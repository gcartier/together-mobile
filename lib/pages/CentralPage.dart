import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:flutter/gestures.dart';
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
  String? errorMessage;
  Group? currentGroup;
  String? url;
  String? lastClickedName;
  NodeType? lastClickedNodeType;
  bool createdByMe = false;
  String? description;

  /* Widget goSomewhere() {
    return Container();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.transparent,
      // appBar: AppBar(title: Text('Together')),
      appBar: null,
      body: Consumer<PeopleModel>(builder: (context, model, child) {
        var lastClicked = model.lastClicked;
        lastClickedName = lastClicked?.memberName;
        description = lastClicked?.description;
        String title = lastClickedName ?? "";
        lastClickedNodeType = lastClicked?.nodeType;
        if (lastClicked is Group) {
          url = lastClicked.link;
          createdByMe = lastClicked.createdByMe();
        }
        Widget centerWidget = Container();
        if (lastClicked?.nodeType == NodeType.PERSON) {
          pageType = ZoomPageType.MESSAGE;
          centerWidget = Container(
              height: 300,
              width: 400,
              child: Center(
                  child:
                      SelectableHtml(data: DisplayHTML(ZoomPageType.MESSAGE))));
        } else {
          switch (lastClickedNodeType) {
            case NodeType.ZOOM_CIRCLE:
              if (lastClicked is Group) currentGroup = lastClicked;
              centerWidget = GoSomewhere(this, title, url, NodeType.ZOOM_CIRCLE,
                  createdByMe, errorMessage, description);
              //centerWidget = goSomewhere();
              break;
            case NodeType.TOGETHER_CIRCLE:
              centerWidget = GoSomewhere(
                  this,
                  title,
                  url,
                  NodeType.TOGETHER_CIRCLE,
                  createdByMe,
                  errorMessage,
                  description);
              //centerWidget = goSomewhere();
              break;
            case NodeType.TOGETHER:
              centerWidget = GoSomewhere(this, title, "together:",
                  NodeType.TOGETHER, createdByMe, errorMessage, description);
              //centerWidget = goSomewhere();
              break;
            case null:
            case NodeType.GATHERING:
            default:
              centerWidget = ZoomCreate(this);
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

String DisplayHTML(ZoomPageType type) {
  late String htmlData;
  if (type == ZoomPageType.NOJOIN) {
    htmlData = r"""
 <div style="color:white; font:helvetica;">
<h1>Together Circle</h1>
<p>This circle is happening
   in the installed version of Together</p>
<p>To install go to
         <a href="https://togethersphere.com/limited/download.html">https://togethersphere.com/limited/download.html</a></p>
         </div>
""";
  } else {
    htmlData = r"""
     <div style="color:white; font:helvetica;">
    <h1>Welcome to Together</h1>
    <p>To join the Morning Circle, click on it and a Join on Zoom button will appear in the center.</p>
    </div>
    """;
  }

  return htmlData;
}

//
/// ZoomJoin
//

class GoSomewhere extends StatefulWidget {
  CentralPageState parentState;
  String title;
  String? url;
  NodeType nodeType;
  bool createdByMe;
  String? errorMessage;
  String? description;

  GoSomewhere(this.parentState, this.title, this.url, this.nodeType,
      this.createdByMe, this.errorMessage, this.description);

  @override
  State<GoSomewhere> createState() => _GoSomewhereState();
}

class _GoSomewhereState extends State<GoSomewhere> {
  Widget description() {
    var composedText = <TextSpan>{};
    if (widget.parentState.description != null) {
      composedText.add(TextSpan(
        text: widget.parentState.description!,
        style: TextStyle(fontStyle: FontStyle.italic),
      ));
      composedText.add(TextSpan(text: "\n\n"));
    }
    ;
    switch (widget.nodeType) {
      case NodeType.TOGETHER_CIRCLE:
      case NodeType.TOGETHER:
        composedText.add(TextSpan(
          text: "To install Together, go to:\n",
        ));
        composedText.add(TextSpan(
            text: "https://togethersphere.com/limited/download.html",
            style: TextStyle(
              color: ColorConstants.linkColor,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                magicHappens(
                    "https://togethersphere.com/limited/download.html");
              }));
    }
    ;
    return Container(
        padding: EdgeInsets.only(bottom: 40, left: 10, right: 10),
        child: RichText(
            text: TextSpan(
                //softWrap: true,
                children: composedText.toList(),
                style: TextStyle(
                  fontSize: 16,
                  color: ColorConstants.messageContentColor,
                ))));
  }

  Widget goButton() {
    switch (widget.nodeType) {
      case NodeType.TOGETHER:
        return ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    ColorConstants.primaryColor)),
            child: Text("Launch Together",
                style: TextStyle(
                  fontSize: 17,
                )),
            onPressed: () {
              magicHappens("togethersphere:");
            });
      case NodeType.TOGETHER_CIRCLE:
        return ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    ColorConstants.primaryColor)),
            child: Text("Join on Together",
                style: TextStyle(
                  fontSize: 17,
                )),
            onPressed: () {
              magicHappens(widget.url);
            });
      case NodeType.ZOOM_CIRCLE:
        return ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    ColorConstants.primaryColor)),
            child: Text("Join on Zoom",
                style: TextStyle(
                  fontSize: 17,
                )),
            onPressed: () {
              magicHappens(widget.url);
            });
      default:
        return Container();
    }
  }

  Widget editOrCopy() {
    if (widget.createdByMe) {
      return ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll<Color>(ColorConstants.primaryColor)),
          child: Text("Edit"),
          onPressed: () {
            editLink();
          });
    } else {
      return ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll<Color>(ColorConstants.primaryColor)),
          child: Text("Copy Link"),
          onPressed: () {
            copyLink();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                width: 200,
                backgroundColor: ColorConstants.highlightColor,
                content: Text("link copied to clipboard")));
          });
    }
  }

  magicHappens(String? link) async {
    //String? link = widget.parentState.currentGroup!.link;
    if (link != null) {
      var url = Uri.parse(link);
      if (await launchUrl(url)) {
      } else {
        widget.parentState.errorMessage = 'Could not launch $url';
      }
    }
  }

  Widget showError() {
    if (widget.errorMessage != null) {
      return Center(
          child: Text(
            widget.errorMessage!,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ));
    } else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.bottomCenter,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(child:
            showError()), // error text
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(widget.title,
                      style: TextStyle(
                          fontSize: 22, color: ColorConstants.buttonTextColor),
                    ),
            ),
                  description(),
          Container(child: goButton()),
          Expanded(child:
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 100),
            child: editOrCopy(),
          )),
        ]));
  }

  copyLink() {
    switch(widget.nodeType) {
      case NodeType.TOGETHER:
        FlutterClipboard.copy("togethersphere:");
        break;
      case NodeType.TOGETHER_CIRCLE:
      case NodeType.ZOOM_CIRCLE:
        if (widget.url != null) {
          FlutterClipboard.copy(widget.url!);
        }
    }
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
            Container(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text("New circle name",
                    style: TextStyle(
                        fontSize: 18, color: ColorConstants.buttonTextColor))),
            Container(
              width: 300,
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
                    isDense: true,
                    enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.0)),
                    border: const OutlineInputBorder(),
                  )),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 5),
              child: Text("Zoom link",
                  style: TextStyle(
                      fontSize: 18, color: ColorConstants.buttonTextColor)),
            ),
            Container(
              width: 400,
              child: TextFormField(
                  validator: widget.parentState.validateLink,
                  onSaved: (String? value) {
                    circleLink = value;
                  },
                  enableInteractiveSelection: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    isDense: true,
                    enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.0)),
                    border: const OutlineInputBorder(),
                  )),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.only(right: 30),
                  width: 120,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStatePropertyAll<Color>(Colors.white),
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              ColorConstants.primaryColor)),
                      child: Text("Create", style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          createZoomCircle();
                        }
                      }
                      // onPressed: isEnabled ? createZoomCircle : null,
                      ),
                ),
                Checkbox(
                    checkColor: Colors.black,
                    fillColor: MaterialStatePropertyAll<Color>(Colors.white),
                    value: isPersistent,
                    onChanged: (bool? value) {
                      setState(() {
                        isPersistent = value!;
                      });
                    }),
                Text("Persistent",
                    style: TextStyle(
                        color: ColorConstants.buttonTextColor, fontSize: 16))
              ]),
            )
          ],
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
    List elements = [
      "create-group",
      circleName,
      isPersistent,
      true,
      true,
      circleLink
    ];
    connection.send(jsonEncode(elements));
    setState(() {
      peopleModel.lastClicked = null;
    }); // maybe should be clearAll
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
        decoration: BoxDecoration(
          color: ColorConstants.editBoxColor,
          border:
              Border(top: side(), right: side(), bottom: side(), left: side()),
        ),
        child: SizedBox(
            width: 500,
            height: 300,
            child: Column(children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border(
                          bottom: const BorderSide(
                              color: ColorConstants.frameColor, width: 0.0))),
                  child: SizedBox(
                      height: 30,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(flex: 1, child: Container()),
                            Center(
                                child: Text("Zoom Circle Options",
                                    style: TextStyle(
                                        color:
                                            ColorConstants.buttonTextColor))),
                            Flexible(
                                flex: 1,
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: cancelChanges,
                                      child: Text("x",
                                          style: TextStyle(
                                              color: ColorConstants
                                                  .buttonTextColor,
                                              fontSize: 18)),
                                    ))),
                          ]))),
              Container(
                  height: 270,
                  child: Column(children: <Widget>[
                    Flexible(
                        flex: 1,
                        child: Center(
                          child: Text(
                              widget.parentState.currentGroup!.memberName,
                              style: TextStyle(
                                  color: ColorConstants.buttonTextColor,
                                  fontSize: 16)),
                        )),
                    Flexible(
                        flex: 1,
                        child: Container(
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                          checkColor: Colors.black,
                                          fillColor:
                                              MaterialStatePropertyAll<Color>(
                                                  Colors.white),
                                          value: isPersistent,
                                          onChanged: (bool? value) {
                                            isPersistentChanged = true;
                                            setState(() {
                                              isPersistent = value;
                                            });
                                          }),
                                      Text("Persistent",
                                          style: TextStyle(
                                              color: ColorConstants
                                                  .buttonTextColor,
                                              fontSize: 16))
                                    ],
                                  ),
                                )))),
                    Flexible(
                        flex: 1,
                        child: Container(
                            child: Row(children: [
                          Container(
                              padding: EdgeInsets.only(left: 5, right: 20),
                              child: Text("Zoom Link",
                                  style: TextStyle(
                                      color: ColorConstants.buttonTextColor,
                                      fontSize: 16))),
                          Container(
                              width: 300,
                              child: Form(
                                  key: _formKey,
                                  child: TextFormField(
                                      initialValue:
                                          widget.parentState.currentGroup!.link,
                                      onChanged: (String? value) {
                                        linkChanged = true;
                                      },
                                      validator:
                                          widget.parentState.validateLink,
                                      onSaved: (String? value) {
                                        circleLink = value;
                                      },
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        enabledBorder: const OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.grey,
                                                width: 0.0)),
                                        border: const OutlineInputBorder(),
                                      ))))
                        ]))),
                    Flexible(
                        flex: 1,
                        child: Container(
                            padding: EdgeInsets.only(top: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStatePropertyAll<Color>(
                                                Colors.white),
                                        backgroundColor:
                                            MaterialStatePropertyAll<Color>(
                                                ColorConstants.primaryColor)),
                                    child: Text("Save"),
                                    onPressed: saveChanges),
                                Container(
                                  padding: EdgeInsets.only(right: 20, left: 20),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStatePropertyAll<Color>(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStatePropertyAll<Color>(
                                                  ColorConstants.primaryColor)),
                                      child: Text("Cancel"),
                                      onPressed: cancelChanges),
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStatePropertyAll<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStatePropertyAll<Color>(
                                              ColorConstants.primaryColor)),
                                  child: Text("Delete"),
                                  onPressed: deleteCircle,
                                ),
                              ],
                            ))),
                  ]))
            ])));
  }

  saveChanges() {
    List<String> toSend = <String>[];

    if (isPersistentChanged) {
      widget.parentState.currentGroup!.persistent = isPersistent!;
      List elements = [
        "change-circle-property",
        widget.parentState.currentGroup!.memberName,
        "persistent?",
        isPersistent
      ];
      isPersistentChanged = false;
      toSend.add(jsonEncode(elements));
    }
    if (linkChanged) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        widget.parentState.currentGroup!.link = circleLink;
        List elements = [
          "change-circle-property",
          widget.parentState.currentGroup!.memberName,
          "link",
          circleLink
        ];
        toSend.add(jsonEncode(elements));
        linkChanged = false;
      }
    }
    toSend.forEach(connection.send);
    setState(() {
      peopleModel.lastClicked = null;
    }); // maybe should be clearAll
  }

  cancelChanges() {
    setState(() {
      peopleModel.lastClicked = null;
    }); // maybe should be clearAll
  }

  deleteCircle() {
    List elements = [
      "delete-group",
      widget.parentState.currentGroup!.memberName
    ];
    connection.send(jsonEncode(elements));
    setState(() {
      peopleModel.lastClicked = null;
    }); // maybe should be clearAll
  }
}
