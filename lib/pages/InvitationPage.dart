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
                child: SizedBox.expand(
                    child: Column(children: <Widget>[
                      togetherTitle(),
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: 0.3,
                        ),
                      ),
                      Text("Join Together by Invitation",
                          style: TextStyle(color: Colors.orange.shade700, fontSize: 25)),
                      Flexible(
                        child: FractionallySizedBox(
                          alignment: FractionalOffset.center,
                          heightFactor: 0.2,
                        ),
                      ),
                      Text("Your Invitation Word",
                          style: TextStyle(
                            color: Colors.amber.shade200,
                            fontSize: 18,
                          )),
                      SizedBox(
                          height: 30.0,
                          width: 300.0,
                          child: TextField(
                              controller: TextEditingController(),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(fontStyle: FontStyle.italic),
                                  border: OutlineInputBorder()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.5,
                              ))),
                    Flexible(
                        child: FractionallySizedBox(
                          heightFactor: 0.2,
                        )),
                      Text("Your name as it will be displayed",
                          style: TextStyle(color: Colors.amber.shade200, fontSize: 18)),
                      SizedBox(
                          height: 30.0,
                          width: 400.0,
                          child: TextField(
                              controller: new TextEditingController(),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(fontStyle: FontStyle.italic),
                                  border: OutlineInputBorder()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.5,
                              ),
                              onChanged: (text) {})),
                      Flexible(
                          child: FractionallySizedBox(heightFactor: 0.3,)
                      ),
                      threeColumns(),
                    ])),
                // alignment: FractionalOffset.center,
              );
            }));}}

