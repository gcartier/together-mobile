import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:together_mobile/pages/Layouts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';

import '../main.dart';
import '../models/PeopleModel.dart';
import 'ColorConstants.dart';

ZoomGroup? currentGroup;
String errorMessage = "";

//
/// ZoomPage
//

class ZoomPage extends StatelessWidget {
  ZoomPage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: AppBar(title: Text('Together')),
      appBar: null,
      body: Consumer<PeopleModel>(builder: (context, model, child) {
        if ((model.lastClicked != null) && (model.lastClicked is ZoomGroup)) {
          currentGroup = model.lastClicked;
        } else {
          currentGroup = null;
        }
        return nebulaBackground(
            (currentGroup != null) ? ZoomJoin() : ZoomCreate());
      }),
    );
  }
}

//
/// ZoomJoin
//

class ZoomJoin extends StatelessWidget {
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
                            errorMessage, // error text
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                        ),
                        Container(
                            child: Text(
                              (currentGroup != null) ? currentGroup!.name : "",
                              style: TextStyle(
                                  fontSize: 18, color: ColorConstants.buttonTextColor),
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
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              ColorConstants.primaryColor)),
                      child: Text("Copy Link"),
                      onPressed: () {
                        copyLink();
                      }),
                ),
              ),
            ]));
  }

  magicHappens() async {
    String? link = currentGroup?.link;
    if (link != null) {
      var url = Uri.parse(link);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        errorMessage = 'Could not launch $url';
      }
    }
  }
}

copyLink() {
  if (currentGroup != null) {
    FlutterClipboard.copy(currentGroup!.link!);
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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    /*
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              connection.errorMessage ?? "",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
          Container(
            child: SizedBox(
              width: 120,
              child: ElevatedButton(
                  //color: Colors.black54,
                  child: Text("Enter"),
                  onPressed: () {
                    Text text = Text(_controller.text);
                  }),
            ),
          ),
          SizedBox(
            width: 200,
            child: Container(
                padding: EdgeInsets.only(bottom: 20),
                child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Zoom Link',
                    ))),
          ),
        ]));*/
  }
}
