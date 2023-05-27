import 'package:flutter/material.dart';
import 'package:gpt_app/grpc/grpc_net.dart';
import 'package:gpt_app/manager/user_manager.dart';

enum LoginState { none, login, logout }

typedef HPM = HomePointerManager;

class HomePointerManager with ChangeNotifier {
  static final HomePointerManager global = HomePointerManager();
  late LoginState state;
  HomePointerManager() {
    state = LoginState.none;
  }
  void login() {
    state = LoginState.login;
    notifyListeners();
  }

  void logout() {
    state = LoginState.logout;
    GRPCNet.shared.shudown;
    UserManager.logout();
    notifyListeners();
  }
}
