import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connection/Connection.dart';
import '../main.dart';
import '../models/MessageModel.dart';
import '../models/PeopleModel.dart';

// TODO put these in Theme
Color _msgBoxColor = const Color(0xaa000000);
// Color _itemColor = const Color(0xcc0b054b);
Color _pplBoxColor = const Color(0x00000000);
Color _itemColor = const Color(0x000b054b);

class HomePage extends StatelessWidget {
  HomePage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Together'),
          actions: <Widget>[
            Consumer<Connection>(builder: (context, model, child) {
              return CloudConnectIcon();
            }),
            Consumer<Connection>(builder: (context, model, child) {
              return snackBarWidget;
            }),
          ],
        ),
        drawer: Drawer(
            child: ListView(children: <Widget>[
          ListTile(
              title: Text("Login Page"),
              onTap: () {
                Navigator.of(context).pushNamed('login');
              })
        ])),
        body: Consumer<Connection>(
          builder: (context, model, child) {
            return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/images/nebula.png"),
                // image: AssetImage("assets/images/Momie.jpg"),
                // image: AssetImage("assets/images/Dragons.jpg"),
                fit: BoxFit.cover,
              )),
              child: Column(
                children: <Widget>[
                  Consumer<PeopleModel>(builder: (context, model, child) {
                    return Flexible(
                      flex: 2,
                      child: People(model),
                    );
                  }),
                  Consumer<MessageModel>(builder: (context, model, child) {
                    return Flexible(
                      flex: 2,
                      child: Messages(),
                    );
                  }),
                  Consumer<PeopleModel>(builder: (context, model, child) {
                    return ToButton();
                  }),
                  Consumer<MessageModel>(builder: (context, model, child) {
                    return SendMessage(model);
                  }),
                ],
              ),
            );
          },
        ));
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
      return _buildContainer(new Container());
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
        print("message type not whisper: ${message.messageType}");
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
