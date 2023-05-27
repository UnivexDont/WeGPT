import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

typedef SPM = SharedPreferencesManager;

class SharedPreferencesManager {
  static const thmeModeSaveKey = 'ThmeModeSaveKey';
  static const chatIndexSaveKey = 'ChatIndexSaveKey';

  static Future<bool> setMap(String key, Map<String, dynamic> map) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(map);
    return await prefs.setString(key, jsonString);
  }

  static Future<bool> setChatIndex(int value) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(chatIndexSaveKey, value);
  }

  static Future<int> getChatIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(chatIndexSaveKey) ?? -1;
  }

  static Future<Map<String, dynamic>> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);
    if (json != null) {
      return jsonDecode(json);
    }
    return {};
  }

  static Future<void> setListMap(String key, List<Map<String, dynamic>> listMap) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(listMap);
    await prefs.setString(key, jsonString);
  }

  static Future<List<Map<String, dynamic>>> getListMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);
    if (json != null) {
      return jsonDecode(json).cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  static Future<bool> setThemeMode(int value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setInt(thmeModeSaveKey, value);
  }

  static Future<int> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(thmeModeSaveKey) ?? 0;
  }
}
