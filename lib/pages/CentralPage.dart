import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:together_mobile/pages/Layouts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

import '../main.dart';
import '../models/PeopleModel.dart';
import 'ColorConstants.dart';

enum ZoomPageType { MESSAGE, JOIN, CREATE, EDIT, NOJOIN }

//
/// ZoomPage
//

class CentralPage extends StatefulWidget {
  CentralPage() {}

  @override
  State<CentralPage> createState() => CentralPageState();
}

class CentralPageState extends State<CentralPage> {
  ZoomPageType pageType = ZoomPageType.JOIN;
  bool isEditClicked = false;
  String errorMessage = "";
  ZoomGroup? currentGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
      // appBar: AppBar(title: Text('Together')),
      appBar: null,
      body: Consumer<PeopleModel>(builder: (context, model, child) {
        Widget centerWidget = Container();
        if (isEditClicked) {
          pageType = ZoomPageType.EDIT;
          centerWidget = ZoomEdit(this);
          isEditClicked = false;
        } else if (model.lastClicked == null) {
          pageType = ZoomPageType.MESSAGE;
          centerWidget = Container(height: 300, width: 400,
              child: Center(
                  child: Html(data: readHTML(ZoomPageType.MESSAGE))));
        } else {
          switch (model.lastClicked.runtimeType) {
            case ZoomGroup:
              pageType = ZoomPageType.JOIN;
              currentGroup = model.lastClicked;
              centerWidget = ZoomJoin(this);
              break;
            case Group:
              if (model.lastClicked.groupType == GroupType.GATHERING) {
                pageType = ZoomPageType.MESSAGE;
                centerWidget = Container(height: 300, width: 400,
                    child: Center(
                        child: Html(data: readHTML(ZoomPageType.MESSAGE))));
              } else if (model.lastClicked.groupType == GroupType.CIRCLE) {
                pageType = ZoomPageType.NOJOIN;
                centerWidget = Container(height: 300, width: 400,
                    child: Center(
                      child: Html(data: readHTML(ZoomPageType.NOJOIN)),
                    ));
              } else {
                pageType = ZoomPageType.CREATE;
                centerWidget = ZoomCreate(this);
              }
              break;
            default:
              pageType = ZoomPageType.CREATE;
              centerWidget = ZoomCreate(this);
              break;
          }
        }
        return nebulaBackground(
          centerWidget,
        );
      }),
    );
  }

  String? validateLink(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    if (!value.contains("https://", 0)) {
      return "Zoom link must start with https://";
    }
    if (!value.contains("/j/")) {
      return "Zoom link must contain /j/";
    }
    return null;
  }
}

String readHTML(ZoomPageType type) {
  late String htmlData;
  if (type == ZoomPageType.NOJOIN) {
    htmlData = r"""
 <div style="color:white;">
<h1>Together Circle</h1>
<p>This type of circle is only available
   in the installed version of Together</p>
<p>To install go to
         https://togethersphere.com/limited/download.html</p>
         </div>
""";
  } else {
    htmlData = r"""
     <div style="color:white;">
    <h1>Welcome to Together Web</h1>
    <p>To join the Morning Circle, click on it and the Join button will appear.</p>
    </div>
    """;
  }

  return htmlData;
}

//
/// ZoomJoin
//

class ZoomJoin extends StatefulWidget {
  CentralPageState parentState;

  ZoomJoin(this.parentState);

  @override
  State<ZoomJoin> createState() => _ZoomJoinState();
}

class _ZoomJoinState extends State<ZoomJoin> {

  Widget editOrCopy() {
    if (widget.parentState.currentGroup!.createdByMe()) {
      return ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(
                  ColorConstants.primaryColor)),
          //child: Text("Copy Link"),
          child: Text("Edit"),
          onPressed: () {
            editLink();
          });
    } else {
      return ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(
                  ColorConstants.primaryColor)),
          child: Text("Copy Link"),
          onPressed: () {
            copyLink();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 110,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: Text(
                            widget.parentState.errorMessage, // error text
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                        ),
                        Container(
                            child: Text(
                              widget.parentState.currentGroup!.name,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: ColorConstants.buttonTextColor),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            ColorConstants.primaryColor)),
                    child: Text("Join on Zoom"),
                    onPressed: () {
                      magicHappens();
                    }),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 20),
                  child: editOrCopy(),
                ),
              ),
            ]));
  }

  magicHappens() async {
    String? link = widget.parentState.currentGroup!.link;
    if (link != null) {
      var url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        widget.parentState.errorMessage = 'Could not launch $url';
      }
    }
  }

  copyLink() {
    FlutterClipboard.copy(widget.parentState.currentGroup!.link!);
  }

  editLink() {
    widget.parentState.setState(() {
      widget.parentState.isEditClicked = true;
    });
  }

}

