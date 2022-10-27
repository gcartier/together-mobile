import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/PeopleModel.dart';
import 'ColorConstants.dart';

class People extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> _items = <Widget>[];
    PeopleIterator? iter = peopleModel.peopleIterator;

    Widget _buildGroupRow(Group group) {
      String name = group.name ?? "NO NAME";
      return ListTile(
        title: Text(
          name,
          style: TextStyle(
              fontSize: 18.0,
              color: group.groupType == GroupType.GROUPLESS
                  ? ColorConstants.gatheringColor
                  : ColorConstants.groupColor),
        ),
      );
    }

    Widget _buildPersonRow(Person person) {
      String name;
      double indent = person.inGroup ? 32 : 16; // 16 is default
      if (person.inMyGroup) {
        name = "<${person.name}>";
      } else {
        name = person.name;
      }
      return ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: indent),
        title: Text(
          name,
          style: TextStyle(fontSize: 18.0, color: ColorConstants.observerColor),
        ),
        onTap: () {
          tilePressed(person);
        },
      );
    }

    if (iter == null) {
      return Container();
    } else {
      while (iter.moveNext()) {
        HierarchyMember item = iter.current;
        if (item is Group) {
          Group group = item as Group;
          _items.add(Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  (group.groupType == GroupType.GROUPLESS)
                      ? tilePressed(group)
                      : joinCircle(group);
                },
                child: _buildGroupRow(group),
              )));
        } else if (item is Person) {
          Person person = item as Person;
          _items.add(
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  person.personClicked();
                },
                onLongPress: () {
                  messageModel.sendInvite(person);
                },
                child: _buildPersonRow(person),
              ),
            ),
          );
        }
        ;
      }
      return ListView(
        children: _items,
      );
    }
  }

  tilePressed(dynamic personOrGathering) {
    if (peopleModel != null) {
      peopleModel.lastClicked = personOrGathering;
    }
  }

  void joinCircle(Group group) {}
}
