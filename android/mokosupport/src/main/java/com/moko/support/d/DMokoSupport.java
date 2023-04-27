package com.moko.support.d;

import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.content.Context;

import androidx.annotation.NonNull;

import com.elvishew.xlog.XLog;
import com.google.gson.Gson;
import com.moko.ble.lib.MokoBleLib;
import com.moko.ble.lib.MokoBleManager;
import com.moko.ble.lib.MokoConstants;
import com.moko.ble.lib.task.OrderTask;
import com.moko.ble.lib.task.OrderTaskResponse;
import com.moko.support.d.entity.ExportData;
import com.moko.support.d.entity.OrderCHAR;
import com.moko.support.d.entity.OrderTaskEvent;
import com.moko.support.d.handler.MokoCharacteristicHandler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.UUID;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class DMokoSupport extends MokoBleLib {
    private HashMap<OrderCHAR, BluetoothGattCharacteristic> mCharacteristicMap;
    private static volatile DMokoSupport INSTANCE;
    private Context mContext;
    private MokoBleConfig mBleConfig;
    private static final String BLE_HANDLE_CHANNEL = "ble.flutter.io/handle";
    private static final String CONNECT_CALLBACK_CHANNEL = "connect.ble.flutter.io/callback";
    private static final String TASK_CALLBACK_CHANNEL = "task.ble.flutter.io/callback";
    private EventChannel.EventSink mConnectEvents;
    private EventChannel.EventSink mTaskEvents;

    private DMokoSupport() {
        //no instance
    }

    public static DMokoSupport getInstance() {
        if (INSTANCE == null) {
            synchronized (DMokoSupport.class) {
                if (INSTANCE == null) {
                    INSTANCE = new DMokoSupport();
                }
            }
        }
        return INSTANCE;
    }

    public void init(Context context) {
        mContext = context;
        super.init(context);
    }

    public void createEventChannel(@NonNull FlutterEngine flutterEngine){
        new EventChannel(flutterEngine.getDartExecutor(), CONNECT_CALLBACK_CHANNEL).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                mConnectEvents = eventSink;
            }

            @Override
            public void onCancel(Object o) {

            }
        });

        new EventChannel(flutterEngine.getDartExecutor(), TASK_CALLBACK_CHANNEL).setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                mTaskEvents = eventSink;
            }

            @Override
            public void onCancel(Object o) {

            }
        });
    }

    public void createMethodChannel(@NonNull FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor(), BLE_HANDLE_CHANNEL).setMethodCallHandler((methodCall, result) -> {
            if ("bleConnect".equals(methodCall.method)) {
                String mac = methodCall.argument("macAddress");
                if (null != mac) connDevice(mac);
            }else if ("checkPassword".equals(methodCall.method)){
                String password = methodCall.argument("password");
                sendOrder(OrderTaskAssembler.setPassword(password));
            }else if ("bleDisconnect".equals(methodCall.method)){
                disConnectBle();
            }else {
                result.notImplemented();
            }
        });
    }


    @Override
    public MokoBleManager getMokoBleManager() {
        mBleConfig = new MokoBleConfig(mContext, this);
        return mBleConfig;
    }

    ///////////////////////////////////////////////////////////////////////////
    // connect
    ///////////////////////////////////////////////////////////////////////////

    @Override
    public void onDeviceConnected(BluetoothGatt gatt) {
        mCharacteristicMap = new MokoCharacteristicHandler().getCharacteristics(gatt);
//        ConnectStatusEvent connectStatusEvent = new ConnectStatusEvent();
//        connectStatusEvent.setAction(MokoConstants.ACTION_DISCOVER_SUCCESS);
//        EventBus.getDefault().post(connectStatusEvent);
        mConnectEvents.success(MokoConstants.ACTION_DISCOVER_SUCCESS);
    }

    @Override
    public void onDeviceDisconnected(BluetoothDevice device) {
//        ConnectStatusEvent connectStatusEvent = new ConnectStatusEvent();
//        connectStatusEvent.setAction(MokoConstants.ACTION_DISCONNECTED);
//        EventBus.getDefault().post(connectStatusEvent);
        mConnectEvents.success(MokoConstants.ACTION_DISCONNECTED);
    }

    @Override
    public BluetoothGattCharacteristic getCharacteristic(Enum orderCHAR) {
        return mCharacteristicMap.get(orderCHAR);
    }

    ///////////////////////////////////////////////////////////////////////////
    // order
    ///////////////////////////////////////////////////////////////////////////

    @Override
    public boolean isCHARNull() {
        if (mCharacteristicMap == null || mCharacteristicMap.isEmpty()) {
            disConnectBle();
            return true;
        }
        return false;
    }

    @Override
    public void orderFinish() {
//        OrderTaskResponseEvent event = new OrderTaskResponseEvent();
//        event.setAction(MokoConstants.ACTION_ORDER_FINISH);
//        EventBus.getDefault().post(event);
        OrderTaskEvent event = new OrderTaskEvent();
        event.action = MokoConstants.ACTION_ORDER_FINISH;
        String json = new Gson().toJson(event);
        mTaskEvents.success(json);
    }

    @Override
    public void orderTimeout(OrderTaskResponse response) {
//        OrderTaskResponseEvent event = new OrderTaskResponseEvent();
//        event.setAction(MokoConstants.ACTION_ORDER_TIMEOUT);
//        event.setResponse(response);
//        EventBus.getDefault().post(event);
        OrderTaskEvent event = new OrderTaskEvent();
        event.action = MokoConstants.ACTION_ORDER_TIMEOUT;
        event.responseValue = response.responseValue;
        event.orderCHAR = ((OrderCHAR)(response.orderCHAR)).getUuid().toString();
        event.responseType = response.responseType;
        String json = new Gson().toJson(event);
        mTaskEvents.success(json);
    }

    @Override
    public void orderResult(OrderTaskResponse response) {
//        OrderTaskResponseEvent event = new OrderTaskResponseEvent();
//        event.setAction(MokoConstants.ACTION_ORDER_RESULT);
//        event.setResponse(response);
//        EventBus.getDefault().post(event);
        OrderTaskEvent event = new OrderTaskEvent();
        event.action = MokoConstants.ACTION_ORDER_RESULT;
        event.responseValue = response.responseValue;
        event.orderCHAR = ((OrderCHAR)(response.orderCHAR)).getUuid().toString();
        event.responseType = response.responseType;
        String json = new Gson().toJson(event);
        mTaskEvents.success(json);
    }

    @Override
    public boolean orderResponseValid(BluetoothGattCharacteristic characteristic, OrderTask orderTask) {
        final UUID responseUUID = characteristic.getUuid();
        final OrderCHAR orderCHAR = (OrderCHAR) orderTask.orderCHAR;
        return responseUUID.equals(orderCHAR.getUuid());
    }


    @Override
    public boolean orderNotify(BluetoothGattCharacteristic characteristic, byte[] value) {
        final UUID responseUUID = characteristic.getUuid();
        OrderCHAR orderCHAR = null;
        if (responseUUID.equals(OrderCHAR.CHAR_DISCONNECT.getUuid())) {
            orderCHAR = OrderCHAR.CHAR_DISCONNECT;
        }
        if (responseUUID.equals(OrderCHAR.CHAR_ACC.getUuid())) {
            orderCHAR = OrderCHAR.CHAR_ACC;
        }
        if (responseUUID.equals(OrderCHAR.CHAR_SINGLE_TRIGGER.getUuid())) {
            orderCHAR = OrderCHAR.CHAR_SINGLE_TRIGGER;
        }
        if (responseUUID.equals(OrderCHAR.CHAR_DOUBLE_TRIGGER.getUuid())) {
            orderCHAR = OrderCHAR.CHAR_DOUBLE_TRIGGER;
        }
        if (responseUUID.equals(OrderCHAR.CHAR_LONG_TRIGGER.getUuid())) {
            orderCHAR = OrderCHAR.CHAR_LONG_TRIGGER;
        }
        if (orderCHAR == null)
            return false;
        XLog.i(orderCHAR.name());
//        OrderTaskResponse response = new OrderTaskResponse();
//        response.orderCHAR = orderCHAR;
//        response.responseValue = value;
//        OrderTaskResponseEvent event = new OrderTaskResponseEvent();
//        event.setAction(MokoConstants.ACTION_CURRENT_DATA);
//        event.setResponse(response);
//        EventBus.getDefault().post(event);
        OrderTaskEvent event = new OrderTaskEvent();
        event.action = MokoConstants.ACTION_CURRENT_DATA;
        event.responseValue = value;
        event.orderCHAR = orderCHAR.getUuid().toString();
        String json = new Gson().toJson(event);
        mTaskEvents.success(json);
        return true;
    }

    public void enableSingleTriggerNotify() {
        if (mBleConfig != null)
            mBleConfig.enableSingleTriggerNotify();
    }

    public void disableSingleTriggerNotify() {
        if (mBleConfig != null)
            mBleConfig.disableSingleTriggerNotify();
    }

    public void enableDoubleTriggerNotify() {
        if (mBleConfig != null)
            mBleConfig.enableDoubleTriggerNotify();
    }

    public void disableDoubleTriggerNotify() {
        if (mBleConfig != null)
            mBleConfig.disableDoubleTriggerNotify();
    }

    public void enableLongTriggerNotify() {
        if (mBleConfig != null)
            mBleConfig.enableLongTriggerNotify();
    }

    public void disableLongTriggerNotify() {
        if (mBleConfig != null)
            mBleConfig.disableLongTriggerNotify();
    }

    public void enableAccNotify() {
        if (mBleConfig != null)
            mBleConfig.enableAccNotify();
    }

    public void disableAccNotify() {
        if (mBleConfig != null)
            mBleConfig.disableAccNotify();
    }

    public ArrayList<ExportData> exportSingleEvents;
    public StringBuilder storeSingleEventString;
    public ArrayList<ExportData> exportDoubleEvents;
    public StringBuilder storeDoubleEventString;
    public ArrayList<ExportData> exportLongEvents;
    public StringBuilder storeLongEventString;
}
