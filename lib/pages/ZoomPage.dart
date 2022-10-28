import 'package:flutter/material.dart';
import 'package:together_mobile/pages/Layouts.dart';

import '../main.dart';
import 'ColorConstants.dart';

class ZoomPage extends StatelessWidget {
  LoginPage() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.transparent,
          //appBar: AppBar(title: Text('Together')),
          appBar: null,
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return nebulaBackground(ZoomJoin());
          }),
    );
  }
}

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
            child: Align(alignment: Alignment.bottomCenter,
              child: Container(height: 110,
                child: Column(children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(
                        "", //error text
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ),
                  Container(
                    child: Text("Zoom Circle Name",
                      style: TextStyle(fontSize: 18, color: ColorConstants.buttonTextColor),
                    )
                  ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
                style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll<Color>
              (ColorConstants.primaryColor)),
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
                  backgroundColor: MaterialStatePropertyAll<Color>
                    (ColorConstants.primaryColor)),
                child: Text("Edit"),
                  onPressed: () {
                    editZoomCircle();
                  }),
            ),
          ),
        ]));
  }

  magicHappens() {
    print("Magic!");
  }

  editZoomCircle() {
    print("Edit Zoom Circle");
  }
}

class ZoomCreate extends StatefulWidget {
  @override
  State<ZoomCreate> createState() {
    return ZoomCreateState();
  }
}

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
    return Container(
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
        ]));
  }
}
