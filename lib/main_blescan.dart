import 'dart:collection';
import 'dart:convert';

import 'package:bxp_b_d_flutter/DeviceInfoBean.dart';
import 'package:bxp_b_d_flutter/DevideInfo.dart';
import 'package:bxp_b_d_flutter/OrderTaskEvent.dart';
import 'package:bxp_b_d_flutter/PasswordDialog.dart';
import 'package:bxp_b_d_flutter/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScanMainPage extends StatelessWidget {
  const ScanMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'about': (context) => const AboutPage(),
        'deviceInfo': (context) => const DeviceInfoPage(),
      },
      home: const HomeScanPage(),
    );
  }
}

class HomeScanPage extends StatefulWidget {
  const HomeScanPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScanPage>
    with SingleTickerProviderStateMixin {
  //蓝牙扫描
  static const MethodChannel scanMethodChannel =
      MethodChannel('scan.ble.flutter.io/handle');
  static const EventChannel scanEventChannel =
      EventChannel('scan.ble.flutter.io/callback');

  static const MethodChannel bleMethodChannel =
      MethodChannel('ble.flutter.io/handle');

  static const EventChannel connectEventChannel =
      EventChannel('connect.ble.flutter.io/callback');
  static const EventChannel taskEventChannel =
      EventChannel('task.ble.flutter.io/callback');

  //蓝牙扫描的数据
  Map<String, DeviceInfoBean> deviceMap = HashMap();
  List<DeviceInfoBean> deviceList = [];

  /// 会重复播放的控制器
  late AnimationController _repeatController;
  var isScan = false;
  var password = "";
  String orderCharPassword = "0000AA07-0000-1000-8000-00805F9B34FB";

  @override
  void initState() {
    super.initState();
    scanEventChannel.receiveBroadcastStream().listen((event) {
      _onScanEvent(event);
    }, onError: _onError, onDone: _onDone);
    connectEventChannel.receiveBroadcastStream().listen((event) {
      _onConnectEvent(event);
    }, onError: _onError, onDone: _onDone);
    taskEventChannel.receiveBroadcastStream().listen((event) {
      _onTaskEvent(event);
    }, onError: _onError, onDone: _onDone);

    scanMethodChannel.invokeListMethod('bleStartScan');
    _repeatController = AnimationController(
        duration: const Duration(milliseconds: 1800), vsync: this);
    _repeatController.forward();
    isScan = true;
    _repeatController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _repeatController.reset();
        _repeatController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      body: Center(
        child: Column(
          children: [
            _topTitle(),
            const Padding(padding: EdgeInsets.only(top: 10)),
            _topSearch(),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  itemCount: deviceList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _listItem(deviceList[index]);
                  }),
            ),
          ],
        ),
      ),
    );
  }

  /// 接受到扫描的回调方法
  void _onScanEvent(Object event) {
    DeviceInfoBean infoBean =
        DeviceInfoBean().fromJson(jsonDecode(event as String));
    if (deviceMap.containsKey(infoBean.mac)) {
      deviceMap.update(infoBean.mac!, (value) => infoBean);
    } else {
      deviceMap.putIfAbsent(infoBean.mac!, () => infoBean);
    }
    List<DeviceInfoBean> list = deviceMap.values.toList();
    list.sort((a, b) => b.rssi!.compareTo(a.rssi!));
    setState(() {
      deviceList = list;
    });
  }

  ///设备连接状态
  void _onConnectEvent(Object event) {
    EasyLoading.dismiss();
    if ("ACTION_DISCOVER_SUCCESS" == event) {
      //验证密码
      if (password.isNotEmpty) {
        EasyLoading.show(status: 'syncing');
        checkPwd();
        // bleMethodChannel.invokeMethod('checkPassword', {'password': password});
      }else{
        //跳转页面
        Navigator.pushNamed(context, 'deviceInfo');
      }
    } else if ("ACTION_DISCONNECTED" == event) {
      Fluttertoast.showToast(msg: 'connect fail!');
      password = "";
      onRefreshClick();
    }
  }

  void checkPwd() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    bleMethodChannel.invokeMethod('checkPassword', {'password': password});
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
      if (orderTaskEvent.orderCHAR!.toUpperCase() == orderCharPassword) {
        var value = orderTaskEvent.responseValue!;
        if (value.length == 5) {
          var header = value[0] & 0xff;
          var flag = value[1] & 0xff;
          var cmd = value[2] & 0xff;
          var length = value[3] & 0xff;
          if (header != 0xEB) return;
          if (flag == 1 && length == 1 && cmd == 0x55) {
            var result = value[4] & 0xFF;
            if (result == 0xaa) {
              //密码验证成功 跳转下一个页面
              Navigator.pushNamed(context, 'deviceInfo');
            } else {
              Fluttertoast.showToast(msg: 'Password incorrect！');
              bleMethodChannel.invokeMethod('bleDisconnect');
            }
          }
        }
      }
    }
  }

  void _onError(Object error) {}

  void _onDone() {}

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
            onTap: onBackPress,
            child: const Image(
              alignment: Alignment.centerLeft,
              image: AssetImage('images/back.png'),
              width: 20,
              height: 20,
            ),
          ),
          Text(
            'Devices（${deviceList.length}）',
            style: const TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: onAboutClick,
            child: const Image(
              alignment: Alignment.centerRight,
              image: AssetImage('images/about.png'),
              width: 20,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }

  //顶部搜索栏
  Widget _topSearch() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.only(left: 10, right: 10),
          height: 45,
          width: MediaQuery.of(context).size.width - 70,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: Colors.white),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: const [
              Image(
                image: AssetImage('images/filter_search.png'),
                width: 20,
                height: 20,
              ),
              Padding(padding: EdgeInsets.only(left: 10)),
              Text(
                'Edit Filter',
                style: TextStyle(fontSize: 16, color: Color(0xffd9d9d9)),
              ),
              Expanded(child: Text('')),
              Image(
                image: AssetImage('images/filter_arrow.png'),
                width: 16,
                height: 16,
              ),
            ],
          ),
        ),
        const Expanded(child: Text('')),
        _refreshImage(),
        const Expanded(child: Text('')),
      ],
    );
  }

  Widget _refreshImage() {
    return RotationTransition(
      turns: _repeatController,
      child: GestureDetector(
        onTap: onRefreshClick,
        child: const Image(
          image: AssetImage('images/refresh.png'),
          width: 23,
          height: 23,
        ),
      ),
    );
  }

  //listView item项
  Widget _listItem(DeviceInfoBean infoBean) {
    return Card(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      elevation: 6,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(left: 5)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(padding: EdgeInsets.only(top: 15)),
              const Image(
                image: AssetImage('images/rssi.png'),
                width: 30,
                height: 12,
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
              Text(
                '${infoBean.rssi}dBm',
                style: const TextStyle(fontSize: 13, color: Color(0xff666666)),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              const Image(
                image: AssetImage('images/battery_1.png'),
                width: 30,
                height: 14,
                fit: BoxFit.cover,
              ),
              const Padding(padding: EdgeInsets.only(top: 40)),
            ],
          ),
          const Padding(padding: EdgeInsets.only(left: 15)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 18)),
              Text(
                infoBean.name ?? "NA",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              Text(
                'MAC:${infoBean.mac}',
                style: const TextStyle(fontSize: 14, color: Color(0xff666666)),
              ),
              const Padding(padding: EdgeInsets.only(top: 6)),
              Text(
                'Device ID：${infoBean.deviceId}',
                style: const TextStyle(fontSize: 11, color: Color(0xff666666)),
              ),
            ],
          ),
          const Expanded(child: Text('')),
          GestureDetector(
            onTap: () {
              connect(infoBean);
            },
            child: Container(
              width: 90,
              height: 35,
              margin: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xff2f84d0),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: const Text(
                'CONNECT',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(left: 5)),
        ],
      ),
    );
  }

  connect(DeviceInfoBean infoBean) async {
    //停止动画
    scanMethodChannel.invokeListMethod('bleStopScan');
    isScan = false;
    _repeatController.stop();
    if (infoBean.verifyEnable == 1) {
      //密码弹窗
      var result = await showDialog(
          context: context,
          builder: (context) {
            return const PasswordDialog('Moko4321');
          });
      password = result;
      EasyLoading.show();
      bleMethodChannel.invokeMethod('bleConnect', {'macAddress': infoBean.mac});
    }else{
      EasyLoading.show();
      bleMethodChannel.invokeMethod('bleConnect', {'macAddress': infoBean.mac});
    }
  }

  void onRefreshClick() {
    if (isScan) {
      scanMethodChannel.invokeListMethod('bleStopScan');
      isScan = false;
      _repeatController.stop();
    } else {
      setState(() {
        deviceMap.clear();
        deviceList.clear();
      });
      scanMethodChannel.invokeListMethod('bleStartScan');
      isScan = true;
      _repeatController.reset();
      _repeatController.forward();
    }
  }

  void onBackPress() {
    Navigator.pop(context);
  }

  void onAboutClick() {
    Navigator.pushNamed(context, 'about');
  }
}
