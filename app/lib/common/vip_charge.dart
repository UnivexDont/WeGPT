import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gpt_app/main.dart';

import 'package:gpt_app/theme/theme_colors.dart';

const serviceWXId = "1232323w";

class VipCharge {
  static void showCharge(BuildContext context, String content) {
    final context = navigatorKey.currentState!.context;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(content, style: const TextStyle(color: themeBlue)),
          content: Row(
            children: [
              const Spacer(),
              const Text("微信:$serviceWXId"),
              const Padding(padding: EdgeInsets.only(left: 10)),
              IconButton(
                  onPressed: () async {
                    await Clipboard.setData(const ClipboardData(text: serviceWXId));
                    EasyLoading.showToast("已成功复制");
                  },
                  icon: Icon(
                    Icons.copy,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                  )),
              const Spacer(),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                "确认",
                style: TextStyle(color: okBtnColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
