import 'dart:async';
import 'dart:convert';
//import 'dart:io';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../main.dart';
import 'Data.dart';
import 'ChannelWrapper.dart';

//import 'SocketWrapper.dart';

class Connection extends ChangeNotifier {
  //bool isConnected;
  ChannelWrapper? _channelWrapper;
  late DataParser dataParser;
  String? _errorMessage;

  String? get errorMessage {
    return _errorMessage;
  }

  set errorMessage(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  clearErrorMessage() {
    _errorMessage = "";
  }

  Connection(connectCompleted, connectFailed) {
    dataParser = DataParser(connectCompleted, connectFailed);
  }

  bool get isConnected {
    if (_channelWrapper != null) {
      return true;
    }
    return false;
  }

  set isConnected(bool val) {
    if (val == false) {
        _channelWrapper?.destroy();  //TODO
        _channelWrapper = null;
    }
    notifyListeners();
  }

  void sendDeconnect() {
    print("sending DECONNECT to server");
    if (!isConnected) {
      print("Deconnect called while already disconnected");
    } else {
      messageModel.addDeconnect();
      dynamic sendJson = jsonEncode(["deconnect"]);
      notifyListeners();
      send(sendJson);
    }
  }

  /// The future returned by this is complete when we receive
  /// connect confirmation from the server
  Future<bool> connect([String? id]) async {
    if (id == null) {
      String? storedId = retrieveId();
      print("1111 received connect Future");
    }
    if (id == null) {
      return Future.value(false);
    }
    print("Connect requested to $id");
    try {
// guillaume local      _socket = await Socket.connect('24.157.138.91', 50950);
      // _socket = await Socket.connect('togethersphere.com', 50050); // devel
      // _socket = await Socket.connect('192.168.1.104', 50050); // local devel
/*
      final channel = WebSocketChannel.connect(
        Uri.parse('wss://echo.websocket.events'),
      );*/
      final channel = WebSocketChannel.connect(
          Uri.parse('wss://togethersphere.com:50350'));

      //final _socket
      //    await Socket.connect('togethersphere.com', 50350); // stable

      _channelWrapper = ChannelWrapper(
          channel, id, dataParser.dataHandler, errorHandler, doneHandler);
    } catch (err) {
      print("2222 $err");
      errorMessage = "Connection refused";
      return Future.value(false);
    }
    clearErrorMessage();
    return Future.value(true);
  }

  void send(String message) async {
    if (isConnected) {
      print("1111 Sending $message");
      _channelWrapper?.write(message);
    } else {
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
    print("error: $err");
    _errorMessage = err.message;
    isConnected = false;
    //FIXME
    //snackBarWidget.handleError();
  }

  doneHandler() async {
    print (">>>>>>>>>>Received Channel Done");
    if (isConnected) {
      await (_channelWrapper?.close());
    }
    isConnected = false;
    //FIXME
    //snackBarWidget.handleError();
  }

}
