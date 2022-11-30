import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../settings.dart';
import '../main.dart';
import 'ChannelWrapper.dart';
import 'Data.dart';

// import 'SocketWrapper.dart';

class Connection extends ChangeNotifier {
  // bool isConnected;
  ChannelWrapper? _channelWrapper;
  late DataParser dataParser;
  String? _errorMessage;
  String? _completionError;

  String? get errorMessage {
    String? retVal = _completionError ?? _errorMessage;
    _completionError = null;
    return retVal;
  }

  set completionError(String? msg) {
    _completionError = msg;
  }

  set errorMessage(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  clearErrorMessage() {
    _completionError = null;
    _errorMessage = null;
  }

  Connection() {
    dataParser = DataParser();
  }

  bool get isConnected {
    if (_channelWrapper == null) {
      return false;
    }
    if (_channelWrapper!.isClosed()) {
      isConnected = false; // for clean-up and notify
      return false;
    }
    return true;
  }

  set isConnected(bool val) {
    if (val == false) {
      _channelWrapper?.destroy(); // TODO
      _channelWrapper = null;
    }
//    notifyListeners();
  }

  void sendDeconnect() {
    if (debugMobile)
      print("sending DECONNECT to server");
    if (!isConnected) {
      if (debugMobile)
        print("Deconnect called while already disconnected");
    } else {
      // messageModel.addDeconnect();
      dynamic sendJson = jsonEncode(["deconnect"]);
      notifyListeners();
      send(sendJson);
    }
  }

  // The future returned by this is complete when we receive
  // connect confirmation from the server
  Future<bool> connect([String? id]) async {
    Completer<bool> completer = Completer<bool>();
    if (id == null) {
      String? storedId = retrieveId();
    }
    if (id == null) {
      return Future.value(false);
    }
    dataParser.connectCompleter = completer;
    try {
      final channel =
      WebSocketChannel.connect(Uri.parse(togetherServer));

      _channelWrapper = ChannelWrapper(
          channel, id, dataParser.dataHandler, errorHandler, doneHandler);
    } catch (err) {
      errorMessage = "Connection refused";
      return Future.value(false);
    }
    clearErrorMessage();
    //return Future.value(true);
    return completer.future;
  }

  void send(String message) async {
    if (isConnected) {
      _channelWrapper?.write(message);
    } else {
      if (debugMobile)
        print("Error attempted to send to null socket: $message");
    }
  }

  get snackBarList {
    List<String>? retVal;
    if (isConnected) {
      retVal = dataParser?.snackBarList;
    }
  }

  void errorHandler(dynamic err) {
    if (debugMobile)
      print("error: $err");
    _errorMessage = err.message;
    isConnected = false;
    // FIXME
    // snackBarWidget.handleError();
  }

  // doneHandler(String? reason, int? code) {
  doneHandler() {
    _errorMessage = "Disconnected from server";
    isConnected = false;
  }
}
