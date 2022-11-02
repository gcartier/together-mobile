import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/PeopleModel.dart';
import 'ColorConstants.dart';

//
/// People
//

class People extends StatefulWidget {
  TabController? _tabController;

  People([TabController? t]) {
    _tabController = t;
  }

  @override
  State<People> createState() {
    return PeopleState(_tabController);
  }
}

//
/// PeopleState
//

class PeopleState extends State<People> {
  TabController? _tabController;

  PeopleState(this._tabController) {}

  tilePressed(dynamic peopleNode) {
    if (peopleModel != null) {
      peopleModel.lastClicked = peopleNode;
    }
    if (peopleNode is ZoomGroup) {
      _tabController?.index = 2; // join Zoom goup
    } else if ((peopleNode is Person) ||
        ((peopleNode is Group) &&
            (peopleNode.groupType == GroupType.GROUPLESS))) {
      _tabController?.index = 1; // Send message to this person
      textFocusNode.requestFocus(null);
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
    String name = "Out there";
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

  Widget createZoomGroupTile(ZoomGroup zoomGroup) {
    String name = zoomGroup.name ?? "NO NAME";
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              tilePressed(zoomGroup);
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
    } else if (person.isMobile) {
      name = "${person.name} (web)";
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
    _items.add(createOutThereTile()); // Out there
    while (zoomIter.moveNext()) {
      _items.add(createZoomGroupTile(zoomIter.current));
    }
    return ListView(
      children: _items,
    );
  }
}
