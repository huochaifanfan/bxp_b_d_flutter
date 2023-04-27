import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageAlarm();
}

class _HomePageAlarm extends State<AlarmPage> {
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
                  _pressMode(3),
                  Divider(height: 1, color: lineColor)
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
              Navigator.of(context).pop();
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
            const Text(
              'OFF',
              style: TextStyle(fontSize: 15, color: Color(0xff333333)),
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
}
