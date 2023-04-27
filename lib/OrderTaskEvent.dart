
class OrderTaskEvent {
  OrderTaskEvent({
    this.action,
    this.orderCHAR,
    this.responseType,
    this.responseValue,
  });

  OrderTaskEvent fromJson(dynamic json) {
    action = json['action'];
    orderCHAR = json['orderCHAR'];
    responseType = json['responseType'];
    responseValue = json['responseValue'] != null?json['responseValue'].cast<int>():[];
    return this;
  }

  String? action;
  String? orderCHAR;
  int? responseType;
  List<int>? responseValue;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['action'] = action;
    map['orderCHAR'] = orderCHAR;
    map['responseType'] = responseType;
    map['responseValue'] = responseValue;
    return map;
  }
}
