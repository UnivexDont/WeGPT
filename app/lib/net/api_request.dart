import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gpt_app/net/interceptors.dart';
import 'package:gpt_app/manager/logger_manager.dart';

typedef AR = ApiRequset;

enum Environment { dev, test, pro }

enum ApiRequsetMethod { get, post }

class ApiRequset {
  static const String _hostDev = 'http://192.168.1.23:3555';
  static const String _hostTest = 'http://192.168.1.23:3555';
  static const String _hostProd = 'https://api.mosoexp.com';
  static const Map<Environment, String> _hostMap = {
    Environment.dev: _hostDev,
    Environment.test: _hostTest,
    Environment.pro: _hostProd,
  };
  static String get host {
    return _hostMap[environment] ?? '';
  }

  static Environment environment = kReleaseMode ? Environment.pro : Environment.dev;
  static MosoexpInterceptors interceptors = MosoexpInterceptors();
  static DateTime startTime = DateTime.now();
  static double serverTime = DateTime.now().microsecondsSinceEpoch / 1000;
  static Dio _initDio() {
    final options = BaseOptions(
      baseUrl: _hostMap[environment]!,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    );
    final finalDio = Dio(options);
    finalDio.interceptors.add(interceptors);
    return finalDio;
  }

  static final Dio _dio = _initDio();

  static void syncServerTime() {
    startTime = DateTime.now();
    get('/sys/time').then((res) {
      if (res['status'] == 200) {
        serverTime = (res['data']['time']) * 1.0;
      } else {
        serverTime = DateTime.now().microsecondsSinceEpoch / 1000;
      }
      startTime = DateTime.now();
    });
  }

  static String handleRequsetPath(String path, Map<String, dynamic>? queryParameters) {
    String resPath = path;
    final paths = path.split('/:');
    List<String> removeKeys = [];
    if (paths.length <= 1) {
      return resPath;
    }
    paths.asMap().forEach((i, element) {
      if (i > 0) {
        if (element.endsWith('?')) {
          final replaceKey = element.replaceAll('?', '');
          if (queryParameters?.containsKey(replaceKey) ?? false) {
            removeKeys.add(replaceKey);

            if (queryParameters![replaceKey] is String) {
              resPath = resPath.replaceFirst(':$element', '${queryParameters[replaceKey]}');
            } else {
              final replaceElement = jsonEncode(queryParameters[replaceKey]);
              resPath = resPath.replaceFirst(':$element', replaceElement);
            }
          }
        } else {
          if (queryParameters?.containsKey(element) ?? false) {
            removeKeys.add(element);
            if (queryParameters![element] is String) {
              resPath = resPath.replaceFirst(':$element', '${queryParameters[element]}');
            } else {
              final replaceElement = jsonEncode(queryParameters[element]);
              resPath = resPath.replaceFirst(':$element', replaceElement);
            }
          } else {
            if (!kReleaseMode) {
              logger.e('$path==>缺少必要的路径参数:$element');
              assert(true);
            } else {
              logger.e('$path==>缺少必要的路径参数:$element');
            }
          }
        }
      }
    });
    if (removeKeys.isNotEmpty) {
      for (var element in removeKeys) {
        queryParameters?.remove(element);
      }
    }
    return resPath;
  }

  static Future request<T>(String path,
      {Map<String, dynamic>? parameters,
      CancelToken? cancelToken,
      ApiRequsetMethod method = ApiRequsetMethod.get,
      bool needAuth = false,
      bool needSecret = false}) async {
    try {
      // ignore: unrelated_type_equality_checks
      path = handleRequsetPath(path, parameters);
      parameters ??= <String, dynamic>{};
      parameters['needAuth'] = needAuth;
      parameters['needSecret'] = needSecret;
      Response<T> response;
      if (ApiRequsetMethod.get == method) {
        response = (await _dio.get<T>(path, queryParameters: parameters, cancelToken: cancelToken));
      } else {
        response = await _dio.post<T>(path, queryParameters: parameters, cancelToken: cancelToken);
      }
      final data = response.data;
      return data;
    } catch (e) {
      if (e.runtimeType == DioError) {
        final error = e as DioError;
        if (error.response?.data == null) {
          final data = {'data': null, 'message': error.toString(), 'status': -500, 'code': ''};
          return data;
        }
        return error.response?.data;
      } else {
        logger.e('不明错误$e');
        final data = {'data': null, 'message': e.toString(), 'status': -500, 'code': ''};
        return data;
      }
    }
  }

  static Future post(String path,
      {Map<String, dynamic>? parameters, bool needAuth = false, bool needSecret = false}) async {
    return request(path,
        method: ApiRequsetMethod.post, parameters: parameters, needAuth: needAuth, needSecret: needSecret);
  }

  static Future get(String path,
      {Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      bool needAuth = false,
      bool needSecret = false}) async {
    return request(path,
        cancelToken: cancelToken, parameters: queryParameters, needAuth: needAuth, needSecret: needSecret);
  }
}
