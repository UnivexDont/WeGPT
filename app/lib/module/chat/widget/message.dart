import 'package:flutter/material.dart';
import 'package:gpt_app/module/chat/model/message_model.dart';
import 'package:gpt_app/theme/gpt_app_theme.dart';
import 'package:gpt_app/theme/theme_colors.dart';
import 'package:gpt_app/uitls/device.dart';
import 'package:markdown_widget/widget/markdown.dart';

enum BubbleRtlAlignment {
  left,
  right,
}

class Message extends StatelessWidget {
  const Message(this.messageModel, this.widthScale, {super.key});
  final MessageModel messageModel;
  final double widthScale;

  @override
  Widget build(BuildContext context) {
    final bubbleRtlAlignment = messageModel.role == 1 ? BubbleRtlAlignment.left : BubbleRtlAlignment.right;
    const messageBorderRadius = 10.0;
    final borderRadius = bubbleRtlAlignment == BubbleRtlAlignment.left
        ? const BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(
              messageBorderRadius,
            ),
            bottomStart: Radius.circular(
              messageBorderRadius,
            ),
            topEnd: Radius.circular(messageBorderRadius),
            topStart: Radius.circular(messageBorderRadius),
          )
        : const BorderRadius.only(
            bottomLeft: Radius.circular(
              messageBorderRadius,
            ),
            bottomRight: Radius.circular(
              messageBorderRadius,
            ),
            topLeft: Radius.circular(messageBorderRadius),
            topRight: Radius.circular(messageBorderRadius),
          );
    final messageWidth = (Device.width * widthScale).floor();

    final avatarText = bubbleRtlAlignment == BubbleRtlAlignment.left ? 'GPT' : 'ME';
    return Container(
        alignment:
            bubbleRtlAlignment == BubbleRtlAlignment.left ? AlignmentDirectional.centerStart : Alignment.centerRight,
        margin: bubbleRtlAlignment == BubbleRtlAlignment.left
            ? const EdgeInsetsDirectional.only(
                bottom: 10,
                end: 10,
                start: 10,
              )
            : const EdgeInsets.only(
                bottom: 10,
                left: 20,
                right: 10,
              ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            textDirection: bubbleRtlAlignment == BubbleRtlAlignment.left ? TextDirection.ltr : TextDirection.rtl,
            children: [
              _avatarBuilder(context, avatarText, bubbleRtlAlignment),
              const Padding(padding: EdgeInsets.only(left: 10)),
              ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: messageWidth.toDouble(),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    _bubbleBuilder(context, borderRadius.resolve(Directionality.of(context)), bubbleRtlAlignment)
                  ])),
            ]));
  }

  Widget _avatarBuilder(BuildContext context, String avatarText, BubbleRtlAlignment alignment) => Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: alignment == BubbleRtlAlignment.left ? const Color(0xFF0BA37F) : const Color(0xFF2A99CF),
        ),
        alignment: Alignment.center,
        child: Text(
          avatarText,
          style: const TextStyle(color: Colors.white),
        ),
      );

  Widget _bubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    BubbleRtlAlignment alignment,
  ) {
    final isDark = GPTAppTheme.globalTheme.mode == GPTAppThemeMode.dark;
    final isLeft = alignment == BubbleRtlAlignment.left;
    final color =
        isDark ? (isLeft ? darkBubbleColor : rDarkBubbleColor) : (isLeft ? lightBubbleColor : rLightBubbleColor);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: isLeft
            ? MarkdownWidget(
                padding: const EdgeInsets.all(0),
                data: messageModel.content,
                config: GPTAppTheme.globalTheme.markdownConfig,
                shrinkWrap: true,
              )
            : Text(
                messageModel.content,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
      ),
    );
  }
}
