import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gpt_app/manager/chat_db_manager.dart';
import 'package:gpt_app/manager/home_pointer_manager.dart';
import 'package:gpt_app/manager/logger_manager.dart';
import 'package:gpt_app/manager/message_db_manager.dart';
import 'package:gpt_app/manager/user_manager.dart';
import 'package:gpt_app/module/home/page/home_page.dart';
import 'package:gpt_app/module/home/page/launch_page.dart';
import 'package:gpt_app/module/login/login_page.dart';
import 'package:gpt_app/net/api_request.dart';
import 'package:gpt_app/theme/gpt_app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  LoggerManager.initLogger();
  runApp(const GPTApp());
}

class GPTApp extends StatefulWidget {
  const GPTApp({super.key});
  @override
  State<StatefulWidget> createState() => GPTAppState();
}

class GPTAppState extends State<GPTApp> {
  late ThemeMode mode;
  bool _initFinished = false;
  bool _isLogin = false;
  late int userId = -1;
  @override
  void initState() {
    super.initState();
    CDBM.initHive();
    MDBM.initHive();
    ApiRequset.syncServerTime();
    UserManager.getUserInfo().then((value) {
      _isLogin = value?.token.isNotEmpty ?? false;
      userId = value?.userInfo.id ?? -1;
    });
    mode = GPTAppTheme.globalTheme.themeMode;
    GPTAppTheme.globalTheme.addListener(() {
      setState(() {
        mode = GPTAppTheme.globalTheme.themeMode;
      });
    });

    HPM.global.addListener(() {
      if (HPM.global.state != LoginState.none) {
        setState(() {
          if (HPM.global.state == LoginState.login) {
            _isLogin = true;
          } else {
            _isLogin = false;
          }
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 350)).then((value) {
      setState(() {
        _initFinished = true;
      });
    });
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (_initFinished) {
      if (_isLogin) {
        home = GPTHomePage(userId: userId);
      } else {
        home = const LoginPage();
      }
    } else {
      home = const LaunchPage();
    }
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'GPT',
      theme: GPTAppTheme.light,
      darkTheme: GPTAppTheme.dark,
      themeMode: GPTAppTheme.globalTheme.themeMode,
      home: home,
      builder: EasyLoading.init(),
    );
  }
}
