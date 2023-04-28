import 'dart:convert';

import 'package:bxp_b_d_flutter/OrderTaskEvent.dart';
import 'package:bxp_b_d_flutter/mokoutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageSetting();
}

class _HomePageSetting extends State<SettingPage> {
  var taskMethodChannel = const MethodChannel('bleMethodTask');
  var bleDisConnectChannel = const MethodChannel('ble.flutter.io/handle');
  var orderTaskEvent = const EventChannel('task.ble.flutter.io/callback');
  var connectEvent = const EventChannel('connect.ble.flutter.io/callback');
  var orderCharParams = "0000AA01-0000-1000-8000-00805F9B34FB";
  var hasAcc = false;
  var clickInterval = 0;
  TextEditingController inputController = TextEditingController();

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
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            _topTitle(),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: [
                  _settingTitle('Alarm event'),
                  Divider(height: 1, color: lineColor),
                  _settingTitle('Dismiss alarm configuration'),
                  Divider(height: 1, color: lineColor),
                  _settingTitle('Remote reminder'),
                  Divider(height: 1, color: lineColor),
                  Visibility(
                    visible: hasAcc,
                    child: Column(
                      children: [
                        _settingTitle('3-axis accelerometer'),
                        Divider(height: 1, color: lineColor),
                        _settingTitle('Power saving configuration'),
                        Divider(height: 1, color: lineColor),
                      ],
                    ),
                  ),
                  _effectiveClickInterval(),
                  Divider(height: 1, color: lineColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _effectiveClickInterval() {
    inputController.text = clickInterval.toString();
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          const Text('Effective click interval',
              style: TextStyle(fontSize: 15, color: Color(0xff333333))),
          const Expanded(child: Padding(padding: EdgeInsets.zero)),
          SizedBox(
            width: 75,
            height: 35,
            child: TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: inputController,
              autofocus: false,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "5 ~ 15"),
              style: const TextStyle(fontSize: 15, color: Color(0xff333333)),
            ),
          ),
          const Text(
            'x 100ms',
            style: TextStyle(fontSize: 15, color: Color(0xff333333)),
          )
        ],
      ),
    );
  }

  Widget _settingTitle(String title) {
    return GestureDetector(
      onTap: () {
        onPressModeClick(title);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            Text(title,
                style: const TextStyle(fontSize: 15, color: Color(0xff333333))),
            const Expanded(child: Padding(padding: EdgeInsets.zero)),
            const Padding(padding: EdgeInsets.only(left: 6)),
            Image.asset('images/arrow_right.png', width: 15, height: 15)
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.popUntil(context, ModalRoute.withName('mainScan'));
            },
            child: const Image(
                image: AssetImage('images/back.png'),
                width: 20,
                height: 20,
                alignment: Alignment.centerLeft),
          ),
          const Text(
            'SETTING',
            style: TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: () {
              save();
            },
            child: Image.asset('images/save.png', width: 20, height: 20),
          ),
        ],
      ),
    );
  }

  /// 保存点击间隔
  void save() {
    var interval = int.parse(inputController.text);
    if (interval < 5 || interval > 15) {
      Fluttertoast.showToast(
          msg:
              'Opps！Save failed. Please check the input characters and try again.');
      return;
    }
    EasyLoading.show();
    taskMethodChannel.invokeMethod(
        'KEY_EFFECTIVE_CLICK_INTERVAL_SET', {'interval': interval * 100});
  }

  void onPressModeClick(String title) {
    Fluttertoast.showToast(msg: title);
  }

  void setAcc(bool hasAcc) {
    this.hasAcc = hasAcc;
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
          if (flag == 0 && cmd == 0x25 && length == 2) {
            List<int> intervalArray = List.filled(2, 0);
            List.copyRange(intervalArray, 0, value, 4, 6);
            var interval = MoKoUtils.bytes2int(intervalArray);
            setState(() {
              clickInterval = interval ~/ 100;
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
            taskMethodChannel.invokeMethod('KEY_EFFECTIVE_CLICK_INTERVAL_GET');
          }
        }
      }
    }
  }
}
