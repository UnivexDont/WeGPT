import 'package:dio/dio.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:gpt_app/manager/user_manager.dart';
import 'package:gpt_app/net/api_request.dart';
import 'package:gpt_app/manager/logger_manager.dart';

class MosoexpInterceptors extends Interceptor {
  static String? token;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final queryParameters = options.queryParameters;
    final needAuth = queryParameters['needAuth'];
    final needSecret = queryParameters['needSecret'];
    if (needAuth) {
      if (token == null) {
        final loginInfo = await UserManager.getUserInfo();
        token = loginInfo?.token;
      }
      options.headers['Authorization'] = 'Bearer $token';
    }
    if (needSecret) {
      final time = ApiRequset.serverTime + DateTime.now().difference(ApiRequset.startTime).inMilliseconds / 1000;
      String secreKey;
      final jwt = JWT({'time': time, 'appKey': 'wegpt-chat-bot'}, header: {'typ': 'JWT'});
      secreKey = jwt.sign(SecretKey('wegpt-chat-ai-secret'));
      options.headers['SecretKey'] = 'Buller $secreKey';
    }
    queryParameters.remove('needAuth');
    queryParameters.remove('needSecret');
    if (options.method == 'POST') {
      FormData formData = FormData.fromMap(queryParameters);
      options.data = formData;
      options.queryParameters = {};
    } else {
      options.queryParameters = queryParameters;
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('PATH: ${response.requestOptions.path} ===> Reuslt[$response]');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    logger.e('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\n$err');
    if (err.response?.statusCode == 404 || err.response?.statusCode == 500) {
      final data = {'data': Null, 'message': err.toString(), 'status': err.response?.statusCode, 'code': ''};
      err.response?.data = data;
    }
    super.onError(err, handler);
  }
}
