import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/solarized-light.dart';
import 'package:gpt_app/module/chat/widget/code_wrapper.dart';
import 'package:markdown_widget/config/configs.dart';
import 'package:markdown_widget/widget/blocks/leaf/code_block.dart';
import 'package:markdown_widget/widget/blocks/leaf/heading.dart';
import 'package:markdown_widget/widget/blocks/leaf/horizontal_rules.dart';
import 'package:markdown_widget/widget/blocks/leaf/paragraph.dart';
import 'package:markdown_widget/widget/inlines/code.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

MaterialColor white = const MaterialColor(
  0xFFFFFFFF,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);

MaterialColor black = const MaterialColor(
  0xFF000000,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(0xFF000000),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);

const Color cellLine = Color(0xFFCDCDCD);
const Color okBtnColor = Color(0xFFF22323);
const Color lightTitle = Color(0xFF363636);
const Color darkTitle = Color(0xFFE5E5E5);
const Color themeBlue = Color(0xFF0A84FF);

const Color rLightBubbleColor = Color(0xFF29B560);
const Color rDarkBubbleColor = Color(0xFF29B560);

const Color lightBubbleColor = Colors.white;
const Color darkBubbleColor = Color(0xFF2C2C2C);

Widget codeWrapper(Widget child, String text) {
  return CodeWrapperWidget(text: text, child: child);
}

MarkdownConfig darkConfig = MarkdownConfig(configs: [
  HrConfig.darkConfig,
  H1Config.darkConfig,
  H2Config.darkConfig,
  H3Config.darkConfig,
  H4Config.darkConfig,
  H5Config.darkConfig,
  H6Config.darkConfig,
  const PreConfig(
    decoration: BoxDecoration(
      color: Color(0xFF111111),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    theme: atomOneDarkTheme,
    wrapper: codeWrapper,
  ),
  PConfig.darkConfig,
  const CodeConfig(style: TextStyle(backgroundColor: Color(0xFF222222))),
]);

MarkdownConfig get lightConfig {
  return MarkdownConfig(configs: [
    const PreConfig(
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      theme: solarizedLightTheme,
      wrapper: codeWrapper,
    ),
    const CodeConfig(style: TextStyle(backgroundColor: Color(0xFFF2F2F2))),
  ]);
}

extension ThemeColor on Color {
  Color fromScale(double scale) {
    return Color.fromARGB(alpha, (red * scale).toInt(), (green * scale).toInt(), (blue * scale).toInt());
  }
}
