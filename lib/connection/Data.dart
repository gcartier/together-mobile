import 'dart:convert';

import '../main.dart';
import '../models/MessageModel.dart';

class DataParser {
  Function connectCompleted;
  Function connectFailed;
  String? _errorMessage;

  DataParser(this.connectCompleted, this.connectFailed);

  final List _connectionJson = [];
  final List _peopleJson = [];
  final List _messagesJson = [];
  final List<String> snackBarJson = [];
  bool _somethingChanged = false;

  String? get errorMessage {
    String? retVal = connection.errorMessage;
    _errorMessage = null;
    return retVal;
  }

  set errorMessage(String? msg) {
    _errorMessage = msg;
    if (msg != null) {
      messageModel.addServerMessage(MessageType.SERVER, msg);
    }
    //FIXME
    connection.notifyListeners();
  }

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

//dataHandler(List<int> event) {
//dataHandler(Uint8List event) {
  dataHandler(dynamic event) {
    void processJson(String s) {
      if (s.length <= 0) {
        print("------------------");
      } else {
        print(s);
        var decodedJSON;
        try {
          decodedJSON = jsonDecode(s); //as Map<String, dynamic>;
          //json = jsonDecode(s);
        } on FormatException catch (e) {
          connection.errorMessage = "Cannot recognize server response";
          return;
        }
        _routeCommands(decodedJSON);
      }
    }
    String buf = utf8.decode(event);
    print("44444 $buf");
    List<String> strings = buf.split('|');
    strings.forEach(processJson);
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
              print("5555Error: $data");
              connection.errorMessage = data;
              _connectionJson.add(["error", data]);
              connectFailed();
              break;
            } else {
              _connectionJson.add([command, data[2]]);
              connectCompleted();
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
            print(" Unknown command: ${command} ");
        }
        break;
      default:
        print("Unknown kind: $kind");
    }
    checkConnectionState();
    //FIXME
    //snackBarWidget.showSnackBarMessages();
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
          messageModel.addServerMessage(
              MessageType.SERVER, "Server confirmed connect");
          if (!connection.isConnected) {
            _somethingChanged = true;
          }
          break;
        case 'detach':
          messageModel.addServerMessage(MessageType.SERVER, "Server detached");
          if (connection.isConnected) {
            _somethingChanged = true;
          }
          break;
        case 'deconnect':
          snackBarJson.add("Server confirmed deconnect");
          _somethingChanged = true;
          break;
        default:
          print("Unknown Connection State: $element");
      }
    });
    clearConnection();
  }
}
