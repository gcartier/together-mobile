import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

Widget bottomWidgets() {
  return Container(
    alignment: Alignment.bottomCenter,
    child: Column(children: <Widget>[
      Container(
          padding: EdgeInsets.only(bottom: 20),
          alignment: Alignment.topCenter,
          child: warningAndNext()),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
        Align(alignment: Alignment.bottomLeft, child: versionAndQuit()),
        //Expanded(child: Container()),
        Container(
            child: OutlinedButton(
            onPressed: usePersonalKey,
            child: Text("Use Personal Key"),
          )
        ),
      ]),
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
        padding: EdgeInsets.only(top: 20),
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
        padding: EdgeInsets.only(bottom: 20),
        child: Text(
          "",
          style: TextStyle(fontSize: 18, color: Colors.red),
        )),
    Container(
        child: OutlinedButton(
      onPressed: next,
      child: Text(style: TextStyle(fontSize: 22),
          "Next"),
    )),
  ]));
}

Widget entryField(String prompt, Function(String?) callback) {
  return Column(children: <Widget>[
    Text(prompt,
        style: TextStyle(
          color: Colors.amber.shade300,
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
          child: entryField("Your invitation word", setInvitation),
        ),
      ),
      Flexible(
          flex: 8,
          child: Container(
            alignment: Alignment.topCenter,
            child: entryField("Your name as it will be displayed", setName),
          ))
    ]),
  );
}

//TEMP
void quit() {}

void next() {}

void usePersonalKey() {}

setInvitation(String? invitation) {}

setName(String? name) {}
