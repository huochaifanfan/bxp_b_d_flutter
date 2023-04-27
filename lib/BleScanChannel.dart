import 'package:flutter/services.dart';

class BleScanChannel {
  //1、方法通道名称
  static const _bleScanChannelName = "bleScanChannel";
  static late MethodChannel _bleScanChannel;

  //2、实例化方法通道
  static void initChannel() {
    _bleScanChannel = const MethodChannel(_bleScanChannelName);
  }
//3、异步任务，通过平台通道与特定平台进行通信

}
