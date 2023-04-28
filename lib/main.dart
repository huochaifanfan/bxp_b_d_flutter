import 'package:bxp_b_d_flutter/main_blescan.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = const Color(0xffffffff)
    ..indicatorColor = const Color(0xff333333)
    ..textColor = const Color(0xff333333)
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = const Color(0x80444444);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    //开始权限请求
    requestPermission();
  }

  void _incrementCounter() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Image.asset(
            'images/ic_guide.png',
            fit: BoxFit.cover,
            //自适应填充显示，图片不会变形，但可能被剪裁
          ),
        ),
      ),
    );
  }

  //请求权限
  Future<void> requestPermission() async {
    int version = await deviceInfo;
    var isNeverAsk = false;
    if (version >= 23 && version <= 28) {
      //申请存储权限 6-9的版本走这里 需要申请写SD卡权限和定位权限
      var storageStatus = await Permission.storage.status;
      var locationStatus = await Permission.location.status;
      if (storageStatus.isGranted && locationStatus.isGranted) {
        //获得了权限
        _gotoMain();
      } else {
        var content = "";
        if (storageStatus.isPermanentlyDenied ||
            locationStatus.isPermanentlyDenied) {
          content =
          'Please find it in cellphone setting- permission, and allow MK Button CR use the Storage and location permission';
          isNeverAsk = true;
        } else {
          content =
          'MK Button D requires access to Storage and location permission. If the permissions are not on, MK Button D cannot be used normally.';
        }
        _showDialog(content, isNeverAsk);
      }
    } else if (version >= 23 && version <= 30) {
      //判断GPS是否打开  10-11走这里 不再申请写SD权限 申请了也没用
      var locationStatus = await Permission.location.request();
      if (locationStatus == PermissionStatus.granted) {
        //获得了权限
        _gotoMain();
      } else {
        var content = "";
        if (locationStatus.isPermanentlyDenied) {
          content =
          '>Please find it in cellphone setting- permission, and allow MK Button CR use the Location permission';
          isNeverAsk = true;
        } else {
          content =
          'MK Button CR requires access to Location permission. If the permissions are not on, MK Button CR cannot be used normally.';
        }
        _showDialog(content, isNeverAsk);
      }
    } else {
      var locationStatus = await Permission.location.request();
      var bleConnectStatus = await Permission.bluetoothConnect.request();
      var bleScanStatus = await Permission.bluetoothScan.request();
      if (locationStatus == PermissionStatus.granted &&
          bleConnectStatus == PermissionStatus.granted &&
          bleScanStatus == PermissionStatus.granted) {
        _gotoMain();
      } else {
        var content = "";
        if (locationStatus.isPermanentlyDenied ||
            bleScanStatus.isPermanentlyDenied ||
            bleConnectStatus.isPermanentlyDenied) {
          content =
          'Please find it in cellphone setting- permission, and allow MK Button CR use the bluetooth and location permission';
          isNeverAsk = true;
        } else {
          content =
          'MK Button CR requires access to bluetooth scan contract and location permission. If the permissions are not on, MK Button CR cannot be used normally.';
        }
        _showDialog(content, isNeverAsk);
      }
    }
  }

  void _showDialog(var content, var isNeverAsk) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text(
                  'CANCEL',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop(1);
                },
              ),
              CupertinoDialogAction(
                child: const Text(
                  'CONFIRM',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (isNeverAsk) {
                    openAppSettings();
                  } else {
                    //再次请求权限
                    requestPermission();
                  }
                },
              ),
            ],
          );
        });
  }

  static get deviceInfo async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var deviceInfo = await deviceInfoPlugin.androidInfo;
    var version = deviceInfo.version.release;
    return int.parse(version ?? "0");
  }

  void _gotoMain() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:
        (context) => const ScanMainPage()), (route) => false);
  }
}
