import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:together_mobile/models/PeopleModel.dart';
import '../settings.dart';

double phoneWidth = 600.0;

bool fullsize(BoxConstraints constraints) {
  return (constraints.maxHeight > phoneWidth ? true : false);
}

Widget togetherTitle(BoxConstraints constraints) {
  double fSize = (fullsize(constraints) ? 60 : 40);
  return Center(
      child: Container(
        padding: EdgeInsets.only(top: (fullsize(constraints) ? 50 : 10)),
        child: Text(
          togetherInvite,
          style: TextStyle(fontSize: (fullsize(constraints) ? 60 : 40)),
        ),
      ));
}

Widget nebulaBackground(Widget child) {
  return Container(
    decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/nebula.png"),
          fit: BoxFit.cover,
        )),
    child: Center(
      child: child,
    ),
  );
}

Widget peopleWidget(List<Widget> peopleAndGroups) {
  return ListView(
    padding: EdgeInsets.only(top: 20.0),
    children: peopleAndGroups,
  );
}

Widget clickablePerson(Person person) {
  String name;
  if (person.inMyGroup) {
    name = "<${person.name}>";
  } else {
    name = person.name;
  }
  return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: () {
            person.personClicked();
          },
          onLongPress: () {
            // messageModel.sendInvite(person);
          },
          child: ListTile(
              title: Text(
                name,
                style: TextStyle(
                  fontSize: 18.0, /*color: Theme.of(context).primaryColor*/
                ),
              ))));
}
