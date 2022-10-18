import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'Data.dart';
import 'SocketWrapper.dart';

class Connection extends ChangeNotifier {
  //bool isConnected;
  SocketWrapper? _socketWrapper;
  late DataParser dataParser;
  String? _errorMessage;

  String? get errorMessage {
    return _errorMessage;
  }

  set errorMessage(String? msg) {
    _errorMessage = msg;
  }

  Connection(connectCompleted, connectFailed) {
    dataParser = DataParser(connectCompleted, connectFailed);
  }

  bool get isConnected {
    if (_socketWrapper != null) {
      return true;
    }
    return false;
  }

  set isConnected(bool val) {
    if (val == false) {
      if (isConnected)
        // _socketWrapper.destroy();  TODO
        _socketWrapper = null;
      isConnected = false;
    }
    isConnected = true;
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
      id = await retrieveId();
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
      final _socket =
          await Socket.connect('togethersphere.com', 50150); // tsd mobile
      _socketWrapper = SocketWrapper(
          _socket, id, dataParser.dataHandler, errorHandler, doneHandler);
    } catch (err) {
      print("2222 $err");
      _errorMessage = "Connection refused";
      return Future.value(false);
    }
    Completer<bool> newCompleter = new Completer<bool>();
    connectCompleter = newCompleter;
    return await newCompleter.future;
  }

  void send(String message) async {
    if (isConnected) {
      print("1111 Sending $message");
      _socketWrapper?.write(message);
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
    if (isConnected) {
      await (_socketWrapper?.close());
    }
    isConnected = false;
    //FIXME
    //snackBarWidget.handleError();
  }

  Future<String?> retrieveId() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? returnVal = _prefs.getString('personal_key');
    print("Future returning $returnVal");
    return returnVal;
    // return Future.value(null);
    // return Future.value("A06250E4-B0D2-4119-90AB-E4B84D2FFCF3");
  }
}
