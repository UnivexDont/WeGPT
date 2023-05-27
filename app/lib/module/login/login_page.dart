import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gpt_app/common/api/api_common_manager.dart';
import 'package:gpt_app/manager/home_pointer_manager.dart';
import 'package:gpt_app/manager/user_manager.dart';
import 'package:gpt_app/theme/theme_colors.dart';
import 'package:gpt_app/uitls/string.dart';

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  int _smsCodeSeconds = 60;
  bool _smsCodeEable = true;
  Timer? _smsCodeTimer;
  bool _isCheck = true;

  @override
  void initState() {
    super.initState();
    _passController.addListener(() {
      if (_passController.text.length > 6) {
        final text = _passController.text.substring(0, 6);
        _passController.value = TextEditingValue(
            text: text,
            selection:
                TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: text.length)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(30),
          child: Column(children: [
            const Text(
              'GPT-欢迎您！',
              style: TextStyle(fontSize: 30),
            ),
            const Padding(padding: EdgeInsets.all(25)),
            _buildTextField(Icons.phone_iphone, '请输入邮箱', _phoneController),
            const Padding(padding: EdgeInsets.all(2.5)),
            _buildTextField(Icons.lock_outline, '请输入验证码', _passController),
            const Padding(padding: EdgeInsets.all(2.5)),
            _buildTextField(Icons.rsvp_outlined, '邀请码(选填)', _codeController),
            // _buildPricayWidget(),
            const Padding(padding: EdgeInsets.all(5)),
            InkWell(
                onTap: goLogin,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(color: themeBlue, width: 0.5), //灰色的一层边框
                      borderRadius: const BorderRadius.all(Radius.circular(20))),
                  child: Row(children: const [
                    Spacer(),
                    Text(
                      "登录",
                      style: TextStyle(color: themeBlue, fontSize: 18),
                    ),
                    Spacer()
                  ]),
                )),
          ]),
        )
      ]),
    );
  }

// MARK: - builds

  Widget _buildTextField(IconData icon, String hintText, TextEditingController controller) {
    final isCodeFiled = controller == _passController;
    const border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
      ),
    );
    final rows = [
      Icon(icon),
      Flexible(
          child: SizedBox(
              height: 50,
              child: TextField(
                keyboardType: isCodeFiled ? TextInputType.phone : TextInputType.emailAddress,
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  border: border,
                  enabledBorder: border,
                  disabledBorder: border,
                  focusedBorder: border,
                  hintText: hintText,
                ),
              ))),
    ];
    if (hintText == '请输入验证码') {
      rows.add(SizedBox(
        width: 120,
        height: 40,
        child: TextButton(
          onPressed: sendSmsCode,
          child: Text(
            _smsCodeEable ? '获取验证码' : '$_smsCodeSeconds/s后获取',
            style: TextStyle(fontSize: 12, color: _smsCodeEable ? themeBlue : Colors.grey),
          ),
        ),
      ));
    }
    return SizedBox(
      height: 51,
      child: Column(
        children: [
          const Spacer(),
          Row(
            children: rows,
          ),
          const Spacer(),
          const Divider(
            color: cellLine,
            height: 0.5,
            thickness: 0.5,
          )
        ],
      ),
    );
  }

  // Widget _buildPricayWidget() {
  //   return Row(children: [
  //     InkWell(
  //       onTap: () {
  //         setState(() {
  //           _isCheck = !_isCheck;
  //         });
  //       },
  //       child: SizedBox(
  //         width: 30,
  //         height: 40,
  //         child: Icon(
  //           _isCheck ? Icons.check_circle : Icons.circle_outlined,
  //           color: _isCheck ? themeBlue : null,
  //         ),
  //       ),
  //     ),
  //     const Text(
  //       '我已阅读并同意',
  //       style: TextStyle(fontSize: 12),
  //     ),
  //     InkWell(onTap: () => skipTo(), child: const Text('《服务协议》', style: TextStyle(color: themeBlue, fontSize: 12))),
  //     const Text(
  //       '和',
  //       style: TextStyle(fontSize: 12),
  //     ),
  //     InkWell(
  //         onTap: () => skipTo(),
  //         child: const Text(
  //           '《隐私协议》',
  //           style: TextStyle(color: themeBlue, fontSize: 12),
  //         )),
  //     const Spacer()
  //   ]);
  // }

// MARK: - Actions

  void goLogin() {
    if (!_isCheck) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: const Text("登录前，请先阅读并同意《服务协议》", style: TextStyle(color: themeBlue)),
            actions: [
              CupertinoDialogAction(
                child: const Text("取消", style: TextStyle(color: themeBlue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text(
                  "确认",
                  style: TextStyle(color: okBtnColor),
                ),
                onPressed: () {
                  setState(() {
                    _isCheck = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    final loginId = _phoneController.text;
    final pass = _passController.text;
    final inviteCode = _codeController.text;

    if (!loginId.isEmail) {
      EasyLoading.showToast('请输入正确的邮箱', duration: const Duration(milliseconds: 1382));
      return;
    }
    if (!pass.isVerifyCode) {
      EasyLoading.showToast('请输入6位有效的验证码', duration: const Duration(milliseconds: 1382));
      return;
    }

    ACM.login({"email": loginId, "verifyCode": pass, "inviteCode": inviteCode}).then((value) {
      if (value.success) {
        EasyLoading.showToast(value.message);
        UserManager.saveUserInfo(value.data);
        HPM.global.login();
      } else {
        EasyLoading.showToast(value.message);
      }
    });
  }

  void skipTo() {}

  void sendSmsCode() {
    if (_smsCodeEable) {
      final loginId = _phoneController.text;
      if (!loginId.isEmail) {
        EasyLoading.showToast('请输入正确的邮箱', duration: const Duration(milliseconds: 1382));
        return;
      }
      EasyLoading.show();
      ACM.fetchVerifyCode({"email": loginId}).then((value) {
        EasyLoading.dismiss();
        if (value.success) {
          setState(() {
            _smsCodeEable = false;
            _smsCodeTimer = Timer.periodic(const Duration(seconds: 1), timerAction);
          });
        } else {
          EasyLoading.showToast(value.message);
        }
      });
    }
  }

  void timerAction(Timer timer) {
    setState(() {
      _smsCodeSeconds -= 1;
      if (_smsCodeSeconds == 0) {
        _smsCodeEable = true;
        _smsCodeSeconds = 60;
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _smsCodeTimer?.cancel();
    _smsCodeTimer = null;
    super.dispose();
  }
}
