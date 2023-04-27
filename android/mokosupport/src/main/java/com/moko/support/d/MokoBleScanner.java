package com.moko.support.d;

import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.os.ParcelUuid;
import android.os.SystemClock;

import androidx.annotation.NonNull;

import com.elvishew.xlog.XLog;
import com.google.gson.Gson;
import com.moko.ble.lib.utils.MokoUtils;
import com.moko.support.d.entity.AdvInfo;
import com.moko.support.d.entity.DeviceInfo;
import com.moko.support.d.entity.OrderServices;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import no.nordicsemi.android.support.v18.scanner.BluetoothLeScannerCompat;
import no.nordicsemi.android.support.v18.scanner.ScanCallback;
import no.nordicsemi.android.support.v18.scanner.ScanFilter;
import no.nordicsemi.android.support.v18.scanner.ScanRecord;
import no.nordicsemi.android.support.v18.scanner.ScanResult;
import no.nordicsemi.android.support.v18.scanner.ScanSettings;

public final class MokoBleScanner {
    private final String bleScanChannelName = "scan.ble.flutter.io/handle";
    private final String bleScanCallback = "scan.ble.flutter.io/callback";
    private ScanCallback scanCallback;

    public void createEventChannel(@NonNull FlutterEngine flutterEngine) {
        new EventChannel(flutterEngine.getDartExecutor(), bleScanCallback).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                scanCallback = new ScanCallback() {
                    @Override
                    public void onScanResult(int callbackType, @NonNull ScanResult result) {
                        BluetoothDevice device = result.getDevice();
                        byte[] scanRecord = result.getScanRecord().getBytes();
                        String name = result.getScanRecord().getDeviceName();
                        int rssi = result.getRssi();
                        if (null == scanRecord || scanRecord.length == 0 || rssi == 127) {
                            return;
                        }
                        DeviceInfo deviceInfo = new DeviceInfo();
                        deviceInfo.name = name;
                        deviceInfo.rssi = rssi;
                        deviceInfo.mac = device.getAddress();
                        deviceInfo.scanRecord = MokoUtils.bytesToHexString(scanRecord);
                        deviceInfo.scanResult = result;
                        ScanRecord record = result.getScanRecord();
                        Map<ParcelUuid, byte[]> map = record.getServiceData();
                        if (map == null || map.isEmpty()) return;
                        int battery = -1;
                        int triggerStatus = -1;
                        int triggerCount = -1;
                        String deviceId = "";
                        int accX = 0;
                        int accY = 0;
                        int accZ = 0;
                        int accShown = 0;
                        int deviceInfoFrame = -1;
                        int triggerTypeFrame = -1;
                        int rangeData = -1;
                        int verifyEnable = 0;
                        int deviceType = 0;
                        String dataStr = "";
                        byte[] dataBytes = new byte[0];
                        for (ParcelUuid parcelUuid : map.keySet()) {
                            if (parcelUuid.getUuid().equals(OrderServices.SERVICE_ADV_DEVICE.getUuid())) {
                                byte[] data = map.get(new ParcelUuid(OrderServices.SERVICE_ADV_DEVICE.getUuid()));
                                if (data == null || data.length < 21) continue;
                                deviceInfoFrame = data[0] & 0xFF;
                                accX = MokoUtils.toIntSigned(Arrays.copyOfRange(data, 4, 6));
                                accY = MokoUtils.toIntSigned(Arrays.copyOfRange(data, 6, 8));
                                accZ = MokoUtils.toIntSigned(Arrays.copyOfRange(data, 8, 10));
                                rangeData = data[12];
                                battery = MokoUtils.toInt(Arrays.copyOfRange(data, 13, 15));
                            }
                            if (parcelUuid.getUuid().equals(OrderServices.SERVICE_ADV_TRIGGER.getUuid())) {
                                byte[] data = map.get(new ParcelUuid(OrderServices.SERVICE_ADV_TRIGGER.getUuid()));
                                if (data == null || data.length < 5) continue;
                                dataStr = MokoUtils.bytesToHexString(data);
                                dataBytes = data;
                                triggerTypeFrame = data[0] & 0xFF;
                                verifyEnable = (data[1] & 0x01) == 0x01 ? 1 : 0;
                                triggerStatus = (data[1] & 0x02) == 0x02 ? 1 : 0;
                                triggerCount = MokoUtils.toInt(Arrays.copyOfRange(data, 2, 4));
                                deviceId = String.format("0x%s", MokoUtils.bytesToHexString(Arrays.copyOfRange(data, 4, data.length - 2)).toUpperCase());
                                deviceType = data[data.length - 2] & 0xFF;
                            }
                        }
                        if (accX != 0 || accY != 0 || accZ != 0) accShown = 1;
                        AdvInfo advInfo = new AdvInfo();
                        advInfo.name = deviceInfo.name;
                        advInfo.mac = deviceInfo.mac;
                        advInfo.rssi = deviceInfo.rssi;
                        if (battery < 0) {
                            advInfo.battery = -1;
                        } else {
                            advInfo.battery = battery;
                        }
                        if (result.isConnectable()) {
                            advInfo.connectState = 1;
                        } else {
                            advInfo.connectState = 0;
                        }
                        advInfo.txPower = record.getTxPowerLevel();
                        advInfo.rangingData = rangeData;
                        advInfo.deviceId = deviceId;
                        advInfo.verifyEnable = verifyEnable;
                        advInfo.deviceType = deviceType;
                        advInfo.scanRecord = deviceInfo.scanRecord;
                        advInfo.scanTime = SystemClock.elapsedRealtime();

                        if (triggerTypeFrame > 0) {
                            AdvInfo.TriggerData triggerData = new AdvInfo.TriggerData();
                            triggerData.dataStr = dataStr;
                            triggerData.dataBytes = dataBytes;
                            triggerData.triggerType = triggerTypeFrame;
                            triggerData.triggerStatus = triggerStatus;
                            triggerData.triggerCount = triggerCount;
                            advInfo.triggerData = triggerData;
                        }
                        advInfo.deviceInfoFrame = deviceInfoFrame;
                        if (deviceInfoFrame == 0) {
                            advInfo.rangingData = rangeData;
                            advInfo.accX = accX;
                            advInfo.accY = accY;
                            advInfo.accZ = accZ;
                            advInfo.accShown = accShown;
                        }
                        String msg = new Gson().toJson(advInfo);
                        eventSink.success(msg);
                    }

                    @Override
                    public void onScanFailed(int errorCode) {
                        eventSink.error("onScanFailed", "errorCode:" + errorCode, null);
                    }
                };
            }

