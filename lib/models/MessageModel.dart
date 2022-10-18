import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../connection/Data.dart';
import '../main.dart';
import 'PeopleModel.dart';

enum MessageType {
  NONE,
  WHISPER,
  GROUP,
  GATHERING,
  INVITE,
  SERVER,
}

class MessageModel extends ChangeNotifier {
  List<Message> messages = [];

  //PeopleModel peopleModel;
  String textMessage = "";
  MessageType toButtonState = MessageType.NONE;

  //String toButtonRecipient;

  // MessageModel(PeopleModel this.peopleModel) {
  //   this.peopleModel = peopleModel;
  //}

  get messageIterator {
    if (messages.isEmpty) {
      return null;
    }
    return messages.iterator;
  }

  //FIXME
  void somethingChanged(DataParser changeProvider) {
    if (changeProvider.messagesList.isNotEmpty) {
      buildMessages(changeProvider.messagesList);
      changeProvider.clearMessages();
      connection.notifyListeners();
    }
  }

  void addMessage(Message msg) {
    messages.add(msg);
    notifyListeners();
  }

  buildMessages(dynamic json) {
    for (int i = 0; i < json.length; i++) {
      addMessage(Message.fromJson(json[i]));
    }
  }

  void addServerMessage(MessageType type, String text) {
    addMessage(Message.fromServer(text));
  }

  void addDeconnect() {
    addMessage(Message.toServer("${peopleModel.me?.name} requested deconnect"));
  }

  // TODO move this to snackbar
  // also this is not a sender-recipient message
  void sendInvite(Person recipient) {
    Person? sender = peopleModel.me;
    String messageToSend = '["invite", "${recipient.name}"]';
    addMessage(Message(sender, recipient, MessageType.INVITE, textMessage));
    connection.send(messageToSend);
  }

  void sendTextMessage() {
    // textMessage is directly set by typing in text field
    if (textMessage.isNotEmpty) {
      String messageToSend;
      switch (toButtonState) {
        case MessageType.WHISPER:
          Person? recipient = peopleModel.lastClicked;
          assert(recipient != null);
          Person? sender = peopleModel.me;
          addMessage(
              Message(sender, recipient, MessageType.WHISPER, "$textMessage"));
          messageToSend =
              '["message", "whisper", "${recipient?.name}", "$textMessage"]';
          break;
        case MessageType.GROUP:
          messageToSend = '["message", "group", "false", "$textMessage"]';
          break;
        case MessageType.GATHERING:
        default:
          messageToSend = '["message", "gathering", "false", "$textMessage"]';
      }
      connection.send(messageToSend);
    } else {
      print("attempted to send empty text message");
    }
  }
}

class Message {
  Person? sender;
  Person? recipient;
  MessageType? messageType;
  String? content;

  Message(this.sender, this.recipient, this.messageType, this.content);

  Message.fromServer(this.content) {
    messageType = MessageType.SERVER;
  }

  Message.toServer(this.content) {
    messageType = MessageType.SERVER;
  }

  Message.fromJson(dynamic json) {
    assert(json[0] is String);
    sender = peopleModel.getDisplayedPerson(json[0]);
    if (json[1] is String) {
      switch (json[1]) {
        case "whisper":
          messageType = MessageType.WHISPER;
          break;
        case "group":
          messageType = MessageType.GROUP;
          break;
        case "gathering":
          messageType = MessageType.GATHERING;
          break;
      }
    }
    if (json[2] is String) content = json[2];
  }

  void messageClicked() {
    sender?.personClicked();
  }
}
