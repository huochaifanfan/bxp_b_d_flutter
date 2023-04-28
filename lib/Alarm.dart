import 'dart:convert';

import 'package:bxp_b_d_flutter/OrderTaskEvent.dart';
import 'package:bxp_b_d_flutter/Setting.dart';
import 'package:bxp_b_d_flutter/mokoutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageAlarm();
}

class _HomePageAlarm extends State<AlarmPage> {
  var taskMethodChannel = const MethodChannel('bleMethodTask');
  var bleDisConnectChannel = const MethodChannel('ble.flutter.io/handle');
  var orderTaskEvent = const EventChannel('task.ble.flutter.io/callback');
  var connectEvent = const EventChannel('connect.ble.flutter.io/callback');
  var orderCharParams = "0000AA01-0000-1000-8000-00805F9B34FB";
  var slot1 = 0;
  var slot2 = 0;
  var slot3 = 0;
  var slot4 = 0;
  var hasAcc = false;

  @override
  void initState() {
    super.initState();
    connectEvent.receiveBroadcastStream().listen((event) {
      _onConnectEvent(event);
    }, onError: _onError, onDone: _onDone);
    orderTaskEvent.receiveBroadcastStream().listen((event) {
      _onTaskEvent(event);
    }, onError: _onError, onDone: _onDone);
    EasyLoading.show(status: "syncing");
    //先获取传感器类型
    taskMethodChannel.invokeMethod('KEY_SENSOR_TYPE');
  }

  @override
  Widget build(BuildContext context) {
    var lineColor = const Color(0xffb3b3b3);
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            _topTitle(),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: [
                  _pressMode(0),
                  Divider(height: 1, color: lineColor),
                  _pressMode(1),
                  Divider(height: 1, color: lineColor),
                  _pressMode(2),
                  Divider(height: 1, color: lineColor),
                  Visibility(visible: hasAcc, child: _pressMode(3)),
                  Visibility(
                      visible: hasAcc,
                      child: Divider(height: 1, color: lineColor))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topTitle() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
      width: MediaQuery.of(context).size.width,
      height: 80,
      color: const Color(0xff2f84d0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              bleDisConnectChannel.invokeMethod('bleDisconnect');
              Navigator.popUntil(context, ModalRoute.withName('mainScan'));
            },
            child: const Image(
              image: AssetImage('images/back.png'),
              width: 20,
              height: 20,
              alignment: Alignment.centerLeft,
            ),
          ),
          const Expanded(
            child: Text(
              'ALARM',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pressMode(int index) {
    var titleList = const [
      'Single press mode',
      'Double press mode',
      'Long press mode',
      'Abnormal inactivity mode'
    ];
    var result = "OFF";
    if (index == 0) {
      result = slot1 == 1 ? "ON" : "OFF";
    } else if (index == 1) {
      result = slot2 == 1 ? "ON" : "OFF";
    } else if (index == 2) {
      result = slot3 == 1 ? "ON" : "OFF";
    } else if (index == 3) {
      result = slot4 == 1 ? "ON" : "OFF";
    }
    return GestureDetector(
      onTap: () {
        onPressModeClick(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            Text(
              titleList[index],
              style: const TextStyle(fontSize: 15, color: Color(0xff333333)),
            ),
            const Expanded(child: Padding(padding: EdgeInsets.zero)),
            Text(
              result,
              style: const TextStyle(fontSize: 15, color: Color(0xff333333)),
            ),
            const Padding(padding: EdgeInsets.only(left: 6)),
            Image.asset(
              'images/arrow_right.png',
              width: 15,
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  void onPressModeClick(int index) {
    var msg = "";
    if (index == 0) {
      msg = "Single press mode";
    } else if (index == 1) {
      msg = "Double press mode";
    } else if (index == 2) {
      msg = "Long press mode";
    } else {
      msg = "Abnormal inactivity mode";
    }
    Fluttertoast.showToast(msg: msg);
  }

  void _onError(Object error) {}

  void _onDone() {}

  ///设备连接状态
  void _onConnectEvent(Object event) {
    if ("ACTION_DISCONNECTED" == event) {
      Fluttertoast.showToast(msg: '设备断开');
    }
  }

  void _onTaskEvent(Object event) {
    OrderTaskEvent orderTaskEvent =
        OrderTaskEvent().fromJson(jsonDecode(event as String));
    if (orderTaskEvent.action == "ACTION_ORDER_FINISH") {
      //取消弹窗显示
      EasyLoading.dismiss();
    } else if (orderTaskEvent.action == "ACTION_ORDER_TIMEOUT") {
      //超时
    } else if (orderTaskEvent.action == "ACTION_ORDER_RESULT") {
      //收到结果
      if (orderTaskEvent.orderCHAR!.toUpperCase() == orderCharParams) {
        var value = orderTaskEvent.responseValue!;
        if (value.length >= 4) {
          var header = value[0] & 0xff;
          var flag = value[1] & 0xff;
          var cmd = value[2] & 0xff;
          var length = value[3] & 0xff;
          if (header != 0xEB) return;
          if (flag == 0 && cmd == 0x34 && length == 6) {
            //通道数据
            var slot = value[4];
            var slotEnable = value[5] & 0xff;
            setState(() {
              if (slot == 0) {
                slot1 = slotEnable;
              } else if (slot == 1) {
                slot2 = slotEnable;
              } else if (slot == 2) {
                slot3 = slotEnable;
              } else if (slot == 3) {
                slot4 = slotEnable;
              }
            });
          } else if (flag == 0 && cmd == 0x4F && length > 0) {
            //获取传感器类型
            List<int> result = List.filled(length, 0);
            List.copyRange(result, 0, value, 4, value.length);
            var val = MoKoUtils.bytes2int(result);
            setState(() {
              hasAcc = (val & 0x01) == 1;
            });
            EasyLoading.show(status: "syncing");
            taskMethodChannel.invokeMethod('KEY_SLOT_PARAMS');
          }
        }
      }
    }
  }
}
