import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'Layouts.dart';

String? invitation;
String? name;
String? errorMessage;

class InvitationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    errorMessage = (connection.errorMessage ?? null);

    return Scaffold(
        backgroundColor: Colors.transparent,
        //appBar: AppBar(title: Text('Together')),
        appBar: null,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/images/nebula.png"),
                // image: AssetImage("assets/images/Momie.jpg"),
                // image: AssetImage("assets/images/Dragons.jpg"),
                fit: BoxFit.cover,
              )),
              child: Column(children: <Widget>[
                togetherTitle(),
                Expanded(
                  child: inviteInfo(),
                ),
                bottomWidgets(),
              ]));
        }));
  }
}
