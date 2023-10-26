import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../connection/Data.dart';
import '../settings.dart';
import '../main.dart';

enum GroupType { TOGETHER_CIRCLE, AUDIO, NOTAGROUP }

enum NodeType {
  PERSON,
  ZOOM_CIRCLE,
  TOGETHER_CIRCLE,
  GATHERING,
  TOGETHER,
  SEPARATOR
}

//
/// PeopleModel
//

class PeopleModel extends ChangeNotifier {
  static List<Person> allPeople = []; // TODO this should be a hashtable
  HierarchyMember? _lastClicked;
  List<Group> togetherCircles = [];
  List<ZoomCircle> zoomCircles = [];
  List<Person> gatheringPeople = [];

  Person? getDisplayedPerson(String personName) {
    for (int i = 0; i < PeopleModel.allPeople.length; i++) {
      Person p = PeopleModel.allPeople[i];
      if ((p.memberName == personName) && (p._isDisplayed)) {
        return p;
      }
    }
    return null;
  }

  void setMe(String myName) {
    if (allPeople.isNotEmpty) {
      if (debugMobile) print("Tried to recreate Me: $myName");
    } else {
      Person me = Person._createMe(myName, this);
    }
  }

  Person? get me {
    // TODO want a more reliable way to do this
    if (allPeople.isNotEmpty) {
      if (allPeople[0]._isDisplayed) {
        return allPeople[0];
      }
    }
    return null;
  }

  HierarchyMember? get lastClicked {
    return _lastClicked;
  }

  void set lastClicked(HierarchyMember? clickable) {
    _lastClicked = clickable;
    notifyListeners();
  }

  void gatheringAddPeople(List<Person> gatheringList, dynamic json) {
    for (int i = 11; i < json.length; i++) {
      Person person = Person._createPerson(json[i], peopleModel);
      person.inTogetherGroup = false;
      gatheringList.add(person);
    }
    ;
  }

  Iterator<HierarchyMember> treeIterator() {
    List<HierarchyMember> masterList = [];
    Iterator<ZoomCircle> z = zoomCircles.iterator;
    while (z.moveNext()) {
      masterList.add(z.current);
    }
    masterList.add(Separator());
    masterList.add(SectionHeading("The gathering", NodeType.GATHERING));
    Iterator<Person> g = gatheringPeople.iterator;
    while (g.moveNext()) {
      Person person = g.current;
      if (!person.inTogetherGroup) {
        masterList.add(g.current);
      }
    }
    masterList.add(Separator());
    masterList.add(SectionHeading("Together", NodeType.TOGETHER));
    Iterator<Group> t = togetherCircles.iterator;
    while (t.moveNext()) {
      Group group = t.current;
      masterList.add(group);
      Iterator<Person> members = group.members.iterator;
      while (members.moveNext()) {
        masterList.add(members.current);
      }
    }
    return masterList.iterator;
  }

  void clearAll() {
    togetherCircles.clear();
    zoomCircles.clear();
    _lastClicked = null;
    PeopleModel.allPeople.forEach((element) {
      element._isDisplayed = false;
    });
  }

  void somethingChanged(DataParser changeProvider) {
    if (!connection.isConnected) {
      clearAll();
    } else {
      List people = changeProvider.peopleList;
      if (people.isNotEmpty) {
        buildHierarchy(people);
        changeProvider.clearPeople();
      }
    }
    notifyListeners();
  }

  buildHierarchy(dynamic json) {
    togetherCircles.clear();
    zoomCircles.clear();
    gatheringPeople.clear();

    var hierarchyJson = json[0];
    var groupJson = hierarchyJson[0];
    for (int i = 0; i < groupJson.length; i++) {
      if (Group.isGathering(groupJson[i]) || Group.isAudioGroup(groupJson[i])
      )
      {
        gatheringAddPeople(gatheringPeople, groupJson[i]);
      } else if (Group.isZoomGroup(groupJson[i])) {
        zoomCircles.add(ZoomCircle(groupJson[i]));
      } else {
        togetherCircles.add(Group(groupJson[i], NodeType.TOGETHER_CIRCLE));
      }
    }
  }
}

abstract class HierarchyMember {
  String memberName = "";
  String? description;
  NodeType nodeType = NodeType.GATHERING;

  HierarchyMember();

  HierarchyMember.n(this.nodeType);
}

class SectionHeading extends HierarchyMember {
  SectionHeading(String sectionName, NodeType nodeType) : super.n(nodeType) {
    memberName = sectionName;
  }
}

class Separator extends HierarchyMember {
  Separator() : super.n(NodeType.SEPARATOR);
}

class Group extends HierarchyMember {
  //GroupType groupType = GroupType.NOTAGROUP;
  int? groupNo;

