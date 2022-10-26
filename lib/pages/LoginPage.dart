import 'package:flutter/material.dart';
import 'package:together_mobile/pages/HomePage.dart';
import 'package:together_mobile/pages/Layouts.dart';

import '../main.dart';

// TODO put these in Theme
Color _msgBoxColor = const Color(0xaa000000);
// Color _itemColor = const Color(0xcc0b054b);
Color _pplBoxColor = const Color(0x00000000);
Color _itemColor = const Color(0x000b054b);

bool isEnabled = true;
String? initError;

class LoginPage extends StatelessWidget {
  LoginPage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        //appBar: AppBar(title: Text('Together')),
        appBar: null,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return FutureBuilder(
              future: futureLocalStorage,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  print(">>>>>>>>DONE");
                  isEnabled = true;
                  initError = null;
                } else {
                  if (snapshot.hasError) {
                    print(">>>>>>>>ERROR");
                    isEnabled = false;
                    initError = snapshot.error.toString();
                  } else {
                    print(">>>>>>>>WAITING");
                    isEnabled = false;
                    initError = null;
                  }
                }
                return nebulaBackground(EnterId(constraints));
              });
        }));
  }
}

class EnterId extends StatefulWidget {
  BoxConstraints constraints;

  EnterId(this.constraints);

  @override
  State<StatefulWidget> createState() {
    return EnterIdState(constraints);
  }
}

class EnterIdState extends State<EnterId> {
  BoxConstraints constraints;
  late TextEditingController _controller;

  EnterIdState(this.constraints);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  clearError() {
    initError = null;
  }

  storePersonalKey(String personalKey) {
    if (localStorage != null) {
      print("setting prefs to personal_key ${personalKey}");
      localStorage?.setString('personal_key', personalKey);
    }
  }

  tryLogin(BuildContext context, String? personalKey) async {
    Future<bool> completed;
    if (personalKey == null) {
      print("33333 attempted login with null personal key");
    } else {
      storePersonalKey(personalKey);
      bool success = await connection.connect(personalKey);
      if (success) {
        print(">>>>>>>> Connect success!");
        setState(clearError);
        print("PUSH");
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      } else {
        //rebuild the page with error message from Connection
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isEnabled && _controller.text.isEmpty) {
      _controller.text = retrieveId() ?? "";
    }
    Widget progressIndicatorIfNeeded() {
      return isEnabled
          ? Container()
          : Container(
              padding: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator());
    }

    return Container(
        child: Column(children: <Widget>[
      togetherTitle(constraints),
      //Consumer<Connection>(
      //  builder: (context, model, child) {
      Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                connection.errorMessage ?? "",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
            SizedBox(
              width: 200,
              child: Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TextField(
                      enabled: isEnabled,
                      controller: _controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Personal Key',
                      ))),
            ),
            Container(
                //alignment: Alignment.bottomCenter,
                child: ElevatedButton(
              //color: Colors.black54,
              child: Text("Enter"),
              onPressed: () {
                if (isEnabled) {
                  Text text = Text(_controller.text);
                  tryLogin(context, text.data);
                } else {
                  null;
                }
              },
            )),
            progressIndicatorIfNeeded(),
          ])
    ]));
  }
}
