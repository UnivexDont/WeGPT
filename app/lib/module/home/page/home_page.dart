import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gpt_app/common/api/api_common_manager.dart';
import 'package:gpt_app/manager/chat_db_manager.dart';
import 'package:gpt_app/manager/share_preferences_manager.dart';
import 'package:gpt_app/module/chat/page/chat_page.dart';
import 'package:gpt_app/module/home/model/chat_history_model.dart';
import 'package:gpt_app/module/home/model/invite_code_model.dart';
import 'package:gpt_app/module/home/widget/drawer_extension.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GPTHomePage extends StatefulWidget {
  const GPTHomePage({super.key, required this.userId});
  final int userId;

  @override
  State<GPTHomePage> createState() => GPTHomePageState();
}

class GPTHomePageState extends State<GPTHomePage> {
  ChatHistoryModel? selectedChat;
  bool switchValue = false;
  final GlobalKey<ChatPageState> _chatKey = GlobalKey();

  List<ChatHistoryModel> chatHistories = <ChatHistoryModel>[];
  late ChatPage _chatPage;
  InviteCodeModel? inviteCodeModel;
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ACM.fetchInviteCode().then((value) {
      if (value.success) {
        setState(() {
          inviteCodeModel = value.data;
        });
      }
    });
    _chatPage = ChatPage(
        key: _chatKey,
        chatModel: selectedChat,
        userId: widget.userId,
        newChatCallBack: (chatModel) {
          setState(() {
            selectedChat = chatModel;
          });
          _chatPage.chatModel = chatModel;
          SPM.setChatIndex(0);
        });
    SPM.getChatIndex().then((value) {
      CDBM.allChats(widget.userId).then((chats) {
        setState(() {
          chatHistories.clear();
          for (final chat in chats) {
            if (chat.userId == widget.userId) {
              chatHistories.add(chat);
            }
          }
          if (value == -1) {
            selectedChat = null;
          } else {
            if (value < chatHistories.length && value >= 0) {
              selectedChat = chatHistories[value];
            }
          }
        });
        _chatPage.chatModel = selectedChat;
        _chatKey.currentState?.refresh();
      });
    });
  }

  void refreshChatPage(ChatHistoryModel? chatModel) {
    setState(() {
      selectedChat = chatModel;
    });
    _chatPage.chatModel = chatModel;
    _chatKey.currentState?.refresh();
  }

  void refresh() {
    CDBM.allChats(widget.userId).then((chats) {
      setState(() {
        chatHistories = chats;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(selectedChat?.name ?? "GPT 新对话"),
      ),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          refresh();
        }
      },
      drawer: Drawer(
          width: 200,
          backgroundColor: const Color(0xFF202123),
          child: Column(
            children: [
              if (!Platform.isIOS && !Platform.isAndroid) const Padding(padding: EdgeInsets.only(bottom: 15)),
              buildDrawerTop(context, textStyle),
              const Padding(padding: EdgeInsets.only(bottom: 15)),
              _buildChatHistory(textStyle),
              buildInviteCode(),
              const Divider(
                thickness: 0.5,
                height: 0.5,
                color: Colors.white,
              ),
              const Padding(padding: EdgeInsets.only(bottom: 15)),
              buildDrawerBottom(textStyle),
              const Padding(padding: EdgeInsets.only(bottom: 15)),
            ],
          )),
      body: _chatPage,
    );
  }

  Widget _buildChatHistory(TextStyle textStyle) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: chatHistories.length,
        itemBuilder: (context, index) {
          final chatHistoryModel = chatHistories[index];
          bool isSelected = chatHistoryModel.id == selectedChat?.id;
          return Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  color: isSelected ? const Color(0xFF444444) : Colors.transparent),
              child: InkWell(
                  onTap: () {
                    setState(() {
                      refreshChatPage(chatHistoryModel);
                      SPM.setChatIndex(index);
                      Navigator.pop(context);
                    });
                  },
                  child: Row(
                    children: [
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Icon(
                        isSelected ? Icons.mark_chat_unread_outlined : Icons.chat_bubble_outline_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Expanded(
                          child: Text(
                        chatHistoryModel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle,
                      )),
                      const Padding(padding: EdgeInsets.only(left: 8)),
                      if (isSelected) editPopupMenu(chatHistoryModel),
                      if (isSelected)
                        SizedBox(
                          width: 30,
                          child: IconButton(
                              iconSize: 20,
                              onPressed: () {
                                setState(() {
                                  int chatIndex = -1;
                                  if (index > 0) {
                                    selectedChat = chatHistories[index - 1];
                                    chatIndex = index - 1;
                                  } else if (index + 1 < chatHistories.length) {
                                    selectedChat = chatHistories[index + 1];
                                    chatIndex = index + 1;
                                  } else {
                                    selectedChat = null;
                                  }
                                  SPM.setChatIndex(chatIndex);
                                  CDBM.delete(chatHistoryModel).then((value) {
                                    chatHistories.removeAt(index);
                                    refresh();
                                    refreshChatPage(selectedChat);
                                  });
                                });
                              },
                              icon: const Icon(
                                CupertinoIcons.delete,
                                size: 18,
                                color: Colors.white,
                              )),
                        ),
                    ],
                  )),
            ),
          );
        },
      ),
    );
  }
}
