import 'package:gpt_app/module/home/model/chat_history_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

typedef CDBM = ChatDBManager;

class ChatDBManager {
  static const boxName = 'chat_histories';
  static Future<void> initHive() async {
    final dbPath = await getApplicationDocumentsDirectory();
    await Hive.initFlutter('${dbPath.path}/chat_history_db');
    Hive.registerAdapter(ChatHistoryModelAdapter());
  }

  static Future<void> close() async {
    await Hive.close();
  }

  static Future<List<ChatHistoryModel>> allChats(int userId) async {
    final historyBox = await Hive.openBox<ChatHistoryModel>(boxName);
    final histories = historyBox.values.where((element) => element.userId == userId).toList();
    histories.sort((x, y) {
      return y.date.compareTo(x.date);
    });
    return histories.toList();
  }

  static Future<void> insert(ChatHistoryModel model) async {
    final historyBox = await Hive.openBox<ChatHistoryModel>(boxName);
    historyBox.add(model);
  }

  static Future<void> delete(ChatHistoryModel model) async {
    final historyBox = await Hive.openBox<ChatHistoryModel>(boxName);
    final deleteIndex = historyBox.values.toList().indexWhere((element) => element.id == model.id);
    final key = historyBox.keyAt(deleteIndex);
    historyBox.delete(key);
  }

  static Future<void> deleteAll(int userId) async {
    final historyBox = await Hive.openBox<ChatHistoryModel>(boxName);
    List keys = [];
    for (final key in historyBox.keys) {
      final history = historyBox.get(key);
      if (history != null && history.userId == userId) {
        keys.add(key);
      }
    }
    historyBox.deleteAll(keys);
  }

  static Future<void> update(ChatHistoryModel model) async {
    final historyBox = await Hive.openBox<ChatHistoryModel>(boxName);
    final deleteIndex = historyBox.values.toList().indexWhere((element) => element.id == model.id);
    final key = historyBox.keyAt(deleteIndex);
    historyBox.put(key, model);
  }
}
