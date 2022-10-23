import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../connection/Data.dart';
import '../main.dart';

enum PersonType { OBSERVER, PLAYER, NOTAPERSON }

enum GroupType { GROUP, CIRCLE, GROUPLESS }

class PeopleModel extends ChangeNotifier {
  static List<Person> allPeople = [];
  Person? _lastClicked;
  bool _lastClickedDirty = false;
  bool _lastClickedNew = false;
  List<Group> groups = [];

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
    if (allPeople.isNotEmpty) {
      if (allPeople[0]._isDisplayed) {
        return allPeople[0];
      }
    }
    return null;
  }

  bool get lastClickedNew {
    if (_lastClickedNew) {
      _lastClickedNew = false;
      return true;
    } else {
      return false;
    }
  }

  Person? get lastClicked {
    return _lastClicked;
  }

  void set lastClicked(Person? person) {
    _lastClicked = person;
    _lastClickedNew = true;
    notifyListeners();
  }

  get peopleIterator {
    if (groups.isEmpty) {
      return null;
    }
    return PeopleIterator(this);
  }

  void clearAll() {
    groups.clear();
    _lastClicked = null;
    _lastClickedDirty = false;
    _lastClickedNew = false;
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
    _lastClickedDirty = true;
    groups.clear();
    var hierarchyJson = json[0];
    var groupJson = hierarchyJson[0];
    for (int i = 0; i < groupJson.length; i++) {
      groups.add(Group(groupJson[i]));
    }
    if (_lastClickedDirty) {
      _lastClicked = null;
      _lastClickedDirty = false;
    }
  }
}

abstract class HierarchyMember {
  String get name;
}

class Group extends HierarchyMember {
  GroupType groupType = GroupType.GROUPLESS;
  int? groupNo;
  String? groupName;
  bool audioOnly = true;
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
    }
    audioOnly = json[1];
    if (json[2] is String) zone = json[2];
    for (int i = 5; i < json.length; i++) { //NOTE changed from 3 to 5
      Person person = Person._createPerson(json[i], peopleModel);
      if (person.isMe()) isMyGroup = true;
      if (person == peopleModel._lastClicked)
        peopleModel._lastClickedDirty = false;
      members.add(person);
    }
    // If this is a group I am in, mark each member and move me to top
    if ((groupType != GroupType.GROUPLESS) && isMyGroup) {
      members.forEach((member) {
        member.inMyGroup = true;
        if (member.isMe()) {
          members.remove(member);
          members.insert(0, member);
        }
      });
    }
  }

  bool get isGroupless {
    if ((groupNo == null) && (groupName == null)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  String get name {
    return groupName ?? groupNo.toString() ?? "No Name";
  }
}

// TODO check with G about getting 7 args instead of 6
class Person extends HierarchyMember {
  bool _isDisplayed = false;
  String name = "unknown";
  int? no;
  bool disconnected = false;
  bool asleep = false;
  String? zone;
  PersonType? type;
  bool inMyGroup = false;
  PeopleModel peopleModel;

  Person(dynamic json, this.peopleModel) {
    name = json[0];
    refresh(json);
  }

  void refresh(dynamic json) {
    _isDisplayed = true;
    inMyGroup = false;
    if ((json.length > 1) && (json[1] is int)) no = json[1];
    if ((json.length > 2) && (json[2] is bool)) disconnected = json[2];
    if ((json.length > 3) && (json[3] is bool)) asleep = json[3];
    if ((json.length > 4) && (json[4] is String)) zone = json[4];
    if ((json.length > 5) && (json[5] is PersonType)) type = json[5];
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
    // for now make sure you can't send to yourself
    // if (!isMe()) peopleModel.lastClicked = this;
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
      if (group.groupType == GroupType.CIRCLE) masterList.add(group);
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
