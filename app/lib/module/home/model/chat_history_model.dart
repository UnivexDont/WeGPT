import 'package:hive_flutter/hive_flutter.dart';
part 'chat_history_model.g.dart';

@HiveType(typeId: 0)
class ChatHistoryModel {
  ChatHistoryModel(this.id, this.name, this.date, this.userId);
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final int userId;
}
