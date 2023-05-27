import 'package:flutter/material.dart';
import 'package:gpt_app/manager/share_preferences_manager.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'theme_colors.dart';

enum GPTAppThemeMode { light, dark }

extension GPTAppThemeModeExt on GPTAppThemeMode {
  static GPTAppThemeMode fromRaw(int index) {
    if (1 == index) {
      return GPTAppThemeMode.dark;
    } else {
      return GPTAppThemeMode.light;
    }
  }
}

class GPTAppTheme with ChangeNotifier {
  static final GPTAppTheme globalTheme = GPTAppTheme();
  late ThemeMode themeMode;
  late GPTAppThemeMode mode = GPTAppThemeMode.light;
  GPTAppTheme() {
    SPM.getThemeMode().then(
      (value) {
        mode = GPTAppThemeModeExt.fromRaw(value);
        handleShowMode();
      },
    );
    handleShowMode();
  }

  void handleShowMode() {
    if (mode == GPTAppThemeMode.dark) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    primarySwatch: white,
    primaryColor: Colors.white,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  );

  static final ThemeData dark = ThemeData(
      useMaterial3: true,
      primaryColor: Colors.black,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111111));

  void changeMode(GPTAppThemeMode newMode) {
    SPM.setThemeMode(newMode.index);
    mode = newMode;
    handleShowMode();
  }

  static Color tagBackgroundColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.black87;
    }
    return Colors.grey[350] ?? Colors.grey;
  }

  MarkdownConfig get markdownConfig {
    final isDark = mode == GPTAppThemeMode.dark;
    return isDark ? darkConfig : lightConfig;
  }
}
