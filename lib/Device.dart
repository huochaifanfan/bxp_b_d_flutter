import 'dart:convert';

import 'package:bxp_b_d_flutter/OrderTaskEvent.dart';
import 'package:bxp_b_d_flutter/mokoutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageDevice();
}

class _HomePageDevice extends State<DevicePage> {
  var taskMethodChannel = const MethodChannel('bleMethodTask');
  var bleDisConnectChannel = const MethodChannel('ble.flutter.io/handle');
  var orderTaskEvent = const EventChannel('task.ble.flutter.io/callback');
  var connectEvent = const EventChannel('connect.ble.flutter.io/callback');
  var orderCharParams = "0000AA01-0000-1000-8000-00805F9B34FB";

  TextEditingController deviceNameController = TextEditingController();
  TextEditingController deviceIdController = TextEditingController();
  var deviceName = "";
  var deviceId = "";

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
    taskMethodChannel.invokeMethod('KEY_DEVICE_NAME_ID_GET');
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  children: [
                    _deviceTitle('Quick switch'),
                    Divider(height: 1, color: lineColor),
                    _deviceTitle('Turn off Beacon'),
                    Divider(height: 1, color: lineColor),
                    _deviceTitle('Reset Beacon'),
                    Divider(height: 1, color: lineColor),
                    _deviceTitle('Modify password'),
                    Divider(height: 1, color: lineColor),
                    _deviceTitle('DFU'),
                    Divider(height: 1, color: lineColor),
                    _deviceTitle('Device info'),
                    Divider(height: 1, color: lineColor),
                    _deviceName(),
                    Divider(height: 1, color: lineColor),
                    _deviceId(),
                    Divider(height: 1, color: lineColor)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceName() {
    deviceNameController.text = deviceName;
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          const Text('Device Name',
              style: TextStyle(fontSize: 15, color: Color(0xff333333))),
          const Expanded(child: Padding(padding: EdgeInsets.zero)),
          SizedBox(
            width: 150,
            height: 35,
            child: TextField(
              controller: deviceNameController,
              autofocus: false,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "1-10 characters"),
              style: const TextStyle(fontSize: 15, color: Color(0xff333333)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceId() {
    deviceIdController.text = deviceId;
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          const Text('Device ID',
              style: TextStyle(fontSize: 15, color: Color(0xff333333))),
          const Expanded(child: Padding(padding: EdgeInsets.zero)),
          const Text(
            '0x',
            style: TextStyle(fontSize: 15, color: Color(0xff333333)),
          ),
          SizedBox(
            width: 150,
            height: 35,
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-fA-F\\d]+"))
              ],
              controller: deviceIdController,
              autofocus: false,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "1-6 bytes"),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xff333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceTitle(String title) {
    return GestureDetector(
      onTap: () {
        onPressModeClick(title);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 15, color: Color(0xff333333))),
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
              alignment: Alignment.centerLeft,
            ),
          ),
          const Text(
            'DEVICE',
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

  void save() {
    if (deviceNameController.text.isEmpty ||
        deviceNameController.text.length > 10) {
      Fluttertoast.showToast(
          msg:
              'Opps！Save failed. Please check the input characters and try again.');
      return;
    }
    if (deviceIdController.text.isEmpty ||
        deviceIdController.text.length % 2 != 0) {
      Fluttertoast.showToast(
          msg:
              'Opps！Save failed. Please check the input characters and try again.');
      return;
    }
    EasyLoading.show();
    taskMethodChannel.invokeMethod('KEY_DEVICE_NAME_ID_SET', {
      'deviceName': deviceNameController.text,
      'deviceId': deviceIdController.text
    });
  }

  void onPressModeClick(String title) {
    Fluttertoast.showToast(msg: title);
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
          if (flag == 0 && cmd == 0x51 && length > 0) {
            List<int> list = List.filled(length, 0);
            List.copyRange(list, 0, value, 4, value.length);
            var name = utf8.decode(list);
            setState(() {
              deviceName = name;
            });
          } else if (flag == 0 && cmd == 0x50 && length > 0) {
            //获取传感器类型
            List<int> result = List.filled(length, 0);
            List.copyRange(result, 0, value, 4, value.length);
            String id = MoKoUtils.bytesToHexString(result);
            setState(() {
              deviceId = id;
            });
          }
        }
      }
    }
  }
}
