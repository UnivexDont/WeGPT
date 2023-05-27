import 'package:gpt_app/common/api_result.dart';
import 'package:gpt_app/common/user_info_model.dart';
import 'package:gpt_app/module/home/model/invite_code_model.dart';
import 'package:gpt_app/net/api_request.dart';

typedef ACM = ApiCommonManager;

class ApiCommonManager {
  static const userLogin = "/user/login";
  static const userLogout = "/user/logout";
  static const userCancelAccount = "/user/cancel/account";
  static const loginVrifyCode = "/user/verifycode/:email";
  static const generateInviteCode = "/user/generate/invite";
  static const inviteCode = "/user/invite/code";

  static Future<ApiResult<LoginInfoModel>> login(Map<String, dynamic> params) async {
    final json = await AR.post(userLogin, parameters: params, needSecret: true);
    final resultModel = ApiResult.fromJson(json, (json) {
      return LoginInfoModel.fromJson(json);
    });
    return resultModel;
  }

  static Future<ApiResult<dynamic>> logout() async {
    final json = await AR.post(userLogout, parameters: {}, needSecret: true, needAuth: true);
    final resultModel = ApiResult.fromJson(json, (json) {
      return null;
    });
    return resultModel;
  }

  static Future<ApiResult<dynamic>> fetchVerifyCode(Map<String, dynamic> params) async {
    final json = await AR.get(loginVrifyCode, queryParameters: params, needSecret: true);
    final resultModel = ApiResult.fromJson(json, (json) => null);
    return resultModel;
  }

  static Future<ApiResult<dynamic>> cancelAccount() async {
    final json = await AR.post(userCancelAccount, needSecret: true, needAuth: true);
    final resultModel = ApiResult.fromJson(json, (json) => null);
    return resultModel;
  }

  static Future<ApiResult<InviteCodeModel>> generateInvite() async {
    final json = await AR.get(generateInviteCode, needSecret: true, needAuth: true);
    final resultModel = ApiResult.fromJson(json, (json) => InviteCodeModel.fromJson(json));
    return resultModel;
  }

  static Future<ApiResult<InviteCodeModel>> fetchInviteCode() async {
    final json = await AR.get(inviteCode, needSecret: true, needAuth: true);
    final resultModel = ApiResult.fromJson(json, (json) => InviteCodeModel.fromJson(json));
    return resultModel;
  }
}
