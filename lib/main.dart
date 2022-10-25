import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'connection/Connection.dart';
import 'models/MessageModel.dart';
import 'models/PeopleModel.dart';
import 'pages/HomePage.dart';
import 'pages/LoginPage.dart';

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

final String titleString = 'Together Mobile';

Future futureLocalStorage = initLocalStorage();
SharedPreferences? localStorage;

PeopleModel peopleModel = PeopleModel();
MessageModel messageModel = MessageModel();
Connection connection = Connection(connectCompleted, connectFailed);
Completer<bool>? connectCompleter;
ToButton toButton = ToButton();
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
  //return prefs;
}

String? retrieveId() {
  if (localStorage != null) {
    String? key = localStorage?.getString("personal_key");
    print("retrieveId retrieved ${key}");
    return key;
  } else {
    print("!!!!!!!!! Local storage is null");
  }
}

void connectCompleted() {
  connectCompleter?.complete(true);
  connectCompleter = null;
}

void connectFailed() {
  connectCompleter?.complete(false); // TODO should this be error?
  connectCompleter = null;
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
          print("send deconnect");
          connection.sendDeconnect();
        },
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.cloud),
        tooltip: "Connect to Server",
        onPressed: () {
          print("send connect");
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

  void handleError() {
    Navigator.of(_context).pushReplacementNamed('login');
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

  PageType pageType = PageType.LOGIN;

  MyApp() {
    pageType = PageType.LOGIN;
  }

  /*
  FutureBuilder<dynamic> homeOrLogin() {
    switch (pageType) {
      case PageType.LOGIN:
        return FutureBuilder(
          future: initLocalStorage(),
          builder: (BuildContext context) {
            return MaterialApp(
              title: titleString,
              theme: themeData,
              routes: {
                'login': (BuildContext) => LoginPage(),
                'home': (BuildContext) => HomePage()
              },
              initialRoute: 'login',
            );
          },
        );
        break;
      case PageType.HOME:
      default:
        return FutureBuilder(
            future: connection.connect(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              Widget returnVal;
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  print("Connection State none!!!");
                  returnVal = Container();
                  break;
                case ConnectionState.waiting:
                  returnVal = Center(child: CircularProgressIndicator());
                  break;
                case ConnectionState.done:
                default:
                  returnVal = MaterialApp(
                    title: titleString,
                    theme: themeData,
                    routes: {
                      'login': (BuildContext) => LoginPage(),
                      'home': (BuildContext) => HomePage(),
                    },
                    // initialRoute: (id == null) ? 'login' : 'home',
                    initialRoute: 'home',
                  );
                  break;
              }
              return returnVal;
            });

    }
}*/

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

class People extends StatelessWidget {
  PeopleModel _model;

  People(this._model);

  @override
  Widget build(BuildContext context) {
    List<Widget> _items = <Widget>[];
    PeopleIterator iter = peopleModel.peopleIterator;

    Widget _buildContainer(Widget child) {
      return Container(
        margin: EdgeInsets.only(
          top: 20.0,
        ),
        decoration: BoxDecoration(
          color: _pplBoxColor,
        ),
        child: child,
      );
    }

    if (iter == null) {
      return _buildContainer(Container());
    } else {
      Widget _buildRow(Person person) {
        String name;
        if (person.inMyGroup) {
          name = "<${person.name}>";
        } else {
          name = person.name;
        }
        return ListTile(
          title: Text(
            name,
            style: TextStyle(
                fontSize: 18.0, color: Theme.of(context).primaryColor),
          ),
        );
      }

      while (iter.moveNext()) {
        HierarchyMember item = iter.current;
        if (item is Group) {
          _items.add(Text(item.name));
        } else if (item is Person) {
          Person person = item as Person;
          _items.add(
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  person.personClicked();
                },
                onLongPress: () {
                  messageModel.sendInvite(person);
                },
                child: _buildRow(person),
              ),
            ),
          );
        }
        ;
      }
      return _buildContainer(
        ListView(
          children: _items,
        ),
      );
    }
  }
}

