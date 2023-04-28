package com.moko.support.d;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;

import com.moko.ble.lib.task.OrderTask;
import com.moko.support.d.entity.ParamsKeyEnum;
import com.moko.support.d.task.GetFirmwareRevisionTask;
import com.moko.support.d.task.GetHardwareRevisionTask;
import com.moko.support.d.task.GetManufacturerNameTask;
import com.moko.support.d.task.GetModelNumberTask;
import com.moko.support.d.task.GetSerialNumberTask;
import com.moko.support.d.task.GetSoftwareRevisionTask;
import com.moko.support.d.task.ParamsTask;
import com.moko.support.d.task.PasswordTask;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class OrderTaskAssembler {
    private final String CHANNEL_NAME = "bleMethodTask";

    public void createMethodChannel(@NonNull FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor(), CHANNEL_NAME).setMethodCallHandler((methodCall, result) -> {
            if ("KEY_SENSOR_TYPE".equals(methodCall.method)) {
                DMokoSupport.getInstance().sendOrder(getSensorType());
            } else if ("KEY_SLOT_PARAMS".equals(methodCall.method)) {
                List<OrderTask> orderTasks = new ArrayList<>();
                orderTasks.add(getSlotParams(0));
                orderTasks.add(getSlotParams(1));
                orderTasks.add(getSlotParams(2));
                orderTasks.add(getSlotParams(3));
                DMokoSupport.getInstance().sendOrder(orderTasks.toArray(new OrderTask[]{}));
            } else if ("KEY_EFFECTIVE_CLICK_INTERVAL_GET".equals(methodCall.method)) {
                DMokoSupport.getInstance().sendOrder(getEffectiveClickInterval());
            } else if ("KEY_EFFECTIVE_CLICK_INTERVAL_SET".equals(methodCall.method)) {
                int interval = null == methodCall.argument("interval") ? 6 : methodCall.argument("interval");
                List<OrderTask> orderTasks = new ArrayList<>();
                orderTasks.add(setEffectiveClickInterval(interval));
                orderTasks.add(getEffectiveClickInterval());
                DMokoSupport.getInstance().sendOrder(orderTasks.toArray(new OrderTask[]{}));
            }else if("KEY_DEVICE_NAME_ID_GET".equals(methodCall.method)){
                List<OrderTask> orderTasks = new ArrayList<>();
                orderTasks.add(getDeviceName());
                orderTasks.add(getDeviceId());
                DMokoSupport.getInstance().sendOrder(orderTasks.toArray(new OrderTask[]{}));
            }else if ("KEY_DEVICE_NAME_ID_SET".equals(methodCall.method)){
                String deviceName = methodCall.argument("deviceName");
                String deviceId = methodCall.argument("deviceId");
                List<OrderTask> orderTasks = new ArrayList<>();
                orderTasks.add(setDeviceName(deviceName));
                orderTasks.add(setDeviceId(deviceId));
                orderTasks.add(getDeviceName());
                orderTasks.add(getDeviceId());
                DMokoSupport.getInstance().sendOrder(orderTasks.toArray(new OrderTask[]{}));
            }
        });
    }

    /**
     * @Description 获取制造商
     */
    public OrderTask getManufacturer() {
        GetManufacturerNameTask task = new GetManufacturerNameTask();
        return task;
    }

    /**
     * @Description 获取设备型号
     */
    public OrderTask getDeviceModel() {
        GetModelNumberTask task = new GetModelNumberTask();
        return task;
    }

    /**
     * @Description 获取生产日期
     */
    public OrderTask getProductDate() {
        GetSerialNumberTask task = new GetSerialNumberTask();
        return task;
    }

    /**
     * @Description 获取硬件版本
     */
    public OrderTask getHardwareVersion() {
        GetHardwareRevisionTask task = new GetHardwareRevisionTask();
        return task;
    }

    /**
     * @Description 获取固件版本
     */
    public OrderTask getFirmwareVersion() {
        GetFirmwareRevisionTask task = new GetFirmwareRevisionTask();
        return task;
    }

    /**
     * @Description 获取软件版本
     */
    public OrderTask getSoftwareVersion() {
        GetSoftwareRevisionTask task = new GetSoftwareRevisionTask();
        return task;
    }


    public OrderTask getDeviceMac() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_DEVICE_MAC);
        return task;
    }

    public OrderTask getAxisParams() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_AXIS_PARAMS);
        return task;
    }

    public OrderTask setAxisParams(@IntRange(from = 0, to = 4) int rate,
                                   @IntRange(from = 0, to = 3) int scale,
                                   @IntRange(from = 1, to = 2048) int sensitivity) {
        ParamsTask task = new ParamsTask();
        task.setAxisParams(rate, scale, sensitivity);
        return task;
    }

    /**
     * @Description 获取连接状态
     */
    public OrderTask getConnectable() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_BLE_CONNECTABLE);
        return task;
    }

    /**
     * @Description 设置连接状态
     */
    public OrderTask setConnectable(int enable) {
        ParamsTask task = new ParamsTask();
        task.setBleConnectable(enable);
        return task;
    }

    public OrderTask getVerifyPasswordEnable() {
        PasswordTask task = new PasswordTask();
        task.setData(ParamsKeyEnum.KEY_VERIFY_PASSWORD_ENABLE);
        return task;
    }

    public OrderTask setVerifyPasswordEnable(@IntRange(from = 0, to = 1) int enable) {
        PasswordTask task = new PasswordTask();
        task.setVerifyPasswordEnable(enable);
        return task;
    }

    public static OrderTask setPassword(String password) {
        PasswordTask task = new PasswordTask();
        task.setPassword(password);
        return task;
    }

    public OrderTask setNewPassword(String password) {
        PasswordTask task = new PasswordTask();
        task.setNewPassword(password);
        return task;
    }

    public OrderTask getEffectiveClickInterval() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_EFFECTIVE_CLICK_INTERVAL);
        return task;
    }

    public OrderTask setEffectiveClickInterval(@IntRange(from = 500, to = 1500) int interval) {
        ParamsTask task = new ParamsTask();
        task.setEffectiveClickInterval(interval);
        return task;
    }

    public OrderTask getScanResponseEnable() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_SCAN_RESPONSE_ENABLE);
        return task;
    }

    public OrderTask setScanResponseEnable(@IntRange(from = 0, to = 1) int enable) {
        ParamsTask task = new ParamsTask();
        task.setScanResponseEnable(enable);
        return task;
    }

    public OrderTask getChangePasswordDisconnectEnable() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_CHANGE_PASSWORD_DISCONNECT_ENABLE);
        return task;
    }

    public OrderTask setChangePasswordDisconnectEnable(@IntRange(from = 0, to = 1) int enable) {
        ParamsTask task = new ParamsTask();
        task.setChangePasswordDisconnectEnable(enable);
        return task;
    }

    public OrderTask getButtonResetEnable() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_BUTTON_RESET_ENABLE);
        return task;
    }

    public OrderTask setButtonResetEnable(int enable) {
        ParamsTask task = new ParamsTask();
        task.setButtonResetEnable(enable);
        return task;
    }

    /**
     * @Description 获取电池电量
     */
    public OrderTask getBattery() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_BATTERY_VOLTAGE);
        return task;
    }

    /**
     * @Description 关机
     */
    public OrderTask setClose() {
        ParamsTask task = new ParamsTask();
        task.setData(ParamsKeyEnum.KEY_CLOSE);
        return task;
    }

    /**
     * @Description 保存为默认值
     */
    public OrderTask setDefault() {
        ParamsTask task = new ParamsTask();
        task.setData(ParamsKeyEnum.KEY_DEFAULT);
        return task;
    }

    /**
     * @Description 恢复出厂设置
     */
    public OrderTask resetDevice() {
        ParamsTask task = new ParamsTask();
        task.setData(ParamsKeyEnum.KEY_RESET);
        return task;
    }

    public OrderTask setSinglePressEventClear() {
        ParamsTask task = new ParamsTask();
        task.setData(ParamsKeyEnum.KEY_SINGLE_PRESS_EVENT_CLEAR);
        return task;
    }

    public OrderTask setDoublePressEventClear() {
        ParamsTask task = new ParamsTask();
        task.setData(ParamsKeyEnum.KEY_DOUBLE_PRESS_EVENT_CLEAR);
        return task;
    }

    public OrderTask setLongPressEventClear() {
        ParamsTask task = new ParamsTask();
        task.setData(ParamsKeyEnum.KEY_LONG_PRESS_EVENT_CLEAR);
        return task;
    }

    public OrderTask getSlotParams(@IntRange(from = 0, to = 3) int slot) {
        ParamsTask task = new ParamsTask();
        task.getSlotParams(slot);
        return task;
    }

    public OrderTask setSlotParams(@IntRange(from = 0, to = 3) int slot,
                                   @IntRange(from = 0, to = 1) int enable,
                                   @IntRange(from = -100, to = 0) int rssi,
                                   @IntRange(from = 20, to = 10000) int interval,
                                   @IntRange(from = -40, to = 4) int txPower) {
        ParamsTask task = new ParamsTask();
        task.setSlotParams(slot, enable, rssi, interval, txPower);
        return task;
    }

    public OrderTask getSlotTriggerParams(@IntRange(from = 0, to = 3) int slot) {
        ParamsTask task = new ParamsTask();
        task.getSlotTriggerParams(slot);
        return task;
    }

    public OrderTask setSlotTriggerParams(@IntRange(from = 0, to = 3) int slot,
                                          @IntRange(from = 0, to = 1) int enable,
                                          @IntRange(from = -100, to = 0) int rssi,
                                          @IntRange(from = 20, to = 10000) int interval,
                                          @IntRange(from = -40, to = 4) int txPower,
                                          @IntRange(from = 1, to = 65535) int triggerAdvTime) {
        ParamsTask task = new ParamsTask();
        task.setSlotTriggerParams(slot, enable, rssi, interval, txPower, triggerAdvTime);
        return task;
    }

    public OrderTask getSlotAdvBeforeTriggerEnable(@IntRange(from = 0, to = 3) int slot) {
        ParamsTask task = new ParamsTask();
        task.getSlotAdvBeforeTriggerEnable(slot);
        return task;
    }

    public OrderTask setSlotAdvBeforeTriggerEnable(@IntRange(from = 0, to = 3) int slot,
                                                   @IntRange(from = 0, to = 1) int enable) {
        ParamsTask task = new ParamsTask();
        task.setSlotAdvBeforeTriggerEnable(slot, enable);
        return task;
    }

    public OrderTask getAbnormalInactivityAlarmStaticInterval() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_ABNORMAL_INACTIVITY_ALARM_STATIC_INTERVAL);
        return task;
    }

    public OrderTask setAbnormalInactivityAlarmStaticInterval(@IntRange(from = 1, to = 65535) int interval) {
        ParamsTask task = new ParamsTask();
        task.setAbnormalInactivityAlarmStaticInterval(interval);
        return task;
    }

    public OrderTask getSlotTriggerAlarmNotifyType(@IntRange(from = 0, to = 3) int slot) {
        ParamsTask task = new ParamsTask();
        task.getSlotTriggerAlarmNotifyType(slot);
        return task;
    }

    public OrderTask setSlotTriggerAlarmNotifyType(@IntRange(from = 0, to = 3) int slot,
                                                   @IntRange(from = 0, to = 5) int type) {
        ParamsTask task = new ParamsTask();
        task.setSlotTriggerAlarmNotifyType(slot, type);
        return task;
    }

    public OrderTask getPowerSavingEnable() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_POWER_SAVING_ENABLE);
        return task;
    }

    public OrderTask setPowerSavingEnable(@IntRange(from = 0, to = 1) int enable) {
        ParamsTask task = new ParamsTask();
        task.setPowerSavingEnable(enable);
        return task;
    }

    public OrderTask getPowerSavingStaticTriggerTime() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_POWER_SAVING_STATIC_TRIGGER_TIME);
        return task;
    }

    public OrderTask setPowerSavingStaticTriggerTime(@IntRange(from = 1, to = 65535) int time) {
        ParamsTask task = new ParamsTask();
        task.setPowerSavingStaticTriggerTime(time);
        return task;
    }

    public OrderTask getSlotLEDNotifyAlarmParams(@IntRange(from = 0, to = 3) int slot) {
        ParamsTask task = new ParamsTask();
        task.getSlotLEDNotifyAlarmParams(slot);
        return task;
    }

    public OrderTask setSlotLEDNotifyAlarmParams(@IntRange(from = 0, to = 3) int slot,
                                                 @IntRange(from = 1, to = 6000) int time,
                                                 @IntRange(from = 100, to = 10000) int interval) {
        ParamsTask task = new ParamsTask();
        task.setSlotLEDNotifyAlarmParams(slot, time, interval);
        return task;
    }

    public OrderTask getSlotBuzzerNotifyAlarmParams(@IntRange(from = 0, to = 3) int slot) {
        ParamsTask task = new ParamsTask();
        task.getSlotBuzzerNotifyAlarmParams(slot);
        return task;
    }

    public OrderTask setSlotBuzzerNotifyAlarmParams(@IntRange(from = 0, to = 3) int slot,
                                                    @IntRange(from = 1, to = 6000) int time,
                                                    @IntRange(from = 100, to = 10000) int interval) {
        ParamsTask task = new ParamsTask();
        task.setSlotBuzzerNotifyAlarmParams(slot, time, interval);
        return task;
    }

    public OrderTask getRemoteLEDNotifyAlarmParams() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_REMOTE_LED_NOTIFY_ALARM_PARAMS);
        return task;
    }

    public OrderTask setRemoteLEDNotifyAlarmParams(@IntRange(from = 1, to = 6000) int time,
                                                   @IntRange(from = 100, to = 10000) int interval) {
        ParamsTask task = new ParamsTask();
        task.setRemoteLEDNotifyAlarmParams(time, interval);
        return task;
    }

    public OrderTask getRemoteBuzzerNotifyAlarmParams() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_REMOTE_BUZZER_NOTIFY_ALARM_PARAMS);
        return task;
    }

    public OrderTask setRemoteBuzzerNotifyAlarmParams(@IntRange(from = 1, to = 6000) int time,
                                                      @IntRange(from = 100, to = 10000) int interval) {
        ParamsTask task = new ParamsTask();
        task.setRemoteBuzzerNotifyAlarmParams(time, interval);
        return task;
    }

    public OrderTask setDismissAlarm() {
        ParamsTask task = new ParamsTask();
        task.setData(ParamsKeyEnum.KEY_DISMISS_ALARM);
        return task;
    }

    public OrderTask setDismissAlarmEnable(@IntRange(from = 0, to = 1) int enable) {
        ParamsTask task = new ParamsTask();
        task.setDismissAlarmEnable(enable);
        return task;
    }

    public OrderTask getDismissAlarmEnable() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_DISMISS_ALARM_ENABLE);
        return task;
    }

    public OrderTask getDismissLEDNotifyAlarmParams() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_DISMISS_LED_NOTIFY_ALARM_PARAMS);
        return task;
    }

    public OrderTask setDismissLEDNotifyAlarmParams(@IntRange(from = 1, to = 6000) int time,
                                                    @IntRange(from = 100, to = 10000) int interval) {
        ParamsTask task = new ParamsTask();
        task.setDismissLEDNotifyAlarmParams(time, interval);
        return task;
    }

    public OrderTask getDismissBuzzerNotifyAlarmParams() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_DISMISS_BUZZER_NOTIFY_ALARM_PARAMS);
        return task;
    }

    public OrderTask setDismissBuzzerNotifyAlarmParams(@IntRange(from = 1, to = 6000) int time,
                                                       @IntRange(from = 100, to = 10000) int interval) {
        ParamsTask task = new ParamsTask();
        task.setDismissBuzzerNotifyAlarmParams(time, interval);
        return task;
    }

    public OrderTask getDismissAlarmType() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_DISMISS_ALARM_TYPE);
        return task;
    }

    public OrderTask setDismissAlarmType(@IntRange(from = 0, to = 5) int type) {
        ParamsTask task = new ParamsTask();
        task.setDismissAlarmType(type);
        return task;
    }

    public OrderTask getDeviceId() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_DEVICE_ID);
        return task;
    }

    public OrderTask setDeviceId(String deviceId) {
        ParamsTask task = new ParamsTask();
        task.setDeviceId(deviceId);
        return task;
    }

    public OrderTask getDeviceName() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_DEVICE_NAME);
        return task;
    }

    public OrderTask setDeviceName(String deviceId) {
        ParamsTask task = new ParamsTask();
        task.setDeviceName(deviceId);
        return task;
    }

    public OrderTask getSinglePressEventCount() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_SINGLE_PRESS_EVENTS);
        return task;
    }

    public OrderTask getDoublePressEventCount() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_DOUBLE_PRESS_EVENTS);
        return task;
    }

    public OrderTask getLongPressEventCount() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_LONG_PRESS_EVENTS);
        return task;
    }

    public OrderTask getSensorType() {
        ParamsTask task = new ParamsTask();
        task.getData(ParamsKeyEnum.KEY_SENSOR_TYPE);
        return task;
    }
}
