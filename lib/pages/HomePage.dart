import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:together_mobile/pages/ColorConstants.dart';

import '../connection/Connection.dart';
import '../models/MessageModel.dart';
import '../models/PeopleModel.dart';
import 'CentralPage.dart';
import 'Layouts.dart';
import 'MessagePage.dart';
import 'PeoplePage.dart';

//
/// HomePage
//

class HomePage extends StatelessWidget {
  BoxConstraints? initialConstraints;

  HomePage({this.initialConstraints}) {}

  @override
  Widget build(BuildContext context) {
    bool smallFormat = false;
    if (initialConstraints != null) {
      smallFormat = (initialConstraints!.maxWidth < 640) ? true : false;
    }
    return Consumer<Connection>(builder: (context, model, child) {
      if (!model.isConnected) {
        Future.delayed(Duration.zero, () async {
          // Navigator.pop(context);
          Navigator.pushReplacementNamed(context, 'login');
        });
      }
      ;
      return smallFormat ? TabbedLayout() : SingleLayout();
    });
  }
}

//
/// TabbedLayout
//

class TabbedLayout extends StatefulWidget {
  const TabbedLayout({ super.key });
  @override
  State<TabbedLayout> createState() => _TabbedLayoutState();
}

//
/// _TabbedLayoutState
//

class _TabbedLayoutState extends State<TabbedLayout> with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'People'),
    Tab(text: 'Messages'),
    Tab(text: 'Join'),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: [
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return nebulaBackground(
                      Consumer<PeopleModel>(builder: (context, model, child) {
                        return People(_tabController);
                      }));
                }),
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return nebulaBackground(Column(children: <Widget>[
                    Consumer<MessageModel>(builder: (context, model, child) {
                      return SizedBox(
                          height: (constraints.maxHeight - 150),
                          child: Messages());
                    }),
                    Consumer<PeopleModel>(builder: (context, model, child) {
                      return WhisperTo();
                    }),
                    SendMessage(),
                  ]));
                }),
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return nebulaBackground(CentralPage());
                })
          ]
      ),
    );
  }
}

//
/// SingleLayout
//

class SingleLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Together'),
            backgroundColor: ColorConstants.primaryColor,
          ),
          body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/nebula.png"),
                        // image: AssetImage("assets/images/Momie.jpg"),
                        // image: AssetImage("assets/images/Dragons.jpg"),
                        fit: BoxFit.cover,
                      )),
                  child: Row(children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: Container(
                          margin: EdgeInsets.only(
                              top: 10, left: 10, bottom: 10, right: 100),
                          decoration: BoxDecoration(
                            // color: _msgBoxColor,
                            border: Border.all(
                              color: ColorConstants.frameColor,
                              width: 1,
                            ),
                          ),
                          child: Consumer<PeopleModel>(
                              builder: (context, model, child) {
                                return People();
                              })),
                    ),
                    Flexible(flex: 1, child: CentralPage()),
                    Flexible(
                        flex: 1,
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 10, right: 10, bottom: 10, left: 100),
                            decoration: BoxDecoration(
                              // color: _msgBoxColor,
                              border: Border.all(
                                color: ColorConstants.frameColor,
                                width: 1,
                              ),
                            ),
                            child: Column(children: <Widget>[
                              Consumer<MessageModel>(
                                  builder: (context, model, child) {
                                    return SizedBox(
                                        height: (constraints.maxHeight - 150),
                                        child: Messages());
                                  }),
                              Consumer<PeopleModel>(
                                  builder: (context, model, child) {
                                    return WhisperTo();
                                  }),
                              SendMessage(),
                            ]))),
                  ]),
                );
              }),
        ));
  }
}
