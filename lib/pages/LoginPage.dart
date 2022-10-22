import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:together_mobile/pages/HomePage.dart';
import 'package:together_mobile/pages/Layouts.dart';

import '../connection/Connection.dart';
import '../main.dart';

// TODO put these in Theme
Color _msgBoxColor = const Color(0xaa000000);
// Color _itemColor = const Color(0xcc0b054b);
Color _pplBoxColor = const Color(0x00000000);
Color _itemColor = const Color(0x000b054b);

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        //appBar: AppBar(title: Text('Together')),
        appBar: null,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return nebulaBackground(EnterId(constraints));
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
    _controller.text = retrieveId() ?? "";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  storePersonalKey(String personalKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (personalKey != null) {
      print("setting prefs to personal_key $personalKey");
      prefs.setString('personal_key', personalKey!);
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
        //Navigator.of(context).pushReplacement(
        //    MaterialPageRoute(builder: (BuildContext context) => HomePage()));
      } else {
        //rebuild the page with error message from Connection
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      togetherTitle(constraints),
      Consumer<Connection>(
        builder: (context, model, child) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Text(
                    model.errorMessage ?? "",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Container(
                      padding: EdgeInsets.only(bottom: 20),
                      child: TextField(
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
                    Text text = Text(_controller.text);
                    tryLogin(context, text.data);
                  },
                )),
              ]);
        },
      ),
    ]));
  }
}
