import 'package:gpt_app/manager/share_preferences_manager.dart';
import 'package:gpt_app/common/user_info_model.dart';

class UserManager {
  static const userInfoKey = "chat-gpt-user-info";

  static Future<String?> getToken() async {
    final loginInfo = await getUserInfo();
    return loginInfo?.token;
  }

  static Future<bool> saveUserInfo(LoginInfoModel? loginInfoModel) async {
    if (null != loginInfoModel) {
      final loginInfo = loginInfoModel.toJson();
      return SPM.setMap(userInfoKey, loginInfo);
    }
    return false;
  }

  static Future<LoginInfoModel?> getUserInfo() async {
    final userInfo = await SPM.getMap(userInfoKey);
    if (userInfo.keys.isNotEmpty) {
      return LoginInfoModel.fromJson(userInfo);
    }
    return null;
  }

  static Future<bool> get isLogin async {
    final userInfo = await getUserInfo();
    return userInfo?.token.isNotEmpty ?? false;
  }

  static Future logout() async {
    await SPM.remove(userInfoKey);
  }
}
