import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
///

// ignore: must_be_immutable
class Input extends StatefulWidget {
  /// Creates [Input] widget.
  Input({
    super.key,
    required this.onSendPressed,
    this.options = const InputOptions(),
  });

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.

  bool isChating = false;
  void setChating(bool chating) {
    isChating = chating;
  }

  final void Function(String) onSendPressed;

  /// Customisation options for the [Input].
  final InputOptions options;

  @override
  State<Input> createState() => InputState();
}

/// [Input] widget state.
class InputState extends State<Input> {
  late final _inputFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.physicalKeysPressed.any(
            (el) => <PhysicalKeyboardKey>{
              PhysicalKeyboardKey.shiftLeft,
              PhysicalKeyboardKey.shiftRight,
            }.contains(el),
          )) {
        if (event is KeyDownEvent) {
          _handleSendPressed();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  late bool _sendButtonVisible;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _sendButtonVisible = false;
    _textController = TextEditingController();
    _handleSendButtonVisibilityModeChange();
  }

  void updateSendState() {
    _handleTextControllerChange();
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleSendButtonVisibilityModeChange();
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _inputFocusNode.requestFocus(),
        child: _inputBuilder(),
      );

  void _handleSendButtonVisibilityModeChange() {
    _textController.removeListener(_handleTextControllerChange);
    _sendButtonVisible = _textController.text.trim() != '';
    _textController.addListener(_handleTextControllerChange);
  }

  void _handleSendPressed() {
    if (widget.isChating) return;
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      widget.onSendPressed(trimmedText);
      _textController.clear();
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      if (widget.isChating) {
        _sendButtonVisible = false;
      } else {
        _sendButtonVisible = _textController.text.trim() != '';
      }
    });
  }

  Widget _inputBuilder() {
    final query = MediaQuery.of(context);
    const buttonPadding = EdgeInsets.only(left: 16, right: 16);
    final safeAreaInsets = Platform.isAndroid || Platform.isIOS
        ? EdgeInsets.fromLTRB(
            query.padding.left,
            0,
            query.padding.right,
            query.viewInsets.bottom + query.padding.bottom,
          )
        : EdgeInsets.zero;
    final textPadding = const EdgeInsets.only(left: 0, right: 0).add(
      EdgeInsets.fromLTRB(
        10,
        15,
        _sendButtonVisible ? 0 : 24,
        0,
      ),
    );
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 0.5),
    );
    return Focus(
      autofocus: true,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Material(
          child: Container(
            padding: safeAreaInsets,
            child: Column(children: [
              const Divider(
                thickness: 0.5,
                height: 0.5,
                color: Colors.grey,
              ),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    child: Padding(
                      padding: textPadding,
                      child: TextField(
                        controller: _textController,
                        focusNode: _inputFocusNode,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10),
                          border: border,
                          enabledBorder: border,
                          disabledBorder: border,
                          focusedBorder: border,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        onChanged: widget.options.onTextChanged,
                        onTap: widget.options.onTextFieldTap,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: buttonPadding.bottom + buttonPadding.top + 24,
                    ),
                    child: Visibility(
                      visible: _sendButtonVisible,
                      child: IconButton(
                        onPressed: _handleSendPressed,
                        icon: const Icon(Icons.send),
                      ),
                    ),
                  ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}

@immutable
class InputOptions {
  const InputOptions({
    this.onTextChanged,
    this.onTextFieldTap,
    this.textEditingController,
  });

  /// Will be called whenever the text inside [TextField] changes.
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap.
  final VoidCallback? onTextFieldTap;

  /// Custom [TextEditingController]. If not provided, defaults to the
  /// [InputTextFieldController], which extends [TextEditingController] and has
  /// additional fatures like markdown support. If you want to keep additional
  /// features but still need some methods from the default [TextEditingController],
  /// you can create your own [InputTextFieldController] (imported from this lib)
  /// and pass it here.
  final TextEditingController? textEditingController;
}