            @Override
            public void onCancel(Object o) {
                scanCallback = null;
            }
        });
    }

    public void createMethodChannel(@NonNull FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor(), bleScanChannelName).setMethodCallHandler((methodCall, result) -> {
            if ("bleStartScan".equals(methodCall.method)) {
                //开始扫描
                startScanDevice();
            } else if ("bleStopScan".equals(methodCall.method)) {
                //停止扫描
                stopScanDevice();
            } else {
                result.notImplemented();
            }
        });
    }

    public void startScanDevice() {
        XLog.i("Start scan");
        final BluetoothLeScannerCompat scanner = BluetoothLeScannerCompat.getScanner();
        ScanSettings settings = new ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .build();
        List<ScanFilter> scanFilterList = new ArrayList<>();
        ScanFilter.Builder builder = new ScanFilter.Builder();
        builder.setServiceData(new ParcelUuid(OrderServices.SERVICE_ADV_TRIGGER.getUuid()), null);
        scanFilterList.add(builder.build());
        scanner.startScan(scanFilterList, settings, scanCallback);
    }

    public void stopScanDevice() {
        XLog.i("End scan");
        final BluetoothLeScannerCompat scanner = BluetoothLeScannerCompat.getScanner();
        scanner.stopScan(scanCallback);
    }
}
