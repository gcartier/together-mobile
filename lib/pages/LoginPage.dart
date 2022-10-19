import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_mobile/pages/HomePage.dart';

import '../connection/Connection.dart';
import '../main.dart';

// TODO put these in Theme
Color _msgBoxColor = const Color(0xaa000000);
// Color _itemColor = const Color(0xcc0b054b);
Color _pplBoxColor = const Color(0x00000000);
Color _itemColor = const Color(0x000b054b);

String? _personalKey;
String? errorMessage;

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    errorMessage = (connection.errorMessage ?? null);
    return Scaffold(
        backgroundColor: Colors.transparent,
        //appBar: AppBar(title: Text('Together')),
        appBar: null,
        body: FutureBuilder(
          future: connection.retrieveId(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            _personalKey = snapshot.data;
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
                returnVal = Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/nebula.png"),
                    // image: AssetImage("assets/images/Momie.jpg"),
                    // image: AssetImage("assets/images/Dragons.jpg"),
                    fit: BoxFit.cover,
                  )),
                  child: Center(
                    child: EnterId(),
                  ),
                );
                break;
            }
            return returnVal;
          },
        ));
  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Colors.transparent,
//      appBar: AppBar(title: Text('Together')),
//      body: Center(
//        child: FlatButton(
//            child: Text('push me'),
//            onPressed: () {
//              Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) => HomePage()),
//              );
//            }),
//      ),
//    );
//  }

}

class EnterId extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EnterIdState();
  }
}

class EnterIdState extends State<EnterId> {
  storePersonalKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_personalKey != null) {
      prefs.setString('personal_key', _personalKey!);
    }
  }

  tryLogin(BuildContext context) async {
    Future<bool> completed;
    if (_personalKey == null) {
      print("33333 attempted login with null personal key");
    } else {
      storePersonalKey();
      bool success = await connection.connect(_personalKey);
      if (success) {
        errorMessage = null;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      } else {
        errorMessage = connection.errorMessage;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100,
      // decoration: BoxDecoration(
      // color: _itemColor,
      // ),
      child: Column(children: <Widget>[
        Consumer<Connection>(builder: (context, model, child) {
          return Expanded(
              flex: 2,
              child: Center(
                  child: RichText(
                      text: TextSpan(
                          text: errorMessage,
                          style:
                              TextStyle(fontSize: 18.0, color: Colors.red)))));
        }),
        // Expanded(
        // flex: 1,
        // child:
        Container(
            padding: EdgeInsets.only(bottom: 20),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: TextField(
                    controller: new TextEditingController(text: _personalKey),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                        border: OutlineInputBorder(),
                        hintText: 'Personal Key'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15.5, color: Theme.of(context).accentColor),
                    onChanged: (text) {
                      _personalKey = text;
                    }))),
        Expanded(
            flex: 2,
            // child: Container(
            child: Align(
              alignment: Alignment.topCenter,
              child: TextButton(
                //color: Colors.black54,
                child: Text("Enter",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24.0, color: Theme.of(context).primaryColor)),
                onPressed: () {
                  tryLogin(context);
                  // dismiss the keyboard
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  print("currentFocus is $currentFocus");
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.focusedChild?.unfocus();
                  }
                },
              ),
            )),
      ]),
    );
  }
}
