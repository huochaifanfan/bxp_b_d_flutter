import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PasswordDialog extends Dialog {
  final String password;

  const PasswordDialog(this.password, {super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
    passwordController.text = password;
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6))),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 240,
        height: null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(padding: EdgeInsets.only(top: 15)),
            const Text('Please enter password',
                style: TextStyle(fontSize: 16, color: Color(0xff333333))),
            const Padding(padding: EdgeInsets.only(top: 15)),
            TextField(
              controller: passwordController,
              autofocus: true,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "8 characters"),
              style: const TextStyle(fontSize: 16, color: Color(0xff333333)),
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            const Divider(height: 1, color: Color(0xfff2f2f2)),
            SizedBox(
              height: 45,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xff2f84d0))),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: Color(0xfff2f2f2)),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        var password = passwordController.text;
                        if (password.isEmpty) {
                          EasyLoading.showToast('Password cannot be empty');
                          return;
                        }
                        if (password.length != 8) {
                          EasyLoading.showToast('Length should be 8 bits');
                          return;
                        }
                        Navigator.of(context).pop(password);
                      },
                      child: const Text('OK',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xff2f84d0))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
