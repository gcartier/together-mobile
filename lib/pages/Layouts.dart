import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget togetherTitle() {
  return Center(
      child: Text(
    "Together",
    style: TextStyle(fontSize: 60),
  ));
}

Widget threeColumns() {
  return Row(children: <Widget>[
    Align(alignment: Alignment.bottomLeft, child: versionAndQuit()),
    Expanded(child: Center(child: warningAndNext())),
    Align(
      alignment: Alignment.bottomRight,
    ),
  ]);
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

Widget inviteInfo() {
  return Center(
    child: Column(children: <Widget>[
      Flexible(
    child: FractionallySizedBox(
      heightFactor: 0.3,
    ),
      ),
      Text("Join Together by Invitation",
      style: TextStyle(color: Colors.orange.shade700, fontSize: 25)),
      Flexible(
      child: FractionallySizedBox(
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
    ),
      ),
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
      )
    ]),
  );
}

//TEMP
void quit() {}

void next() {}
