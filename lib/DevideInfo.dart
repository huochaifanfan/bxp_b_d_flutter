import 'package:bxp_b_d_flutter/Alarm.dart';
import 'package:bxp_b_d_flutter/Device.dart';
import 'package:bxp_b_d_flutter/Setting.dart';
import 'package:flutter/material.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<DeviceInfoPage> {
  var currentIndex = 0;
  var pageList = const [AlarmPage(), SettingPage(), DevicePage()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: pageList[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            _bottomWidget(
                currentIndex == 0
                    ? 'images/alarm_checked.png'
                    : 'images/alarm_unchecked.png',
                'ALARM'),
            _bottomWidget(
                currentIndex == 1
                    ? 'images/setting_checked.png'
                    : 'images/setting_unchecked.png',
                'SETTING'),
            _bottomWidget(
                currentIndex == 2
                    ? 'images/device_checked.png'
                    : 'images/device_unchecked.png',
                'DEVICE')
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
          backgroundColor: const Color(0xffffffff),
          selectedLabelStyle:
              const TextStyle(color: Color(0xff2f84d0), fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(color: Color(0xff666666), fontSize: 13),
        ),
      ),
    );
  }

  BottomNavigationBarItem _bottomWidget(String imgPath, String labelName) {
    return BottomNavigationBarItem(
        icon: Image.asset(
          imgPath,
          width: 22,
          height: 22,
          fit: BoxFit.cover,
        ),
        label: labelName);
  }
}
