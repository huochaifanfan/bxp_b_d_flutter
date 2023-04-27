import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageDevice();
}

class _HomePageDevice extends State<DevicePage> {
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
    TextEditingController inputController = TextEditingController();
    // inputController.text = "";
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
              controller: inputController,
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
    TextEditingController inputController = TextEditingController();
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          const Text('Device Name',
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
              controller: inputController,
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
              Navigator.of(context).pop();
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
            onTap: () {},
            child: Image.asset('images/save.png', width: 20, height: 20),
          ),
        ],
      ),
    );
  }

  void onPressModeClick(String title) {
    Fluttertoast.showToast(msg: title);
  }
}
