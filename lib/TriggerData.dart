
class TriggerData {
  TriggerData({
      this.dataBytes, 
      this.dataStr, 
      this.triggerCount, 
      this.triggerStatus, 
      this.triggerType,});

  TriggerData.fromJson(dynamic json) {
    dataBytes = json['dataBytes'] != null ? json['dataBytes'].cast<int>() : [];
    dataStr = json['dataStr'];
    triggerCount = json['triggerCount'];
    triggerStatus = json['triggerStatus'];
    triggerType = json['triggerType'];
  }
  List<int>? dataBytes;
  String? dataStr;
  int? triggerCount;
  int? triggerStatus;
  int? triggerType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['dataBytes'] = dataBytes;
    map['dataStr'] = dataStr;
    map['triggerCount'] = triggerCount;
    map['triggerStatus'] = triggerStatus;
    map['triggerType'] = triggerType;
    return map;
  }

}