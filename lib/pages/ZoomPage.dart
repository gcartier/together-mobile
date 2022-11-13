import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:together_mobile/pages/Layouts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

import '../main.dart';
import '../models/PeopleModel.dart';
import 'ColorConstants.dart';

enum ZoomPageType { JOIN, CREATE, EDIT, NOJOIN }

//
/// ZoomPage
//

class ZoomPage extends StatefulWidget {
  ZoomPage() {}

  @override
  State<ZoomPage> createState() => ZoomPageState();
}

class ZoomPageState extends State<ZoomPage> {
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
          pageType = ZoomPageType.CREATE;
          centerWidget = ZoomCreate();
        } else {
          switch (model.lastClicked.runtimeType) {
            case ZoomGroup:
              pageType = ZoomPageType.JOIN;
              currentGroup = model.lastClicked;
              centerWidget = ZoomJoin(this);
              break;
            case Group:
              if (model.lastClicked.groupType == GroupType.CIRCLE) {
                pageType = ZoomPageType.NOJOIN;
                centerWidget = Container(height: 300, width: 500,
                    child: Center(
                      child: Text(
                          style: TextStyle(
                              color: ColorConstants.buttonTextColor,
                              fontSize: 18,
                              height: 1.5),
                          "This Circle is only available in the installed version of Together. "
                              +
                              "To install go to\n"
                              + "https://togethersphere.com/limited/download"),

                    ));
              } else {
                pageType = ZoomPageType.CREATE;
                centerWidget = ZoomCreate();
              }
              break;
            default:
              pageType = ZoomPageType.CREATE;
              centerWidget = ZoomCreate();
              break;
          }
        }
        return nebulaBackground(
          centerWidget,
        );
      }),
    );
  }
}

//
/// ZoomJoin
//

class ZoomJoin extends StatefulWidget {
  ZoomPageState parentState;

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
  @override
  State<ZoomCreate> createState() {
    return ZoomCreateState();
  }
}

//
/// ZoomCreateState
//

class ZoomCreateState extends State<ZoomCreate> {
  late TextEditingController _nameController;
  late TextEditingController _linkController;
  String? _nameError;
  String? _linkError;
  bool isEnabled = false;
  bool progressIndicator = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _linkController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicatorIfNeeded() {
      return progressIndicator
          ? Container(
          padding: EdgeInsets.only(top: 20),
          child: CircularProgressIndicator())
          : Container();
    }

    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(padding: EdgeInsets.only(bottom: 5.0),
                child: Text("New circle name",
                    style: TextStyle(
                        fontSize: 18, color: ColorConstants.buttonTextColor))),
            SizedBox(height: 50, width: 300,
              child: TextField(
                  maxLength: 40,
                  enableInteractiveSelection: true,
                  controller: _nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.grey, width: 0.0)),
                    border: const OutlineInputBorder(),
                  )),
            ),
            Text(_nameError ?? "",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            Container(padding: EdgeInsets.only(top: 20, bottom: 5),
              child: Text("Zoom link",
                  style: TextStyle(
                      fontSize: 18, color: ColorConstants.buttonTextColor)),
            ),
            SizedBox(height: 50, width: 600,
              child: LinkField(_linkController, 80, enableCreateButton),
            ),
            Text(_linkError ?? "",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: SizedBox(width: 120,
                child: ElevatedButton(
                  style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll<Color>(
                          Colors.white),
                      backgroundColor: MaterialStatePropertyAll<Color>(
                          ColorConstants.primaryColor)),
                  child: Text("Create",
                      style: TextStyle(fontSize: 18)),
                  onPressed: isEnabled ? createZoomCircle : null,
                ),
              ),
            ),
            progressIndicatorIfNeeded()],
        ),
      ),
    );
  }


  void enableCreateButton(String s) {
    bool enable;
    if (_nameController.text.isNotEmpty && _linkController.text.isNotEmpty) {
      enable = true;
    } else {
      enable = false;
    }
    if (enable != isEnabled) {
      setState(() {
        isEnabled = enable;
      });
    }
  }

  createZoomCircle() {
    String? circleName = _nameController.text;
    String? zoomLink = _linkController.text;
    String nameError = "";
    String linkError = "";
    bool isError = false;
    if (circleName.length < 3) {
      nameError = "Name must be at least 3 characters long";
      isError = true;
    } else {
      nameError = "";
    }
    if (!zoomLink.contains("https://", 0)) {
      isError = true;
      linkError = "Zoom link must start with https://";
    } else if (!zoomLink.contains("/j/")) {
      isError = true;
      linkError = "Zoom link must contain /j/";
    } else {
      linkError = "";
    }
    if (isError) {
      setState(() {
        _nameError = nameError;
        _linkError = linkError;
      });
    } else {
      //encodeJson
      _nameError = "";
      _linkError = "";
      setState(() {
        progressIndicator = true;
      });
      List elements = List<dynamic>.filled(6, null, growable: false);
      elements.setAll(
          0, ["create-group", circleName, false, false, true, zoomLink]);
      connection.send(jsonEncode(elements));
      //wait for result
    };
  }
}


class ZoomEdit extends StatefulWidget {
  ZoomPageState parentState;

  ZoomEdit(this.parentState);

  @override
  State<ZoomEdit> createState() => _ZoomEditState();
}

class _ZoomEditState extends State<ZoomEdit> {
  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController();
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
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
                                      onPressed: () {
                                        widget.parentState.setState(() {
                                          widget.parentState.pageType =
                                              ZoomPageType.JOIN;
                                        });
                                      },
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
                                      value: widget.parentState.currentGroup!
                                          .persistent,
                                      onChanged: persist),
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
                          SizedBox(height: 30, width: 300,
                            child: LinkField(_linkController, 80, noop),
                          )
                        ])
                    )),
                    Flexible(flex: 1, child: Container(
                        child: Center(
                          child: ElevatedButton(
                            style: ButtonStyle(
                                foregroundColor: MaterialStatePropertyAll<
                                    Color>(
                                    Colors.white),
                                backgroundColor: MaterialStatePropertyAll<
                                    Color>(
                                    ColorConstants.primaryColor)),
                            child: Text("Delete"),
                            onPressed: deleteCircle(),
                          ),
                        )
                    )),
                  ])

              )

            ])
        )
    );
  }

  void persist(bool? value) {
    widget.parentState.currentGroup!.persistent = value ?? false;
    setState(() {});
  }

  deleteCircle() {

  }

  void noop(String s) {}


}

class LinkField extends StatefulWidget {
  TextEditingController controller;
  int maxLength;
  void Function(String)? onChanged;

  LinkField(this.controller, this.maxLength, this.onChanged);

  @override
  State<LinkField> createState() => _LinkFieldState();
}

class _LinkFieldState extends State<LinkField> {

  @override
  Widget build(BuildContext context) {
    String initText = "nothing";
    return TextField(
      maxLength: widget.maxLength,
      enableInteractiveSelection: true,
      onChanged: widget.onChanged,
      controller: widget.controller,
      style: TextStyle(color: Colors.white, fontSize: 10),
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 0.0)),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

