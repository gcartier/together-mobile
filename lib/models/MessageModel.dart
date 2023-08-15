import 'dart:convert';

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

//
/// MessageModel
//

class MessageModel extends ChangeNotifier {
  List<Message> messages = [];

  get messageIterator {
    if (messages.isEmpty) {
      return null;
    }
    return messages.iterator;
  }

  // FIXME
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
      Message decoded = Message.fromJson(json[i]);
      if (decoded.sender != null) {
        // meaning I didn't send it
        addMessage(decoded);
      }
    }
  }

  void addServerMessage(MessageType type, String text) {
    addMessage(Message.fromServer(text));
  }

  void addDeconnect() {
    addMessage(Message.toServer("${peopleModel.me?.memberName} requested deconnect"));
  }

  // TODO move this to snackbar
  // also this is not a sender-recipient message
  void sendInvite(Person recipient) {
    Person? sender = peopleModel.me;
    String messageToSend = '["invite", "${recipient.memberName}"]';
    addMessage(Message(sender, recipient, MessageType.INVITE, messageToSend));
    connection.send(messageToSend);
  }

  void sendTextMessage(String? message, dynamic recipient, MessageType type) {
    // textMessage is directly set by typing in text field
    String messageToSend;
    Person? sender = peopleModel.me;
    List elements = List<dynamic>.filled(4, null, growable: false);
    switch (type) {
      case MessageType.WHISPER:
        addMessage(Message(sender, recipient, MessageType.WHISPER, "$message"));
        elements.setAll(0, ["message", "whisper", "${recipient?.memberName}", "$message"]);
        break;
      case MessageType.GROUP:
        addMessage(Message(sender, recipient, MessageType.GROUP, "$message"));
        elements.setAll(0, ["message", "group", "false", "$message"]);
        break;
      case MessageType.GATHERING:
      default:
      // addMessage( this causes message to be seen twice by sender
      // Message(sender, recipient, MessageType.GATHERING, "$message"));
      elements.setAll(0, ["message", "gathering", "false", "$message"]);
    }
    connection.send(jsonEncode(elements));
  }
}

//
/// Message
//

class Message {
  Person? sender;
  dynamic? recipient;
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
}