class Messages extends StatefulWidget {
  @override
  MessagesState createState() {
    return MessagesState();
  }
}

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
                              color: Theme.of(context).accentColor)
                          : TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).primaryColor)),
                  TextSpan(
                    text: message.content,
                    style: TextStyle(
                        fontSize: 16.0, color: Theme.of(context).primaryColor),
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

  // List<String> _messages;

  @override
  Widget build(BuildContext context) {
    List _items = <Widget>[];

    Widget _buildContainer(Widget child) {
      return Container(
        margin: EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: _msgBoxColor,
//          border: Border.all( color: Colors.black, width: 0, ),
        ),
        child: child,
      );
    }

    for (int i = 0; i < messageModel.messages.length; i++) {
      Message message = messageModel.messages[i];
      if (message.messageType == MessageType.WHISPER) {
        print("message type whisper");
        _items.add(
          Material(
            color: _itemColor,
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

    ListView list = ListView.builder(
        controller: scrollController,
        itemCount: messageModel.messages.length,
        itemBuilder: (context, index) {
          return _items[index];
        });

    Widget returnVal = _buildContainer(list);
    if ((scrollController != null) && (scrollController.hasClients)) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent + 1000);
    }

    return returnVal;
  }
}

class ToButton extends StatefulWidget {
  @override
  State<ToButton> createState() {
    return ToButtonState();
  }
}

class ToButtonState extends State<ToButton> {
  MessageType _toType = MessageType.GATHERING;

  void set toType(MessageType type) {
    print("setting toType to $type");
    assert((type == MessageType.WHISPER) ||
        (type == MessageType.GATHERING) ||
        (type == MessageType.GROUP));
    _toType = type;
  }

  void cycleToType() {
    switch (_toType) {
      case MessageType.WHISPER:
        toType = (peopleModel.me?.inMyGroup ?? false)
            ? MessageType.GROUP
            : MessageType.GATHERING;
        break;
      case MessageType.GROUP:
        toType = MessageType.GATHERING;
        break;
      case MessageType.GATHERING:
        if (peopleModel.lastClicked != null) {
          toType = MessageType.WHISPER;
        } else if (peopleModel.me?.inMyGroup ?? false) {
          toType = MessageType.GROUP;
        } else {
          toType = MessageType.GATHERING;
        }
        break;
      default:
        toType = MessageType.GATHERING;
    }
    messageModel.toButtonState = _toType;
  }

  String createToLabel() {
    print("11111 createToLabel lastClicked: ${peopleModel.lastClicked?.name}");
    String returnVal;
    Person? lastClicked = peopleModel?.lastClicked;
    bool lastClickedNew = peopleModel.lastClickedNew;
    if ((lastClicked != null) && lastClickedNew) {
      toType = MessageType.WHISPER;
    }
    switch (_toType) {
      case MessageType.WHISPER:
        if (lastClicked != null) {
          returnVal = "Whisper to ${lastClicked.name}";
        } else {
          toType = MessageType.GATHERING;
          returnVal = "To the Gathering";
        }
        break;
      case MessageType.GROUP:
        if (peopleModel.me?.inMyGroup ?? false) {
          returnVal = "To My Group";
        } else {
          toType = MessageType.GATHERING;
          returnVal = "To the Gathering";
        }
        break;
      case MessageType.GATHERING:
      default:
        returnVal = "To the Gathering";
    }
    return returnVal;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Text(createToLabel(),
            style: TextStyle(
                fontSize: 24.0, color: Theme.of(context).primaryColor)),
        onPressed: () => setState(() {
              cycleToType();
            }));
  }
}

class SendMessage extends StatelessWidget {
  MessageModel messageModel;

  SendMessage(this.messageModel);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: _itemColor,
      ),
      child: Row(children: <Widget>[
        Expanded(
            child: TextField(
                decoration: InputDecoration(
                    hintStyle: TextStyle(fontStyle: FontStyle.italic),
                    border: InputBorder.none,
                    hintText: 'Tap to compose a message'),
                style: TextStyle(color: Theme.of(context).accentColor),
                onChanged: (text) {
                  messageModel.textMessage = text;
                })),
        IconButton(
          icon: Icon(Icons.send),
          color: Theme.of(context).accentColor,
          onPressed: () {
            messageModel.sendTextMessage();
            // dismiss the keyboard
            FocusScopeNode currentFocus = FocusScope.of(context);
            print("currentFocus is $currentFocus");
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.focusedChild?.unfocus();
            }
          },
        ),
      ]),
    );
  }
}
