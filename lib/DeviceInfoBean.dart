import 'TriggerData.dart';

class DeviceInfoBean {
  DeviceInfoBean({
      this.accShown,
      this.accX,
      this.accY,
      this.accZ,
      this.battery,
      this.beaconTemp,
      this.connectState,
      this.deviceId,
      this.deviceInfoFrame,
      this.deviceType,
      this.intervalTime,
      this.mac,
      this.name,
      this.rangingData,
      this.rssi,
      this.scanRecord,
      this.scanTime,
      this.triggerData,
      this.txPower,
      this.verifyEnable,});

  DeviceInfoBean fromJson(dynamic json) {
    accShown = json['accShown'];
    accX = json['accX'];
    accY = json['accY'];
    accZ = json['accZ'];
    battery = json['battery'];
    beaconTemp = json['beaconTemp'];
    connectState = json['connectState'];
    deviceId = json['deviceId'];
    deviceInfoFrame = json['deviceInfoFrame'];
    deviceType = json['deviceType'];
    intervalTime = json['intervalTime'];
    mac = json['mac'];
    name = json['name'];
    rangingData = json['rangingData'];
    rssi = json['rssi'];
    scanRecord = json['scanRecord'];
    scanTime = json['scanTime'];
    triggerData = json['triggerData'] != null ? TriggerData.fromJson(json['triggerData']) : null;
    txPower = json['txPower'];
    verifyEnable = json['verifyEnable'];
    return this;
  }
  int? accShown;
  int? accX;
  int? accY;
  int? accZ;
  int? battery;
  String? beaconTemp;
  int? connectState;
  String? deviceId;
  int? deviceInfoFrame;
  int? deviceType;
  int? intervalTime;
  String? mac;
  String? name;
  int? rangingData;
  int? rssi;
  String? scanRecord;
  int? scanTime;
  TriggerData? triggerData;
  int? txPower;
  int? verifyEnable;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accShown'] = accShown;
    map['accX'] = accX;
    map['accY'] = accY;
    map['accZ'] = accZ;
    map['battery'] = battery;
    map['beaconTemp'] = beaconTemp;
    map['connectState'] = connectState;
    map['deviceId'] = deviceId;
    map['deviceInfoFrame'] = deviceInfoFrame;
    map['deviceType'] = deviceType;
    map['intervalTime'] = intervalTime;
    map['mac'] = mac;
    map['name'] = name;
    map['rangingData'] = rangingData;
    map['rssi'] = rssi;
    map['scanRecord'] = scanRecord;
    map['scanTime'] = scanTime;
    if (triggerData != null) {
      map['triggerData'] = triggerData?.toJson();
    }
    map['txPower'] = txPower;
    map['verifyEnable'] = verifyEnable;
    return map;
  }

}