import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/PeopleModel.dart';
import 'ColorConstants.dart';

class People extends StatelessWidget {
  tilePressed(dynamic personOrGathering) {
    if (peopleModel != null) {
      peopleModel.lastClicked = personOrGathering;
    }
  }

  Widget createGroupTile(Group group) {
    String name = group.name ?? "NO NAME";
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              (group.groupType == GroupType.GROUPLESS)
                  ? tilePressed(group)
                  : joinCircle(group);
            },
            child: ListTile(
              title: Text(
                name,
                style: TextStyle(
                    fontSize: 18.0,
                    color: group.groupType == GroupType.GROUPLESS
                        ? ColorConstants.gatheringColor
                        : ColorConstants.groupColor),
              ),
            )));
  }

  Widget createOutThereTile() {
    String name = "Out There";
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              createNewZoom();
            },
            child: ListTile(
                title: Text(
              name,
              style: TextStyle(
                fontSize: 18.0,
                color: ColorConstants.gatheringColor,
              ),
            ))));
  }

  Widget createZoomGroupTile(ZoomGroup group) {
    String name = group.name ?? "NO NAME";
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              joinZoomGroup(group);
            },
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 32),
              title: Text(
                name,
                style:
                    TextStyle(fontSize: 18.0, color: ColorConstants.groupColor),
              ),
            )));
  }

  Widget createPersonTile(Person person) {
    String name = person.name;
    double indent = person.inGroup ? 32 : 16; // 16 is default
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
              person.personClicked();
            },
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: indent),
              title: Text(
                name,
                style: TextStyle(
                    fontSize: 18.0, color: ColorConstants.observerColor),
              ),
              onTap: () {
                tilePressed(person);
              },
            )));
  }

  void joinCircle(Group group) {}

  void joinZoomGroup(ZoomGroup group) {}

  void createNewZoom() {}

  @override
  Widget build(BuildContext context) {
    List<Widget> _items = <Widget>[];
    PeopleIterator? iter = peopleModel.peopleIterator;
    Iterator zoomIter = peopleModel.zoomIterator;
    if (iter != null) {
      while (iter.moveNext()) {
        HierarchyMember item = iter.current;
        if (item is Group) {
          Group group = item as Group;
          _items.add(createGroupTile(group));
        } else if (item is Person) {
          Person person = item as Person;
          _items.add(createPersonTile(person));
        }
        ;
      }
    }
    ;
    _items.add(createOutThereTile()); //Out There
    while (zoomIter.moveNext()) {
      _items.add(createZoomGroupTile(zoomIter.current));
    }
    return ListView(
      children: _items,
    );
  }
}
