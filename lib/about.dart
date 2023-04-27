import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _topTitle(context),
              const Padding(padding: EdgeInsets.only(top: 45)),
              const Image(
                image: AssetImage('images/ic_logo.png'),
                alignment: Alignment.center,
                width: 120,
                height: 120,
              ),
              const Padding(padding: EdgeInsets.only(top: 15)),
              const Text(
                'MOKO BUTTON',
                style: TextStyle(fontSize: 20, color: Color(0xff012d75)),
                textAlign: TextAlign.center,
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              const Text(
                'Version:1.0.3',
                style: TextStyle(fontSize: 20, color: Color(0xffb3b3b3)),
                textAlign: TextAlign.center,
              ),
              const Expanded(child: Padding(padding: EdgeInsets.zero)),
              SizedBox(
                width: 300,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xff2f84d0)),
                      elevation: MaterialStateProperty.all(6),
                      shape: MaterialStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      )),
                  child: const Text(
                    'Feedback log',
                    style: TextStyle(fontSize: 16, color: Color(0xffffffff)),
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              const Text(
                'MOKO TECHNOLOGY LTD.',
                style: TextStyle(fontSize: 20, color: Color(0xff333333)),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              GestureDetector(
                child: const Text(
                  'www.mokoblue.com',
                  style: TextStyle(fontSize: 20, color: Color(0xff2f84d0)),
                ),
                onTap: (){

                },
              ),
              const Padding(padding: EdgeInsets.only(top: 25))
            ],
          ),
        ),
      ),
    );
  }

  Widget _topTitle(BuildContext context) {
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
              'ABOUT',
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
