import 'package:flutter/material.dart';
import 'package:together_mobile/pages/HomePage.dart';
import 'package:together_mobile/pages/Layouts.dart';

import '../main.dart';

bool isEnabled = true;
String? initError;

//
/// LoginPage
//

class LoginPage extends StatelessWidget {
  LoginPage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(title: Text('Together')),
        appBar: null,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return FutureBuilder(
                  future: futureLocalStorage,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      isEnabled = true;
                      initError = null;
                    } else {
                      if (snapshot.hasError) {
                        isEnabled = false;
                        initError = snapshot.error.toString();
                      } else {
                        isEnabled = false;
                        initError = null;
                      }
                    }
                    return nebulaBackground(EnterId(constraints));
                  });
            }));
  }
}

//
/// EnterId
//

class EnterId extends StatefulWidget {
  BoxConstraints constraints;

  EnterId(this.constraints);

  @override
  State<StatefulWidget> createState() {
    return EnterIdState(constraints);
  }
}

//
/// EnterIdState
//

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
      localStorage?.setString('personal_key', personalKey);
    }
  }

  tryLogin(BuildContext context, String? personalKey,
      BoxConstraints constraints) async {
    Future<bool> completed;
    if (personalKey == null) {
    } else {
      storePersonalKey(personalKey);
      if(connection.isConnected) { // back button got us here
        connection.sendDeconnect();
        return;
      }
      bool success = await connection.connect(personalKey);
      if (success) {
        setState(clearError);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    HomePage(initialConstraints: constraints,)));
      } else {
        // rebuild the page with error message from Connection
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
          // Consumer<Connection>(
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
                  width: 200, height: 50,
                  child: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: TextField(
          onSubmitted: (value) {

    sendKey(context, value, constraints);},

                          enabled: isEnabled,
                          controller: _controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Personal Key',
                          ))),
                ),
                Container(
                    child: SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          child: Text("Enter"),
                          onPressed: () {
                            if (isEnabled) {
                              sendKey(context, _controller.text, constraints);
                            } else {
                              null;
                            }
                          },
                        ))),
                progressIndicatorIfNeeded(),
              ])
        ]));
  }

  sendKey(BuildContext context, String key, BoxConstraints constraints) {
    tryLogin(context, key, constraints);
  }
}
