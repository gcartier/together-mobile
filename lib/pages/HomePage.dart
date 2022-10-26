import 'package:flutter/material.dart';
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
        body: Consumer<Connection>(
          builder: (context, model, child) {
            if(!model.isConnected) {
              Future.delayed(Duration.zero, () async {
                Navigator.pop(context);
              });
            }
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
            }
        ));
  }


}



