import 'dart:async';
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gpt_app/grpc/grpc_net_header_status.dart';
import 'package:gpt_app/manager/home_pointer_manager.dart';
import 'package:gpt_app/net/api_request.dart';
import 'package:gpt_app/protos/generated/chatmessage.pbgrpc.dart';
import 'package:gpt_app/manager/logger_manager.dart';
import 'package:gpt_app/protos/generated/headermessage.pb.dart';
import 'package:grpc/grpc.dart';

import '../manager/user_manager.dart';

typedef StreamCallback = void Function(bool isStarted, ChatMessageReply reply);

typedef StreamHeaerCallback = void Function(GRPCNetHeaderStatus status, String message);

class GRPCNet {
  static String? token;
  static GRPCNet? _shared;

  static GRPCNet get shared {
    if (_shared == null) {
      _shared = GRPCNet();
      _shared!.isLogout = false;
    }
    return _shared!;
  }

  final channel = ClientChannel(
    '192.168.1.23',
    port: 55551,
    options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
  );
  bool isLogout = false;

  Future<void> request(String user, messages, StreamHeaerCallback heaerCallback, StreamCallback callback) async {
    final client = ChatMessagerClient(channel);
    try {
      List<int> messageBytes = utf8.encode(messages);

      final time = ApiRequset.serverTime + DateTime.now().difference(ApiRequset.startTime).inMilliseconds / 1000;
      String secreKey;
      final jwt = JWT({'time': time, 'appKey': 'wegpt-chat-bot'}, header: {'typ': 'JWT'});
      secreKey = jwt.sign(SecretKey('wegpt-chat-ai-secret'));
      if (token == null) {
        final loginInfo = await UserManager.getUserInfo();
        token = loginInfo?.token;
      }
      final metadata = {'Authorization': 'Bearer $token', 'SecretKey': 'Buller $secreKey'};
      final requestData = ChatMessageRequest()
        ..user = user
        ..messages = messageBytes;
      final streamResponse = client.sendMessage(requestData,
          options: CallOptions(timeout: const Duration(seconds: 1200), metadata: metadata));

      streamResponse.headers.then((headers) {
        final authenticationData = headers["authentication"];
        final authentication = base64.decode(authenticationData ?? "");
        final headerMessage = HeaderMessage.fromBuffer(authentication);
        final status = GRPCNetHeaderStatuser.fromRaw(headerMessage.status);
        if (status != GRPCNetHeaderStatus.success) {
          if (headerMessage.status == 1) {
            EasyLoading.showToast(headerMessage.message);
            HPM.global.logout();
            shudown();
            isLogout = true;
          } else {
            heaerCallback(status, headerMessage.message);
          }
        }
      });

      bool first = true;
      await for (var respose in streamResponse) {
        callback(first, respose);
        first = false;
      }
    } catch (e) {
      callback(false, ChatMessageReply(finished: true, id: '', message: ''));
      logger.d('Caught error: $e');
    }
  }

  Future<void> shudown() async {
    await channel.shutdown();
    _shared = null;
  }
}
