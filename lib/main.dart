import 'dart:async';
import 'dart:ui';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings.dart';
import 'connection/Connection.dart';
import 'models/MessageModel.dart';
import 'models/PeopleModel.dart';
import 'pages/HomePage.dart';
import 'pages/LoginPage.dart';
import 'pages/CentralPage.dart';

// TODO
// Need to add cases for join and leave group - message only
// Clicking the cloud button fast causes desync with server
// Need to clean up fonts and general layout of message tiles
// Investigate UDP
// Need to be able to accept invite (investigate dialog)
// Need to clean up display (etc) when disconnected from server
// Need to create login screen
// When person leaves, can still whisper to that person
// check with G about getting 7 args instead of 6 to describe Person
// Focus bug with keyboard dismiss - throws exception
// admin commands
// background image of selected zone
// connect-sound, connect-attention, message-sound, message-attention

final String titleString = 'Together Connect';

Future futureLocalStorage = initLocalStorage();
SharedPreferences? localStorage;

PeopleModel peopleModel = PeopleModel();
MessageModel messageModel = MessageModel();
FocusNode textFocusNode = FocusNode();

Connection connection = Connection();

// CloudConnectIcon cloudConnectIcon = CloudConnectIcon();
SnackBarWidget snackBarWidget = SnackBarWidget();

Color _msgBoxColor = const Color(0xaa000000);
// Color _itemColor = const Color(0xcc0b054b);
Color _pplBoxColor = const Color(0x00000000);
Color _itemColor = const Color(0x000b054b);

enum PageType {
  HOME,
  LOGIN,
}

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => peopleModel),
      ChangeNotifierProvider(create: (context) => messageModel),
      ChangeNotifierProvider(create: (context) => connection),
    ],
    child: Consumer<Connection>(builder: (context, model, child) {
      return MyApp();
    }),
  ));
}

Future initLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  localStorage = prefs;
  // return prefs;
}

String? retrieveId() {
  if (localStorage != null) {
    String? key = localStorage?.getString("personal_key");
    return key;
  } else {
    if (debugMobile)
      print("!!!!!!!!! Local storage is null");
  }
}

class CloudConnectIcon extends StatelessWidget {
  // BuildContext _context;

  @override
  Widget build(BuildContext context) {
    // _context = context;
    if (connection.isConnected) {
      return IconButton(
        icon: const Icon(Icons.cloud_off),
        tooltip: "Deconnect from Server",
        onPressed: () {
          connection.sendDeconnect();
        },
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.cloud),
        tooltip: "Connect to Server",
        onPressed: () {
          connection.connect();
        },
      );
    }
  }

// This is here because it needs a Widget class for context, but does not have
// a Widget of its own to display.
// void showSnackBarMessages() {
// List<String> snackList = togetherSocket._snackBarJson;
// snackList.forEach((snack) {
// Scaffold.of(_context).showSnackBar(SnackBar(content: Text(snack)));
// });
// snackList.clear();
// }
}

class SnackBarWidget extends StatelessWidget {
  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    this._context = context;
    return Container();
  }

  void showSnackBarMessages() {
    if (_context == null) return;
    List<String> snackList = connection.snackBarList;
    snackList.forEach((snack) {
      ScaffoldMessenger.of(_context)
          .showSnackBar(SnackBar(content: Text(snack)));
    });
    snackList.clear();
  }

}

class MyApp extends StatelessWidget {
  ThemeData themeData = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.lightBlue[800],
      highlightColor: Colors.cyan[600],
      dividerColor: Colors.blueGrey,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            //backgroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 18))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            textStyle: const TextStyle(
              fontSize: 16,
            ),
            backgroundColor: Colors.deepOrange.shade900,
            foregroundColor: Colors.amber.shade300,
          )));

  MyApp() {
    html.window.onBeforeUnload.listen((e) {
      if(connection.isConnected) {
        connection.sendDeconnect();
        connection.isConnected = false;
      }
    });  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //   return Builder(builder: (BuildContext context) {
    return Builder(builder: (BuildContext context) {
      return MaterialApp(
        title: titleString,
        theme: themeData,
        routes: {
          'login': (BuildContext) => LoginPage(),
          'home': (BuildContext) => HomePage()
        },
        initialRoute: 'login',
      );
    });
  }
}
