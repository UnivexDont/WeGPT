import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gpt_app/common/api/api_common_manager.dart';
import 'package:gpt_app/manager/chat_db_manager.dart';
import 'package:gpt_app/manager/home_pointer_manager.dart';
import 'package:gpt_app/manager/message_db_manager.dart';
import 'package:gpt_app/manager/share_preferences_manager.dart';
import 'package:gpt_app/module/home/model/chat_history_model.dart';
import 'package:gpt_app/module/home/page/home_page.dart';
import 'package:gpt_app/module/profile/profile_page.dart';
import 'package:gpt_app/theme/gpt_app_theme.dart';
import 'package:gpt_app/theme/theme_colors.dart';

extension HomePageStateExtension on GPTHomePageState {
  Widget buildDrawerTop(BuildContext context, TextStyle textStyle) {
    const lrPadding = Padding(padding: EdgeInsets.only(left: 10));
    return SafeArea(
        bottom: false,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        inviteCodeModel: inviteCodeModel,
                      ),
                    ));
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
                child: Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color(0xFF2A99CF),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "ME",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    const Text("个人中心", style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_right, color: Colors.white)
                  ],
                ),
              ),
            ),
            const Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.white,
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            Row(
              children: [
                lrPadding,
                Expanded(
                    child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: Colors.white),
                      borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                  child: TextButton(
                    child: Row(
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 5)),
                        const Icon(
                          CupertinoIcons.add,
                          color: Colors.white,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 5)),
                        Text(
                          '新对话',
                          style: textStyle,
                        ),
                      ],
                    ),
                    onPressed: () {
                      refreshChatPage(null);
                      SPM.setChatIndex(-1);
                      Navigator.pop(context);
                    },
                  ),
                )),
                lrPadding,
              ],
            )
          ],
        ));
  }

  Widget buildDrawerBottom(TextStyle textStyle) {
    const lrPadding = Padding(padding: EdgeInsets.only(left: 10));
    return SafeArea(
        top: false,
        child: Column(
          children: [
            InkWell(
              onTap: () => deleteAllChats(),
              child: SizedBox(
                height: 35,
                child: Row(
                  children: [
                    lrPadding,
                    const Icon(
                      CupertinoIcons.delete,
                      color: Colors.white,
                    ),
                    lrPadding,
                    Text(
                      '删除所有对话',
                      style: textStyle,
                    ),
                    lrPadding,
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => settingAction(),
              child: SizedBox(
                height: 35,
                child: Row(
                  children: [
                    lrPadding,
                    const Icon(
                      CupertinoIcons.settings,
                      color: Colors.white,
                    ),
                    lrPadding,
                    Text(
                      '设置',
                      style: textStyle,
                    ),
                    lrPadding,
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () => logout(),
              child: SizedBox(
                height: 35,
                child: Row(
                  children: [
                    lrPadding,
                    const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    lrPadding,
                    Text(
                      '退出登录',
                      style: textStyle,
                    ),
                    lrPadding,
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget buildInviteCode() {
    final inviteCode = inviteCodeModel?.code ?? "";
    final haveCode = inviteCode.isNotEmpty;

    return Column(
      children: [
        const Divider(
          thickness: 0.5,
          height: 0.5,
          color: Colors.white,
        ),
        const Padding(padding: EdgeInsets.only(top: 5)),
        Row(
          children: [
            const Padding(padding: EdgeInsets.only(left: 12)),
            const Icon(
              Icons.qr_code_2_outlined,
              color: Colors.white,
            ),
            haveCode
                ? const Text(
                    "邀请码:",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      ACM.generateInvite().then((value) {
                        if (value.success) {
                          // ignore: invalid_use_of_protected_member
                          setState(() {
                            inviteCodeModel = value.data;
                          });
                        }
                      });
                    },
                    child: Row(
                      children: const [
                        Text(
                          "点击生成邀请码",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(Icons.swipe_up_outlined, color: Colors.white)
                      ],
                    ))
          ],
        ),
        if (haveCode)
          Row(
            children: [
              const Padding(padding: EdgeInsets.only(left: 12)),
              Text(
                inviteCode,
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: inviteCode));
                    EasyLoading.showToast("邀请码已复制");
                  },
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.white,
                  ))
            ],
          ),
        Padding(padding: EdgeInsets.only(bottom: haveCode ? 0 : 5)),
      ],
    );
  }

  Widget editPopupMenu(ChatHistoryModel chatHistoryModel) {
    String chatName = chatHistoryModel.name;
    const border = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 0.5),
    );
    return PopupMenuButton(
      color: const Color(0xFF202123),
      icon: const Icon(
        Icons.border_color_outlined,
        size: 18,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
              padding: const EdgeInsets.only(left: 15, right: 10),
              onTap: () {
                // ignore: invalid_use_of_protected_member
                setState(() {
                  chatHistoryModel.name = chatName;
                });
                CDBM.update(chatHistoryModel);
              },
              textStyle: const TextStyle(color: Colors.white),
              child: SizedBox(
                width: 180,
                child: Row(
                  children: [
                    SizedBox(
                        width: 150,
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            hintText: '输入对话的名字',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: border,
                            enabledBorder: border,
                            disabledBorder: border,
                            focusedBorder: border,
                          ),
                          onChanged: (value) {
                            // ignore: invalid_use_of_protected_member
                            setState(() {
                              chatName = value;
                            });
                          },
                          controller: TextEditingController(text: chatName),
                        )),
                    SizedBox(
                      width: 30,
                      child: IconButton(
                          onPressed: () {
                            // ignore: invalid_use_of_protected_member
                            setState(() {
                              chatHistoryModel.name = chatName;
                            });
                            CDBM.update(chatHistoryModel);
                            Future.delayed(const Duration(milliseconds: 382));
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.download_done_outlined,
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
              ))
        ];
      },
    );
  }

  void settingAction() {
    switchValue = GPTAppTheme.globalTheme.mode == GPTAppThemeMode.dark;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('设置'),
          content: Row(
            children: [
              const Spacer(),
              const Text('暗黑模式：'),
              CupertinoSwitch(
                  value: switchValue,
                  onChanged: (value) {
                    // ignore: invalid_use_of_protected_member
                    setState(() {
                      switchValue = value;
                      GPTAppTheme.globalTheme.changeMode(switchValue ? GPTAppThemeMode.dark : GPTAppThemeMode.light);
                      refreshChatPage(selectedChat);
                    });
                  }),
              const Spacer(),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                "关闭",
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void logout() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: const Text("确定要退出登录吗？", style: TextStyle(color: themeBlue)),
          actions: [
            CupertinoDialogAction(
              child: const Text("取消", style: TextStyle(color: themeBlue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                "确认",
              ),
              onPressed: () {
                EasyLoading.show();
                ACM.logout().then((value) {
                  if (value.success) {
                    HPM.global.logout();
                  }
                  EasyLoading.dismiss();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteAllChats() async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: const Text("确定要删除所有的聊天记录吗？", style: TextStyle(color: themeBlue)),
          actions: [
            CupertinoDialogAction(
              child: const Text("取消", style: TextStyle(color: themeBlue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                "确认",
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                EasyLoading.show();
                CDBM.deleteAll(widget.userId);
                // ignore: invalid_use_of_protected_member
                setState(() {
                  selectedChat = null;
                  chatHistories = [];
                });
                refreshChatPage(null);
                MDBM.deleteAll();
                SPM.setChatIndex(-1);
                await Future.delayed(const Duration(milliseconds: 300));
                EasyLoading.dismiss();
              },
            ),
          ],
        );
      },
    );
  }
}
