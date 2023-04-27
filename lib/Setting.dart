import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageSetting();
}

class _HomePageSetting extends State<SettingPage> {
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
                  _settingTitle('3-axis accelerometer'),
                  Divider(height: 1, color: lineColor),
                  _settingTitle('Power saving configuration'),
                  Divider(height: 1, color: lineColor),
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
    TextEditingController inputController = TextEditingController();
    inputController.text = "8";
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
              Navigator.of(context).pop();
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
