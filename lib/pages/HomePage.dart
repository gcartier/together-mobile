import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:together_mobile/pages/ColorConstants.dart';

import '../connection/Connection.dart';
import '../main.dart';
import '../models/MessageModel.dart';
import '../models/PeopleModel.dart';
import 'MessagePage.dart';
import 'PeoplePage.dart';

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
                print("POP");
                Navigator.pop(context);
              })
        ])),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Consumer<Connection>(builder: (context, model, child) {
            if (!model.isConnected) {
              Future.delayed(Duration.zero, () async {
                Navigator.pop(context);
              });
            }
            if (constraints.maxWidth > 640) {
              return largeFormat(context, constraints);
            } else {
              return smallFormat(context, constraints);
            }
          });
        }));
  }

  Widget smallFormat(BuildContext context, Constraints constraints) {
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
              //child: Container(),
              child: People(),
            );
          }),
          Consumer<MessageModel>(builder: (context, model, child) {
            return Flexible(
              flex: 2,
              child: Messages(),
            );
          }),
          Consumer<PeopleModel>(builder: (context, model, child) {
            return whisperTo();
          }),
          Consumer<MessageModel>(builder: (context, model, child) {
            return SendMessage();
          }),
        ],
      ),
    );
  }

  Widget largeFormat(BuildContext context, BoxConstraints constraints) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/images/nebula.png"),
          // image: AssetImage("assets/images/Momie.jpg"),
          // image: AssetImage("assets/images/Dragons.jpg"),
          fit: BoxFit.cover,
        )),
        child: Row(children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
                margin:
                    EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 100),
                decoration: BoxDecoration(
                  //color: _msgBoxColor,
                  border: Border.all(
                    color: ColorConstants.frameColor,
                    width: 1,
                  ),
                ),
                child: Consumer<PeopleModel>(builder: (context, model, child) {
                  return People();
                })),
          ),
          Flexible(flex: 1, child: Container()),
          Flexible(
            flex: 1,
            child: Container(
                margin:
                    EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 100),
                decoration: BoxDecoration(
                  //color: _msgBoxColor,
                  border: Border.all(
                    color: ColorConstants.frameColor,
                    width: 1,
                  ),
                ),
                child: Consumer<MessageModel>(
                  builder: (context, model, child) {
                    return Column(children: <Widget>[
                      SizedBox(
                          height: (constraints.maxHeight - 150),
                          child: Messages()),
                      Consumer<PeopleModel>(builder: (context, model, child) {
                        return whisperTo();
                      }),
                      SendMessage(),
                    ]);
                  },
                )),
          )
        ]));
  }
}
