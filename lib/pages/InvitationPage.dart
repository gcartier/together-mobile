import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'Layouts.dart';
import 'InvitationLayouts.dart';

String? invitation;
String? name;
String? errorMessage;

class InvitationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    errorMessage = (connection.errorMessage ?? null);

    return Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(title: Text('Together')),
        appBar: null,
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (!fullsize(constraints)) {
                return invitationPageSmall(constraints);
              } else {
                return Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/nebula.png"),
                          // image: AssetImage("assets/images/Momie.jpg"),
                          // image: AssetImage("assets/images/Dragons.jpg"),
                          fit: BoxFit.cover,
                        )),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          togetherTitle(constraints),
                          SizedBox(
                              height: (constraints.maxHeight / 2),
                              child: inviteInfo(constraints)),
                          // inviteInfo(),
                          buttonWidgets(constraints),
                        ]));
              }
            }));
  }

  Widget invitationPageSmall(BoxConstraints constraints) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/nebula.png"),
              // image: AssetImage("assets/images/Momie.jpg"),
              // image: AssetImage("assets/images/Dragons.jpg"),
              fit: BoxFit.cover,
            )),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              togetherTitle(constraints),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    buttonWidgets(constraints),
                    SizedBox(
                        height: (constraints.maxHeight - 100),
                        child: inviteInfo(constraints)),
                    nextButton(),
                  ]),
              warningText(),
            ]));
  }
}
