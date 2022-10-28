import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../connection/Data.dart';
import '../main.dart';

enum PersonType { OBSERVER, PLAYER, NOTAPERSON }

enum GroupType { GROUP, CIRCLE, GROUPLESS, ZOOM }

class PeopleModel extends ChangeNotifier {
  static List<Person> allPeople = []; //TODO this should be a hashtable
  dynamic? _lastClicked;
  List<Group> groups = [];
  List<ZoomGroup> zoomGroups = [];

  Person? getDisplayedPerson(String name) {
    for (int i = 0; i < PeopleModel.allPeople.length; i++) {
      Person p = PeopleModel.allPeople[i];
      if ((p.name == name) && (p._isDisplayed)) {
        return p;
      }
    }
    return null;
  }

  void setMe(String myName) {
    if (allPeople.isNotEmpty) {
      print("Tried to recreate Me: $myName");
    } else {
      Person me = Person._createMe(myName, this);
    }
  }

  Person? get me {
    //TODO want a more reliable way to do this
    if (allPeople.isNotEmpty) {
      if (allPeople[0]._isDisplayed) {
        return allPeople[0];
      }
    }
    return null;
  }

  dynamic? get lastClicked {
    return _lastClicked;
  }

  void set lastClicked(dynamic? personOrGroup) {
    if ((personOrGroup is Person ||
        (personOrGroup is Group &&
            (personOrGroup.groupType == GroupType.GROUPLESS ||
                personOrGroup.isMyGroup)))) {
      _lastClicked = personOrGroup;
      notifyListeners();
    }
  }

  get peopleIterator {
    if (groups.isEmpty) {
      return null;
    }
    return PeopleIterator(this);
  }

  Iterator<ZoomGroup> get zoomIterator {
    return zoomGroups.iterator;
  }

  void clearAll() {
    groups.clear();
    zoomGroups.clear();
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
    groups.clear();
    zoomGroups.clear();
    var hierarchyJson = json[0];
    var groupJson = hierarchyJson[0];
    for (int i = 0; i < groupJson.length; i++) {
      if(ZoomGroup.isZoomGroup(groupJson[i])) {
        zoomGroups.add(ZoomGroup(groupJson[i]));
      } else {
        groups.add(Group(groupJson[i]));
      }
    }
  }
}

abstract class HierarchyMember {
  String get name;
}

class ZoomGroup extends HierarchyMember {
  GroupType groupType = GroupType.CIRCLE;
  String? groupName;
  String? owner;
  bool isZoom = true;
  String? link;

  bool isMyGroup = false;

  static bool isZoomGroup(dynamic json) {
    return json[6] as bool;
  }

  ZoomGroup(dynamic json) {
    groupName = json[0];

    if (json[1] is String) owner = json[1];
    isZoom = json[6];
    if (json[7] is String) link = json[7];
  }

  @override
  String get name {
    return groupName ?? "No Name";
  }
}

class Group extends HierarchyMember {
  GroupType groupType = GroupType.GROUPLESS;
  int? groupNo;
  String? groupName;
  String? owner;
  bool requireMicrophone = true;
  bool requireCamera = true;
  bool isZoom = false;
  String? link;

  //bool audioOnly = true;
  String? zone;

  List<Person> members = [];
  bool isMyGroup = false;

  Group(dynamic json) {
    var nameOrNumber = json[0];
    if (nameOrNumber is int) {
      groupNo = nameOrNumber;
      groupType = GroupType.GROUP;
    } else if (nameOrNumber is String) {
      groupName = nameOrNumber;
      groupType = GroupType.CIRCLE;
    } else {
      groupType = GroupType.GROUPLESS;
      groupName = "The gathering";
    }
    if (json[1] is String) owner = json[1];
    requireMicrophone = json[2];
    requireCamera = json[3];
    if (json[4] is String) zone = json[4];
    //5 is the meeting stone
    isZoom = json[6];
    if (json[7] is String) link = json[7];
    for (int i = 8; i < json.length; i++) {
      Person person = Person._createPerson(json[i], peopleModel);
      person.inGroup = groupType == GroupType.GROUPLESS ? false : true;
      if (person.isMe()) isMyGroup = true;
      members.add(person);
    }
    // If this is a group I am in, mark each member and move me to top
    if (isMyGroup) {
      members.forEach((member) {
        member.inMyGroup = groupType == GroupType.GROUPLESS ? false : true;
        if (member.isMe()) {
          members.remove(member);
          members.insert(0, member);
        }
      });
    }
    ;
  }

  @override
  String get name {
    return groupName ?? groupNo.toString() ?? "No Name";
  }
}

// TODO check with G about getting 7 args instead of 6
class Person extends HierarchyMember {
  bool _isDisplayed = false;
  bool inGroup = false;
  String name = "unknown";
  String? id = null;
  int? no;
  bool verified = false;
  bool disconnected = false;
  bool roaming = false;
  bool asleep = false;
  String? zone;
  String? mode;
  bool isMobile = false;

  //PersonType? type;
  bool inMyGroup = false;
  PeopleModel peopleModel;

  Person(dynamic json, this.peopleModel) {
    name = json[0];
    if (json.length > 1) {
      refresh(json);
    }
  }

  void refresh(dynamic json) {
    _isDisplayed = true;
    inMyGroup = false;
    //1 is id
    no = json[2];
    verified = json[3];
    asleep = json[4];
    disconnected = json[5];
    roaming = json[6];
    if (json[7] is String) zone = json[7];
    mode = json[8];
    isMobile = json[9];

    //if ((json.length > 5) && (json[5] is PersonType)) type = json[5];
  }

  static Person _createPerson(dynamic json, PeopleModel model) {
    for (int i = 0; i < PeopleModel.allPeople.length; i++) {
      Person p = PeopleModel.allPeople[i];
      if (p.name == json[0]) {
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
    assert(name != null);

    peopleModel.lastClicked = this;
  }

  List<String> get snackBarList {
    return [];
  }
}

class PeopleIterator extends Iterator {
  List masterList = [];
  late Iterator iterator;

  PeopleIterator(model) {
    model.groups.forEach((group) {
      //if (group.groupType == GroupType.CIRCLE)
      masterList.add(group);
      group.members.forEach((member) {
        masterList.add(member);
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
}
