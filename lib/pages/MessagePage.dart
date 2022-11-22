import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/MessageModel.dart';
import '../models/PeopleModel.dart';
import 'ColorConstants.dart';

MessageType toType = MessageType.GATHERING;
ScrollController scrollController = ScrollController();

//
/// Messages
//

class Messages extends StatefulWidget {
  @override
  MessagesState createState() {
    return MessagesState();
  }
}

//
/// MessagesState
//

class MessagesState extends State<Messages> {
  void _scrollDown(dynamic context) {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  Widget _buildRow(Message message) {
    switch (message.messageType) {
      case MessageType.INVITE:
        return ListTile(
            title: RichText(
                text: TextSpan(
                  text: "You invited ${message.recipient?.name}",
                  style: DefaultTextStyle.of(context).style,
                )));
        break;
      case MessageType.WHISPER:
      case MessageType.GROUP:
      case MessageType.GATHERING:
      // assert(message.sender != null);
        String sender = message.sender?.name ?? "NULL";
        return ListTile(
          title: RichText(
            text: TextSpan(
                text: "",
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                      text: "${sender}: ",
                      style: (message.messageType == MessageType.WHISPER)
                          ? TextStyle(
                          fontSize: 16.0,
                          color: ColorConstants.whisperMessageColor)
                          : TextStyle(
                          fontSize: 16.0,
                          color: ColorConstants.gatheringMessageColor)),
                  TextSpan(
                    text: message.content,
                    style: TextStyle(
                        fontSize: 16.0, color: ColorConstants.messageContentColor),
                  )
                ]),
          ),
        );
        break;
      case MessageType.SERVER:
        return ListTile(
            title: RichText(
                text: TextSpan(
                    text: message.content,
                    style: TextStyle(fontSize: 16.0, color: ColorConstants.serverMessageColor))));
        break;
      default:
        return Text("unknown msg: ${message.messageType}");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _items = <Widget>[];

    Future.delayed(Duration.zero, () {
      bool hasFocus = textFocusNode.hasFocus;
      _scrollDown(context);
      if (hasFocus) {
        textFocusNode.requestFocus();
      }
    });
    for (int i = 0; i < messageModel.messages.length; i++) {
      Message message = messageModel.messages[i];
      if (message.messageType == MessageType.WHISPER) {
        _items.add(
          Material(
            color: ColorConstants.peopleBGColor,
            child: InkWell(
                onTap: () {
                  message.sender?.personClicked();
                },
                child: _buildRow(message)),
          ),
        );
      } else {
        _items.add(_buildRow(message));
      }
    }
    return ListView(controller: scrollController, children: _items);

    /*.builder(
        controller: scrollController,
        itemCount: messageModel.messages.length,
        itemBuilder: (context, index) {
          return _items[index];
        });*/

    // return list;
  }
}

//
/// WhisperTo
//

class WhisperTo extends StatefulWidget {
  @override
  State<WhisperTo> createState() {
    return WhisperToState();
  }
}

//
/// WhisperToState
//

class WhisperToState extends State<WhisperTo> {
  Widget buildToGathering() {
    toType = MessageType.GATHERING;
    return RichText(
        text: TextSpan(
            text: "Say to ",
            style: TextStyle(fontSize: 18.0, color: ColorConstants.ochreColor),
            children: [
              TextSpan(
                text: "The gathering",
                style: TextStyle(fontSize: 18.0, color: ColorConstants.gatheringColor),
              )
            ]
        )
    );
  }

  Widget buildToPerson(String name) {
    toType = MessageType.WHISPER;
    return RichText(
        text: TextSpan(
            text: "Whisper to ",
            style: TextStyle(fontSize: 18.0, color: ColorConstants.ochreColor),
            children: [
              TextSpan(
                text: name,
                style: TextStyle(fontSize: 18.0, color: ColorConstants.observerColor),
              )
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final lastClicked = peopleModel.lastClicked;
    if (lastClicked == null) {
      return buildToGathering();
    } else if (lastClicked is Person) {
      return buildToPerson(lastClicked.name);
    }
    else {
      return buildToGathering();
    }
  }
}

//
/// SendMessage
//

class SendMessage extends StatefulWidget {
  @override
  State<SendMessage> createState() {
    return SendMessageState();
  }
}

//
/// SendMessageState
//

class SendMessageState extends State<SendMessage> {
  late TextEditingController _controller;
  late TextField _textField;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    textFocusNode = FocusNode(onKeyEvent: eventResult);
    _textField = TextField(
        focusNode: textFocusNode,
        maxLines: 2,
        controller: _controller,
        decoration: InputDecoration(
            hintStyle: TextStyle(fontStyle: FontStyle.italic),
            border: InputBorder.none,
            hintText: 'Tap to compose a message'),
        style: TextStyle(color: ColorConstants.messageContentColor),
        cursorColor: ColorConstants.messageContentColor
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      height: 100,
      decoration: BoxDecoration(
        color: ColorConstants.peopleBGColor,
      ),
      child: Row(children: <Widget>[
        Expanded(child: _textField),
        IconButton(
            icon: Icon(Icons.send),
            color: ColorConstants.highlightColor,
            onPressed: () {
              submitText(_controller.text);
              textFocusNode.requestFocus();
            }),
      ]),
    );
  }

  KeyEventResult eventResult(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      submitText(_controller.text);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  submitText(String? message) {
    if ((message != null) && (!message.isEmpty)) {
      messageModel.sendTextMessage(message, peopleModel.lastClicked, toType);
      _controller.clear();
    }
    ;
  }
}
