import 'package:gpt_app/module/chat/model/message_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

typedef MDBM = MessageDBManager;

class MessageDBManager {
  static const boxName = 'message_histories';
  static Future<void> initHive() async {
    final dbPath = await getApplicationDocumentsDirectory();
    await Hive.initFlutter('${dbPath.path}/message_history_db');
    Hive.registerAdapter(MessageModelAdapter());
  }

  static Future<List<MessageModel>> all(String chatId) async {
    final historyBox = await Hive.openBox<MessageModel>(boxName);
    final histories = historyBox.values.where((element) => element.chatId == chatId).toList();
    histories.sort((y, x) {
      return x.date.compareTo(y.date);
    });
    return histories.toList();
  }

  static Future<void> insert(MessageModel model) async {
    final historyBox = await Hive.openBox<MessageModel>(boxName);
    historyBox.add(model);
  }

  static Future<void> delete(MessageModel model) async {
    final historyBox = await Hive.openBox<MessageModel>(boxName);
    final deleteIndex = historyBox.values.toList().indexWhere((element) => element.id == model.id);
    if (deleteIndex >= 0) {
      historyBox.deleteAt(deleteIndex);
    }
  }

  static Future<void> deleteWithChat(String chatId) async {
    final historyBox = await Hive.openBox<MessageModel>(boxName);
    final deleteIndexs = historyBox.keys.where((key) => historyBox.get(key)?.chatId == chatId).toList();
    historyBox.deleteAll(deleteIndexs);
  }

  static Future<void> deleteAll() async {
    final historyBox = await Hive.openBox<MessageModel>(boxName);
    final deleteIndexs = historyBox.keys.toList();
    historyBox.deleteAll(deleteIndexs);
  }
}
