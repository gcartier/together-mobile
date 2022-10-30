
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Layouts.dart';

Widget buttonWidgets(BoxConstraints constraints) {
  if (!fullsize(constraints)) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // warningAndNext(),
            Container(
                padding: EdgeInsets.only(bottom: 50),
                child: OutlinedButton(
                  onPressed: usePersonalKey,
                  child: Text("Use Personal Key"),
                )),
            versionAndQuit(),
          ]),
    );
  } else {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        Container(
            padding: EdgeInsets.only(bottom: 20),
            alignment: Alignment.topCenter,
            child: warningAndNext()),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Align(alignment: Alignment.bottomLeft, child: versionAndQuit()),
              Container(
                  child: OutlinedButton(
                    onPressed: usePersonalKey,
                    child: Text("Use Personal Key"),
                  )),
            ]),
      ]),
    );
  }
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

Widget nextButton() {
  return Container(
      child: OutlinedButton(
        onPressed: next,
        child: Text(style: TextStyle(fontSize: 22), "Next"),
      ));
}

Widget warningText() {
  return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Text(
        "Warning your current personal key will be lost",
        style: TextStyle(fontSize: 18, color: Colors.red),
      ));
}

Widget warningAndNext() {
  return Container(
      child: Column(children: <Widget>[
        warningText(),
        nextButton(),
      ]));
}

Widget entryField(String prompt, Function(String?) callback, BoxConstraints constraints) {
  return Column(children: <Widget>[
    Text(prompt,
        style: TextStyle(
          color: Colors.amber.shade300,
          fontSize: 18,
        )),
    Container(
      padding: EdgeInsets.only(top: (fullsize(constraints) ? 10 : 4)),
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

Widget inviteInfoSmall() {
  return Container();
}

Widget inviteInfo(BoxConstraints constraints) {
  return Container(
    child: Column(children: <Widget>[
      Flexible(
          flex: 4,
          child: Container(
            alignment: Alignment.topCenter,
            child: Text("Join Together by Invitation",
                style: TextStyle(color: Colors.orange.shade700, fontSize: (fullsize(constraints)) ? 25 : 16)),
          )),
      Flexible(
        flex: 4,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: entryField("Your invitation word", setInvitation, constraints),
        ),
      ),
      Flexible(
          flex: (fullsize(constraints)) ? 10 : 4,
          child: Container(
            alignment: Alignment.bottomCenter,
            child: entryField("Your name as it will be displayed", setName, constraints),
          ))
    ]),
  );
}

// TEMP
void quit() {}

void next() {}

void usePersonalKey() {}

setInvitation(String? invitation) {}

setName(String? name) {}