  //String? groupName;
  String? owner;
  bool inviteOnly = false;
  bool persistent = false;
  bool requireMicrophone = true;
  bool requireCamera = true;
  bool isZoom = false;
  String? link;

  // bool audioOnly = true;
  String? zone;

  List<Person> members = [];
  bool isMyGroup = false;

  Iterator<Person> membersIterator() {
    return members.iterator;
  }

  static bool isZoomGroup(dynamic json) {
    return json[8] as bool;
  }

  static bool isGathering(dynamic json) {
    if (json[0] != false) {
      return false;
    }
    return true;
  }

  static bool isAudioGroup(dynamic json) {
    if (json[0] is int)
      return true;
    else
      return false;
  }

  Group(dynamic json, NodeType nodeType) : super.n(nodeType) {
    var nameOrNumber = json[0];
    if (json[1] is String) owner = json[1];
    persistent = json[2];
    inviteOnly = json[3];
    requireMicrophone = json[4];
    requireCamera = json[5];
    if (json[6] is String) zone = json[6];
    // 7 is the meeting stone
    isZoom = json[8];
    if (json[9] is String) link = json[9];
    if (json[10] is String) description = json[10];
    if (nameOrNumber is int) {
      groupNo = nameOrNumber;
    } else if (nameOrNumber is String) {
      memberName = nameOrNumber;
    }

    for (int i = 11; i < json.length; i++) {
      Person person = Person._createPerson(json[i], peopleModel);
      person.inTogetherGroup =
          (nodeType == NodeType.TOGETHER_CIRCLE) ? true : false;
      if (person.isMe()) isMyGroup = true;
      members.add(person);
    }
    // If this is a group I am in, mark each member and move me to top
    if (isMyGroup) {
      members.forEach((member) {
        member.inMyGroup = true;
        if (member.isMe()) {
          members.remove(member);
          members.insert(0, member);
        }
      });
    }
    ;
  }

  bool createdByMe() {
    String? key = localStorage?.getString('personal_key') ?? null;
    if (owner != null && owner == key) {
      return true;
    }
    return false;
  }
}

class ZoomCircle extends Group {
  ZoomCircle(dynamic json) : super(json, NodeType.ZOOM_CIRCLE);
  bool isZoom = true;
}

//
/// Person
//

// TODO check with G about getting 7 args instead of 6
class Person extends HierarchyMember {
  bool _isDisplayed = false;
  bool inTogetherGroup = false;
  String? id = null;
  int? no;
  bool verified = false;
  bool disconnected = false;
  bool asleep = false;
  String? zone;
  String? mode;
  bool isMobile = false;

  // PersonType? type;
  bool inMyGroup = false;
  PeopleModel peopleModel;
  Group? group;

  Person(dynamic json, this.peopleModel) : super.n(NodeType.PERSON) {
    memberName = json[0];
    if (json.length > 1) {
      refresh(json);
    }
  }

  void refresh(dynamic json) {
    _isDisplayed = true;
    inMyGroup = false;
    // 1 is id
    no = json[2];
    verified = json[3];
    asleep = json[4];
    disconnected = json[5];
    if (json[6] is String) zone = json[6];
    mode = json[7];
    isMobile = json[8];

    // if ((json.length > 5) && (json[5] is PersonType)) type = json[5];
  }

  static Person _createPerson(dynamic json, PeopleModel model) {
    for (int i = 0; i < PeopleModel.allPeople.length; i++) {
      Person p = PeopleModel.allPeople[i];
      if (p.memberName == json[0]) {
        p.refresh(json);
        return p;
      }
    }
    PeopleModel.allPeople.add(Person(json, model));
    return PeopleModel.allPeople.last;
  }

  static Person _createMe(String myName, PeopleModel model) {
    assert(PeopleModel.allPeople.isEmpty);
    return _createPerson([myName], model);
  }

  bool isMe() {
    if (PeopleModel.allPeople[0] == this) {
      return true;
    } else {
      return false;
    }
  }

  void personClicked() {
    assert(_isDisplayed);
    assert(!disconnected);
    assert(memberName != null);

    peopleModel.lastClicked = this;
  }

  List<String> get snackBarList {
    return [];
  }
}

//
/// PeopleIterator
//
/*
class PeopleIterator extends Iterator {
  List<HierarchyMember> masterList = [];
  late Iterator iterator;

  PeopleIterator(model) {
    model.togetherCircles.forEach((group) {
      // if (group.groupType == GroupType.CIRCLE)
      masterList.add(group);
      group.members.forEach((member) {
        masterList.add(member);
        if (member is Person) {
          member.group = group;
        }

      });
    });
    iterator = masterList.iterator;
  }

  @override
  get current {
    if (iterator == null) {
      return false;
    } else
      return iterator.current;
  }

  @override
  bool moveNext() {
    if (iterator == null) {
      return false;
    } else
      return iterator.moveNext();
  }
}*/
