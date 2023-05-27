///
//  Generated code. Do not modify.
//  source: chatmessage.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'chatmessage.pb.dart' as $0;
export 'chatmessage.pb.dart';

class ChatMessagerClient extends $grpc.Client {
  static final _$sendMessage =
      $grpc.ClientMethod<$0.ChatMessageRequest, $0.ChatMessageReply>(
          '/chatmessage.ChatMessager/SendMessage',
          ($0.ChatMessageRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ChatMessageReply.fromBuffer(value));

  ChatMessagerClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseStream<$0.ChatMessageReply> sendMessage(
      $0.ChatMessageRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$sendMessage, $async.Stream.fromIterable([request]),
        options: options);
  }
}

abstract class ChatMessagerServiceBase extends $grpc.Service {
  $core.String get $name => 'chatmessage.ChatMessager';

  ChatMessagerServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ChatMessageRequest, $0.ChatMessageReply>(
        'SendMessage',
        sendMessage_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.ChatMessageRequest.fromBuffer(value),
        ($0.ChatMessageReply value) => value.writeToBuffer()));
  }

  $async.Stream<$0.ChatMessageReply> sendMessage_Pre($grpc.ServiceCall call,
      $async.Future<$0.ChatMessageRequest> request) async* {
    yield* sendMessage(call, await request);
  }

  $async.Stream<$0.ChatMessageReply> sendMessage(
      $grpc.ServiceCall call, $0.ChatMessageRequest request);
}