//
/// ZoomCreate
//

class ZoomCreate extends StatefulWidget {
  CentralPageState parentState;

  ZoomCreate(this.parentState);

  @override
  State<ZoomCreate> createState() {
    return ZoomCreateState();
  }
}

//
/// ZoomCreateState
//

class ZoomCreateState extends State<ZoomCreate> {
  final _formKey = GlobalKey<FormState>();
  String? circleName;
  String? circleLink;
  bool isPersistent = false;

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(padding: EdgeInsets.only(bottom: 5.0),
                    child: Text("New circle name",
                        style: TextStyle(
                            fontSize: 18, color: ColorConstants.buttonTextColor))),
                Container(width: 300,
                  child: TextFormField(
                      validator: validateName,
                      onSaved: (String? value) {
                        circleName = value;
                      },
                      maxLength: 40,
                      //enableInteractiveSelection: true,
                      // controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.0)),
                        border: const OutlineInputBorder(),
                      )),
                ),
                Container(padding: EdgeInsets.only(top: 20, bottom: 5),
                  child: Text("Zoom link",
                      style: TextStyle(
                          fontSize: 18, color: ColorConstants.buttonTextColor)),
                ),
                Container(width: 400,
                  child: TextFormField(validator: widget.parentState.validateLink,
                      onSaved: (String? value) {
                        circleLink = value;
                      },
                      enableInteractiveSelection: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.0)),
                        border: const OutlineInputBorder(),
                      )

                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(padding: EdgeInsets.only(right: 30), width: 120,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              foregroundColor: MaterialStatePropertyAll<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  ColorConstants.primaryColor)),
                          child: Text("Create",
                              style: TextStyle(fontSize: 18)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              createZoomCircle();
                            }
                          }
                        // onPressed: isEnabled ? createZoomCircle : null,
                      ),
                    ),
                    Checkbox(checkColor: Colors.black,
                        fillColor: MaterialStatePropertyAll<
                            Color>(Colors.white),
                        value: isPersistent,
                        onChanged: (bool? value) {
                          setState((){isPersistent = value!;});
                        }),
                    Text("Persistent", style: TextStyle(
                        color: ColorConstants.buttonTextColor,
                        fontSize: 16))

                  ]),
                )],
            ),
          )),
    );
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    if (value.length < 3) {
      return "Name must be at least 3 characters long";
    }
    return null;
  }




  createZoomCircle() {
    List elements = ["create-group", circleName, isPersistent, true, true, circleLink];
    connection.send(jsonEncode(elements));
    setState((){peopleModel.lastClicked = null;}); // maybe should be clearAll
  }
}


class ZoomEdit extends StatefulWidget {
  CentralPageState parentState;

  ZoomEdit(this.parentState);

  @override
  State<ZoomEdit> createState() => _ZoomEditState();
}

class _ZoomEditState extends State<ZoomEdit> {
  final _formKey = GlobalKey<FormState>();
  bool isPersistentChanged = false;
  bool? isPersistent;
  bool linkChanged = false;
  String? circleLink;


  @override
  void initState() {
    isPersistent = widget.parentState.currentGroup!.persistent;
  }

