import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    } else if (peopleNode is Person) {
      _tabController?.index = 1; // Send message to this person
      textFocusNode.requestFocus(null);
    } else if ((peopleNode is Group) && (peopleNode.groupType == GroupType.GATHERING)) {
      _tabController?.index = 1; // send message to The gathering
      textFocusNode.requestFocus(null);
    } else if (peopleNode is Groupless) {
      _tabController?.index = 2; // Create Zoom circle
    }
  }

  Widget createTile(HierarchyMember node) {
    String name = node.name;

    double getIndent() {
      if ((node is Person) ||
          (node is ZoomGroup)) {
        return 32;
      } else {
        return 16;
      }
    }

    Color getColor() {
      if (node is Groupless) {
        return ColorConstants.gatheringColor;
      } else if (node is Person) {
        return ColorConstants.observerColor;
      } else if ((node is Group) && (node.groupType == GroupType.GATHERING)) {
        return ColorConstants.gatheringColor;
      } else {
        return ColorConstants.groupColor;
      }
    }

    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              tilePressed(node);
            },
            child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: getIndent()),
                title: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: getColor(),
                  ),
                ))));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _items = <Widget>[];
    PeopleIterator? iter = peopleModel.peopleIterator;
    Iterator zoomIter = peopleModel.zoomIterator;
    if (iter != null) {
      while (iter.moveNext()) {
        HierarchyMember item = iter.current;
        _items.add(createTile(item));
      };
    };
    _items.add(createTile(Groupless("Out there"))); // Out there
    while (zoomIter.moveNext()) {
      _items.add(createTile(zoomIter.current));
    }
    return ListView(
      children: _items,
    );
  }
}
