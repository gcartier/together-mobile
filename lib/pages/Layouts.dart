import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget togetherTitle() {
  return Center(
      child: Container(
    padding: EdgeInsets.only(top: 50),
    child: Text(
      "Together",
      style: TextStyle(fontSize: 60),
    ),
  ));
}

Widget threeColumns() {
  return Container(
    alignment: Alignment.bottomCenter,
    child: Row(children: <Widget>[
      Align(alignment: Alignment.bottomLeft, child: versionAndQuit()),
      Expanded(child: Center(child: warningAndNext())),
      Align(
        alignment: Alignment.bottomRight,
      ),
    ]),
  );
}

Widget versionAndQuit() {
  return Container(
      child: Column(children: <Widget>[
    Container(
      child: Text("v1.0"),
    ),
    Container(
        child: OutlinedButton(
      onPressed: quit,
      child: Text("Quit"),
    )),
  ]));
}

Widget warningAndNext() {
  return Container(
      child: Column(children: <Widget>[
    Container(
        child: Text(
      "Warning",
      style: TextStyle(color: Colors.red),
    )),
    Container(
        child: OutlinedButton(
      onPressed: next,
      child: Text("Next"),
    )),
  ]));
}

Widget entryField(String prompt, Function(String?) callback) {
  return Column(children: <Widget>[
    Text(prompt,
        style: TextStyle(
          color: Colors.amber.shade200,
          fontSize: 18,
        )),
    Container(
      padding: EdgeInsets.only(top: 10),
      child: SizedBox(
          height: 25.0,
          width: 300.0,
          child: TextField(
            controller: TextEditingController(),
            decoration: InputDecoration(
                hintStyle: TextStyle(fontStyle: FontStyle.italic),
                border: OutlineInputBorder()),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
            ),
            onChanged: callback,
          )),
    ),
  ]);
}

Widget inviteInfo() {
  return Container(
    child: Column(children: <Widget>[
      Flexible(
        flex: 4,
        child: SizedBox.expand(),
      ),
      Flexible(
          flex: 2,
          child: Container(
            alignment: Alignment.topCenter,
            child: Text("Join Together by Invitation",
                style: TextStyle(color: Colors.orange.shade700, fontSize: 25)),
          )),
      Flexible(
        flex: 3,
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(children: <Widget>[
            Text("Your Invitation Word",
                style: TextStyle(
                  color: Colors.amber.shade200,
                  fontSize: 18,
                )),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: SizedBox(
                  height: 25.0,
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
            ),
          ]),
        ),
      ),
      Flexible(
          flex: 10,
          child: Container(
            alignment: Alignment.topCenter,
            child: Column(children: <Widget>[
              Text("Your name as it will be displayed",
                  style: TextStyle(color: Colors.amber.shade200, fontSize: 18)),
              Container(
                  padding: EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 25.0,
                    width: 300.0,
                    child: TextField(
                        controller: new TextEditingController(),
                        decoration: InputDecoration(
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            border: OutlineInputBorder()),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.5,
                        ),
                        onChanged: (text) {}),
                  )),
            ]),
          ))
    ]),
  );
}

//TEMP
void quit() {}

void next() {}

void setInvitation(String invitation) {}

void setName(String name) {}
