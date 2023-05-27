///
//  Generated code. Do not modify.
//  source: chatmessage.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use chatMessageRequestDescriptor instead')
const ChatMessageRequest$json = const {
  '1': 'ChatMessageRequest',
  '2': const [
    const {'1': 'user', '3': 1, '4': 1, '5': 9, '10': 'user'},
    const {'1': 'messages', '3': 2, '4': 1, '5': 12, '10': 'messages'},
  ],
};

/// Descriptor for `ChatMessageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageRequestDescriptor = $convert.base64Decode('ChJDaGF0TWVzc2FnZVJlcXVlc3QSEgoEdXNlchgBIAEoCVIEdXNlchIaCghtZXNzYWdlcxgCIAEoDFIIbWVzc2FnZXM=');
@$core.Deprecated('Use chatMessageReplyDescriptor instead')
const ChatMessageReply$json = const {
  '1': 'ChatMessageReply',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'finished', '3': 3, '4': 1, '5': 8, '10': 'finished'},
    const {'1': 'login', '3': 4, '4': 1, '5': 8, '10': 'login'},
  ],
};

/// Descriptor for `ChatMessageReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageReplyDescriptor = $convert.base64Decode('ChBDaGF0TWVzc2FnZVJlcGx5Eg4KAmlkGAEgASgJUgJpZBIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEhoKCGZpbmlzaGVkGAMgASgIUghmaW5pc2hlZBIUCgVsb2dpbhgEIAEoCFIFbG9naW4=');
