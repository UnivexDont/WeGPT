import 'package:gpt_app/protos/generated/chatmessage.pb.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'message_model.g.dart';

@HiveType(typeId: 1)
class MessageModel {
  MessageModel(
    this.id,
    this.chatId,
    this.content,
    this.role,
    this.date,
  );
  @HiveField(0)
  final String id;
  @HiveField(1)
  String chatId;
  @HiveField(2)
  String content;
  @HiveField(3)
  final int role;
  @HiveField(4)
  final DateTime date;

  void add(ChatMessageReply reply) {
    if (id == reply.id) {
      content = content + reply.message;
    }
  }

  factory MessageModel.fromReply(ChatMessageReply reply, String chatId) {
    String content = reply.message;
    String id = reply.id;
    return MessageModel(id, chatId, content, 1, DateTime.now());
  }

  factory MessageModel.fromReplyList(List<ChatMessageReply> replyList, String chatId) {
    String content = '';
    String id = '';
    for (final reply in replyList) {
      content = content + reply.message;
      id = reply.id;
    }
    return MessageModel(id, chatId, content, 1, DateTime.now());
  }

  factory MessageModel.fromSend(String content, String chatId) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    return MessageModel(id, chatId, content, 2, DateTime.now());
  }

  Map<String, dynamic> toJson() {
    String message = content;
    if (message.runes.length > 200) {
      if (message.length > 200) {
        message = message.substring(0, 200);
      } else {
        message = message.substring(0, message.length - (202 - message.length) ~/ 2);
      }
    }
    return {
      "id": id,
      "message": content,
    };
  }
}
