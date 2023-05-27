import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gpt_app/common/vip_charge.dart';
import 'package:gpt_app/grpc/grpc_net_header_status.dart';
import 'package:gpt_app/manager/chat_db_manager.dart';
import 'package:gpt_app/manager/message_db_manager.dart';
import 'package:gpt_app/module/chat/model/message_model.dart';
import 'package:gpt_app/module/chat/widget/input.dart';
import 'package:gpt_app/module/chat/widget/message.dart';
import 'package:gpt_app/grpc/grpc_net.dart';
import 'package:gpt_app/module/home/model/chat_history_model.dart';
import 'package:gpt_app/protos/generated/chatmessage.pb.dart';
import 'package:gpt_app/uitls/platform.dart';
import 'package:uuid/uuid.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class ChatPage extends StatefulWidget {
  ChatPage({super.key, this.chatModel, required this.userId, required this.newChatCallBack});
  ChatHistoryModel? chatModel;
  int userId;
  final Function(ChatHistoryModel chatModel) newChatCallBack;
  @override
  State<StatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  List<MessageModel> _messages = <MessageModel>[];
  final GlobalKey<InputState> _inputKey = GlobalKey();
  late Function(ChatHistoryModel chatModel) _newChatCallBack;
  late Input _input;
  final _messageWithScale = AppPlatform.isMobile ? 0.72 : 0.80;
  bool _isChatting = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _newChatCallBack = widget.newChatCallBack;
    _input = Input(
      onSendPressed: _handleSendPressed,
      key: _inputKey,
    );
    _input.isChating = false;
    refresh();
  }

  void refresh() async {
    final chatId = widget.chatModel?.id ?? "";
    _isChatting = false;
    _messages = <MessageModel>[];
    if (chatId.isNotEmpty) {
      final messageHistories = await MDBM.all(chatId);
      setState(() {
        _messages = messageHistories;
      });
    } else {
      setState(() {
        _messages = <MessageModel>[];
      });
    }
  }

  void streamHeaderCallback(GRPCNetHeaderStatus status, String message) {
    _input.isChating = false;
    if (status == GRPCNetHeaderStatus.freeOver) {
      if (_messages.isNotEmpty) {
        final replyMessage = _messages[0];
        if (replyMessage.chatId.isNotEmpty) {
          MDBM.delete(_messages[0]).then((value) => _messages.removeAt(0));
        }
      }
      VipCharge.showCharge(context, message);
    } else {
      EasyLoading.showToast(message);
    }
  }

  void streamCallback(bool isStarted, ChatMessageReply reply) {
    setState(() {
      if (isStarted) {
        final replyMessage = MessageModel.fromReply(reply, widget.chatModel?.id ?? "");
        _messages.insert(0, replyMessage);
      } else {
        final replyMessage = _messages.first;
        replyMessage.add(reply);
      }
      if (reply.finished) {
        _input.isChating = false;

        _isChatting = false;

        final replyMessage = _messages.first;
        if (_messages.length >= 2) {
          if (widget.chatModel == null) {
            if (replyMessage.content.isNotEmpty) {
              final chatId = const Uuid().v1();
              String chatName = replyMessage.content;
              if (chatName.length > 10) {
                chatName = chatName.substring(0, 10);
              }
              final chatModel = ChatHistoryModel(chatId, chatName, DateTime.now(), widget.userId);
              widget.chatModel = chatModel;
              _newChatCallBack(chatModel);
              CDBM.insert(chatModel);
              for (var message in _messages) {
                message.chatId = chatId;
                MDBM.insert(message);
              }
            } else {
              _messages.removeAt(0);
            }
          } else {
            MDBM.insert(replyMessage);
          }
        }
      }

      if (_input.isChating && !isStarted && reply.message.isEmpty) {
        _input.isChating = false;
      }
      if (!_input.isChating) {
        _inputKey.currentState?.updateSendState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Column(children: [
        Flexible(
            child: LayoutBuilder(
          builder: (
            BuildContext context,
            BoxConstraints constraints,
          ) =>
              GestureDetector(
            onTap: () {
              if (AppPlatform.isMobile) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
              reverse: true,
              slivers: [
                if (_isChatting)
                  SliverToBoxAdapter(
                      child: Row(
                    children: [
                      const Padding(padding: EdgeInsets.only(left: 34)),
                      Lottie.asset(
                        'assets/json/chatting.json',
                        width: 30,
                        height: 30,
                      ),
                    ],
                  )),
                SliverPadding(
                    padding: const EdgeInsets.only(bottom: 4),
                    sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                            (context, index) => Message(_messages[index], _messageWithScale),
                            childCount: _messages.length))),
                SliverPadding(
                  padding: EdgeInsets.only(top: 16 + MediaQuery.of(context).padding.top),
                )
              ],
            ),
          ),
        )),
        _input
      ]),
    );
  }

  Future<void> rpcSendMessage(String user) async {
    final sendMessages = <Map<String, dynamic>>[];
    final maxLength = _messages.length <= 10 ? _messages.length : 10;
    for (var i = maxLength - 1; i >= 0; i--) {
      sendMessages.add(_messages[i].toJson());
    }
    final messageString = json.encode(sendMessages);
    _input.isChating = true;
    GRPCNet.shared.request(
      user,
      messageString,
      streamHeaderCallback,
      streamCallback,
    );
  }

  void _handleSendPressed(String message) {
    final chatId = widget.chatModel?.id ?? "";
    final sendMessage = MessageModel.fromSend(message, chatId);
    if (chatId.isNotEmpty) {
      MDBM.insert(sendMessage);
    }
    setState(() {
      _isChatting = true;
      _messages.insert(0, sendMessage);
    });
    final chatPrompt = 'id-${widget.userId}';
    rpcSendMessage(chatPrompt);
  }

// Future<void> rpcSendMessage(String user) async {
//     final sendMessages = <Map<String, dynamic>>[];
//     sendMessages.add({'id': user, "message": ""});
//     GRPCNet.shared.request(user, json.encode(sendMessages), (x, y) {});
//   }
  // void _handleSendPressed(String message) {
  //   for (var i = 0; i < 240; i++) {
  //     rpcSendMessage('$i');
  //   }
  // }
}