  @override
  Widget build(BuildContext context) {
    BorderSide side() {
      return const BorderSide(color: Colors.blueGrey, width: 1.0);
    }
    return Container(
        decoration: BoxDecoration(color: ColorConstants.editBoxColor,
          border: Border(
              top: side(), right: side(), bottom: side(), left: side()),
        ),
        child: SizedBox(width: 500, height: 300,
            child: Column(children: <Widget>[
              Container(
                  decoration: BoxDecoration(color: Colors.black,
                      border: Border(bottom: const BorderSide(
                          color: ColorConstants.frameColor, width: 0.0))),
                  child: SizedBox(height: 30,
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(flex: 1, child: Container()),
                            Center(child: Text("Zoom Circle Options",
                                style: TextStyle(
                                    color: ColorConstants.buttonTextColor))),
                            Flexible(flex: 1,
                                child: Align(alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: cancelChanges,
                                      child: Text("x", style: TextStyle(
                                          color: ColorConstants.buttonTextColor,
                                          fontSize: 18)),
                                    ))),
                          ])
                  )),
              Container(height: 270,
                  child: Column(children: <Widget>[
                    Flexible(flex: 1, child: Center(
                      child: Text(widget.parentState.currentGroup!.name,
                          style: TextStyle(
                              color: ColorConstants.buttonTextColor,
                              fontSize: 16)),
                    )),
                    Flexible(flex: 1, child: Container(
                        child: Align(alignment: Alignment.topLeft,
                            child: Container(
                              child: Row(
                                children: [
                                  Checkbox(checkColor: Colors.black,
                                      fillColor: MaterialStatePropertyAll<
                                          Color>(Colors.white),
                                      value: isPersistent,
                                      onChanged: (bool? value) {
                                        isPersistentChanged = true;
                                        setState((){isPersistent = value;});
                                      }),
                                  Text("Persistent", style: TextStyle(
                                      color: ColorConstants.buttonTextColor,
                                      fontSize: 16))
                                ],
                              ),
                            ))
                    )),
                    Flexible(flex: 1, child: Container(
                        child: Row(children: [
                          Container(padding: EdgeInsets.only(
                              left: 5, right: 20),
                              child: Text("Zoom Link", style: TextStyle(
                                  color: ColorConstants.buttonTextColor,
                                  fontSize: 16))),
                          Container(width: 300,
                              child: Form( key: _formKey,
                              child: TextFormField(
                                  initialValue: widget.parentState.currentGroup!.link,
                                  onChanged: (String? value) {linkChanged = true;},
                                  validator: widget.parentState.validateLink,
                                  onSaved: (String? value) {circleLink = value;},
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 0.0)),
                                    border: const OutlineInputBorder(),
                                  )
                              ))
                          )
                        ])
                    )),
                    Flexible(flex: 1, child: Container(padding: EdgeInsets.only(top:30),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    foregroundColor: MaterialStatePropertyAll<
                                        Color>(
                                        Colors.white),
                                    backgroundColor: MaterialStatePropertyAll<
                                        Color>(
                                        ColorConstants.primaryColor)),
                                child: Text("Save"),
                                onPressed: saveChanges),
                            Container(padding: EdgeInsets.only(right: 20, left: 20),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      foregroundColor: MaterialStatePropertyAll<
                                          Color>(
                                          Colors.white),
                                      backgroundColor: MaterialStatePropertyAll<
                                          Color>(
                                          ColorConstants.primaryColor)),
                                  child: Text("Cancel"),
                                  onPressed: cancelChanges),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  foregroundColor: MaterialStatePropertyAll<
                                      Color>(
                                      Colors.white),
                                  backgroundColor: MaterialStatePropertyAll<
                                      Color>(
                                      ColorConstants.primaryColor)),
                              child: Text("Delete"),
                              onPressed: deleteCircle,
                            ),
                          ],
                        )
                    )),
                  ])

              )

            ])
        )
    );
  }

  saveChanges() {
    List<String> toSend = <String>[];

    if (isPersistentChanged) {
      widget.parentState.currentGroup!.persistent = isPersistent!;
      List elements = ["change-circle-property",
        widget.parentState.currentGroup!.name,
        "persistent?",
        isPersistent];
      isPersistentChanged = false;
      toSend.add(jsonEncode(elements));
    }
    if (linkChanged) {
      if(_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        widget.parentState.currentGroup!.link = circleLink;
        List elements = ["change-circle-property",
          widget.parentState.currentGroup!.name,
          "link",
          circleLink];
        toSend.add(jsonEncode(elements));
        linkChanged = false;
      }
    }
    toSend.forEach(connection.send);
    setState((){peopleModel.lastClicked = null;}); // maybe should be clearAll
  }

  cancelChanges() {
    setState((){peopleModel.lastClicked = null;}); // maybe should be clearAll
  }

  deleteCircle() {
    List elements = ["delete-group", widget.parentState.currentGroup!.name];
    connection.send(jsonEncode(elements));
    setState((){peopleModel.lastClicked = null;}); // maybe should be clearAll
  }
}