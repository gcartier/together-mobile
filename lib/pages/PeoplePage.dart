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

  tilePressed(HierarchyMember peopleNode) {
    if (peopleModel != null) {
      peopleModel.lastClicked = peopleNode;
    }
    switch (peopleNode.nodeType) {
      case NodeType.ZOOM_CIRCLE:
        _tabController?.index = 2; // join Zoom goup
        break;
      case NodeType.PERSON:
        _tabController?.index = 1; // Send message to this person
        textFocusNode.requestFocus(null);
        break;
      case NodeType.GATHERING:
        _tabController?.index = 1; // send message to The gathering
        textFocusNode.requestFocus(null);
        break;
      case NodeType.TOGETHER:
        _tabController?.index = 2; // join Together
        break;
      default:
        _tabController?.index = 2;
    }
  }

  Widget createTile(HierarchyMember node, {noTap = false}) {
    String getName() {
      return node.memberName;
    }

    double getIndent() {
      switch (node.nodeType) {
        case NodeType.PERSON:
          if (node is Person && node.inTogetherGroup) {
            return 40;
          } else
            return 8;
        case NodeType.TOGETHER_CIRCLE:
          return 24;
        case NodeType.ZOOM_CIRCLE:
          return 8;
        default:
          return 0;
      }
    }

    Color getColor() {
      switch (node.nodeType) {
        case NodeType.GATHERING:
        case NodeType.TOGETHER:
          return ColorConstants.gatheringColor;
        case NodeType.ZOOM_CIRCLE:
        case NodeType.TOGETHER_CIRCLE:
          return ColorConstants.groupColor;
        case NodeType.PERSON:
        default:
          return ColorConstants.observerColor;
      }
    }

    return noTap
        ? ListTile(
            dense: true,
            minVerticalPadding: 0,
            visualDensity: VisualDensity(vertical: -4.0),
          )
        : Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () {
                  tilePressed(node);
                },
                child: ListTile(
                    mouseCursor: SystemMouseCursors.click,
                    dense: true,
                    visualDensity: VisualDensity(vertical: -4.0),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: getIndent()),
                    minVerticalPadding: 0,
                    title: Text(
                      getName(),
                      style: TextStyle(
                        fontSize: 18.0,
                        color: getColor(),
                      ),
                    ))));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _items = <Widget>[];
    Iterator<HierarchyMember> iter = peopleModel.treeIterator();
    //Iterator zoomIter = peopleModel.zoomIterator;
    void separator(HierarchyMember node) {
      _items.add(createTile(node, noTap: true)); // Separator
    }
    //_items.add(createTile(Groupless("Web"))); // Out there
    while (iter.moveNext()) {
      _items.add(createTile(iter.current));
    }
    return ListView(
      children: _items,
    );
  }
}
