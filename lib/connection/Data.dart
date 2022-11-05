import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import '../settings.dart';
import '../main.dart';
import '../models/MessageModel.dart';

void playMessageSound() {
  js.context.callMethod("beep", ["sounds/message.wav", 15]);
}

class DataParser {
  Completer? connectCompleter;

  final List _connectionJson = [];
  final List _peopleJson = [];
  final List _messagesJson = [];
  final List<String> snackBarJson = [];
  bool _somethingChanged = false;

  complete(bool success) {
    if (success) {
      connectCompleter?.complete(true);
    } else {
      connectCompleter?.complete(false);
    }
    connectCompleter = null;
  }

  /*
  String? get errorMessage {
    String? retVal = connection.errorMessage;
    _errorMessage = null;
    return retVal;
  }

  set errorMessage(String? msg) {
    _errorMessage = msg;
    if (msg != null) {
      // addServerMessage(MessageType.SERVER, msg);
      if (debugMobile)
        print("error: $msg");
    }
    // FIXME
    // connection.notifyListeners();
  }*/

  List<String> decodeJSArray(List l) {
    List<String> returnList = [];
    l.forEach((element) {
      returnList.add(element[0]);
    });
    return returnList;
  }

  List<String> get connectionList {
    return decodeJSArray(_connectionJson);
  }

  List<dynamic> get peopleList {
    return _peopleJson;
  }

  List<String> get snackBarList {
    return snackBarJson;
  }

  List get messagesList {
    return _messagesJson;
  }

  void clearConnection() => _connectionJson.clear();

  void clearPeople() => _peopleJson.clear();

  void clearMessages() => _messagesJson.clear();

  _notifyModels() {
    if (_somethingChanged) {
      peopleModel.somethingChanged(this);
      messageModel.somethingChanged(this);
    }
    _somethingChanged = false;
  }

// dataHandler(List<int> event) {
// dataHandler(Uint8List event) {
  dataHandler(dynamic event) {
    void processJson(String s) {
      if (s.length <= 0) {
        if (debugMobile)
          print("------------------");
      } else {
        if (debugMobile) {
          print(s);
        }
        var decodedJSON;
        try {
          decodedJSON = jsonDecode(s); // as Map<String, dynamic>;
          // json = jsonDecode(s);
        } on FormatException catch (e) {
          connection.errorMessage = "Cannot recognize server response";
          return;
        }
        _routeCommands(decodedJSON);
      }
    }
    processJson(event);
  }

  _routeCommands(List json) {
    var kind = json[0];
    var command = json[1];
    var data = json[2];
    switch (kind) {
      case 'result':
        switch (command) {
          case 'connect':
            if (data is String) {
              connection.errorMessage = data;
              _connectionJson.add(["error", data]);
              connection.completionError = data;
              complete(false);
              return;
              //break;
            } else {
              _connectionJson.add([command, data[2]]);
              complete(true);
            }
            break;
          case 'deconnect':
            _connectionJson.add([command, data]);
            break;
        }
        break;
      case 'call':
        switch (command) {
          case 'people':
            _peopleJson.add(data);
            _somethingChanged = true;
            break;
          case 'detach':
            _connectionJson.add([command, data]);
            break;
          case 'entered':
            snackBarJson.add("${data[1]} entered");
            break;
          case 'exited':
            snackBarJson.add("${data[0]} exited");
            break;
          case 'disconnected':
          case 'reconnected':
            snackBarJson.add(data as String);
            break;
          case 'message':
            var messageKind = data[1];
            // for now as there are very few messages to the gathering
            // and also until we have some nice notification for them
            // if (messageKind == 'whisper')
              playMessageSound();
            _messagesJson.add(data);
            _somethingChanged = true;
            break;
          case 'messages':
          // _msgModel.addAll(data);
            break;
          case 'invite':
            snackBarJson.add("${data[0]} invited you to her group");
            break;
          case 'accept':
            snackBarJson.add("${data[0]} accepted your invitation");
            break;
          case 'decline':
            snackBarJson.add("${data[0]} declined your invitation");
            break;
          case 'disband':
            snackBarJson.add("your group was disbanded");
            break;
          default:
            if (debugMobile)
              print(" Unknown command: ${command} ");
        }
        break;
      default:
        if (debugMobile)
          print("Unknown kind: $kind");
    }
    checkConnectionState();
    // FIXME
    // snackBarWidget.showSnackBarMessages();
    _notifyModels();
  }

  void checkConnectionState() {
    if (_connectionJson.isEmpty) return;
    _connectionJson.forEach((element) {
      switch (element[0]) {
        case 'error':
          _somethingChanged = true;
          break;
        case 'connect':
          peopleModel.setMe(element[1]);
          snackBarJson.add("Server confirmed connect");
          // messageModel.addServerMessage(
          //     MessageType.SERVER, "Server confirmed connect");
          _somethingChanged = true;
          break;
        case 'detach':
        // messageModel.addServerMessage(MessageType.SERVER, "Server detached");
          if (connection.isConnected) {
            _somethingChanged = true;
          }
          break;
        case 'deconnect':
          snackBarJson.add("Server confirmed deconnect");
          _somethingChanged = true;
          break;
        default:
          if (debugMobile)
            print("Unknown Connection State: $element");
      }
    });
    clearConnection();
  }
}
