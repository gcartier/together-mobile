import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/MessageModel.dart';
import '../models/PeopleModel.dart';
import 'ColorConstants.dart';

MessageType toType = MessageType.GATHERING;

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
  ScrollController scrollController = ScrollController();

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
                              color: ColorConstants.highlightColor)
                          : TextStyle(
                              fontSize: 16.0,
                              color: ColorConstants.primaryColor)),
                  TextSpan(
                    text: message.content,
                    style: TextStyle(
                        fontSize: 16.0, color: ColorConstants.primaryColor),
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
                    style: TextStyle(fontSize: 16.0, color: Colors.amber))));
        break;
      default:
        return Text("unknown msg: ${message.messageType}");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _items = <Widget>[];

    for (int i = 0; i < messageModel.messages.length; i++) {
      Message message = messageModel.messages[i];
      if (message.messageType == MessageType.WHISPER) {
        _items.add(
          Material(
            color: ColorConstants.peopleBGColor,
            child: InkWell(
                onTap: () {
                  print("message tapped");
                  message.sender?.personClicked();
                },
                child: _buildRow(message)),
          ),
        );
      } else {
        _items.add(_buildRow(message));
      }
    }

    return ListView(children: _items);

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
  String createToLabel() {
    dynamic? lastClicked = peopleModel.lastClicked;
    if (lastClicked == null) {
      toType = MessageType.GATHERING;
      return "Whisper to the Gathering";
    }
    if (lastClicked is Person) {
      toType = MessageType.WHISPER;
      return "Whisper to ${lastClicked.name}";
    }
    if (lastClicked is Group) {
      if (lastClicked.groupType != GroupType.GROUPLESS) {
        toType = MessageType.GROUP;
        return "Whisper to my group";
      }
    }
    toType = MessageType.GATHERING;
    return "Whisper to the Gathering";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      createToLabel(),
      style: TextStyle(fontSize: 18.0, color: ColorConstants.primaryColor),
    );
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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
        Expanded(
            child: TextField(
          maxLines: 3,
          controller: _controller,
          decoration: InputDecoration(
              hintStyle: TextStyle(fontStyle: FontStyle.italic),
              border: InputBorder.none,
              hintText: 'Tap to compose a message'),
          style: TextStyle(color: ColorConstants.highlightColor),
        )),
        IconButton(
            icon: Icon(Icons.send),
            color: ColorConstants.highlightColor,
            onPressed: () {
              String message = _controller.text;
              if (message != null) {
                messageModel.sendTextMessage(
                    message, peopleModel.lastClicked, toType);
              }
              ;
            }),
      ]),
    );
  }
}
