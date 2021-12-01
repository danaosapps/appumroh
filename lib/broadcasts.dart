import 'dart:convert';
import 'package:appumroh/create_broadcast.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'global.dart';

void main() {
  runApp(Broadcasts(null, null, null));
}

class Broadcasts extends StatefulWidget {
  final context, string, group;

  Broadcasts(this.context, this.string, this.group);

  @override
  BroadcastsState createState() => BroadcastsState();
}

class BroadcastsState extends State<Broadcasts> with WidgetsBindingObserver {
  var broadcasts = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    getBroadcasts();
  }

  void getBroadcasts() async {
    var broadcastString = await Global.readString("broadcasts", "[]");
    print("BROADCASTS:");
    print(broadcastString);
    var _broadcasts = jsonDecode(broadcastString);
    setState(() {
      broadcasts = [];
      for (var broadcast in _broadcasts) {
        if (int.parse(broadcast['group_id'].toString()) == int.parse(widget.group['id'].toString())) {
          broadcasts.add(broadcast);
        }
      }
    });
  }

  Future<void> onBroadcastRefresh() async {
    getBroadcasts();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      Card(
          elevation: 5,
          clipBehavior: Clip.antiAlias,
          shadowColor: Color(0x4C888888),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: Container(
              width: width,
              height: 50,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Center(
                                child: Icon(Ionicons.arrow_back_outline,
                                    color: Global.SECONDARY_COLOR, size: 20)))),
                    Text(widget.string.broadcast,
                        style: TextStyle(
                            color: Global.SECONDARY_COLOR,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    Container(
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              var result = await Global.navigateAndWait(context, CreateBroadcast(context, widget.string, widget.group));
                              if (result == true) {
                                getBroadcasts();
                              }
                            },
                            child: Center(
                                child: Icon(Ionicons.add,
                                    color: Global.SECONDARY_COLOR, size: 20))))
                  ]))),
              Flexible(
                child: RefreshIndicator(
                    onRefresh: onBroadcastRefresh,
                    child: ListView.builder(
                        itemCount: broadcasts.length,
                        itemBuilder: (context, index) {
                          print("BROADCAST:");
                          print(broadcasts[index]);
                          print("SENDER:");
                          print(broadcasts[index]['sender']);
                          var senderName = "";
                          if (broadcasts[index]['sender'] != null
                              && broadcasts[index]['sender'].toString().trim() != "null"
                              && broadcasts[index]['sender'].toString().trim() != "") {
                            senderName = jsonDecode(broadcasts[index]['sender'])['name'].toString();
                          }
                          print("SENDER NAME:");
                          print(senderName);
                          print("DATE:");
                          print(broadcasts[index]['date'].toString());
                          print("MESSAGE:");
                          print(broadcasts[index]['message'].toString());
                          return Card(
                              elevation: 5,
                              clipBehavior: Clip.antiAlias,
                              shadowColor: Color(0x4C888888),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                              child: Padding(
                                  padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(senderName, style: TextStyle(
                                                  color: Colors.black, fontSize: 14
                                              )),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(Jiffy(broadcasts[index]['date'].toString(), "yyyy-MM-dd HH:mm:ss")
                                                        .format("d MMMM yyyy"), style: TextStyle(
                                                        color: Colors.black, fontSize: 13
                                                    )),
                                                    Text(Jiffy(broadcasts[index]['date'].toString(), "yyyy-MM-dd HH:mm:ss")
                                                        .format("HH:mm:ss"), style: TextStyle(
                                                        color: Colors.black, fontSize: 12
                                                    ))
                                                  ]
                                              )
                                            ]
                                        ),
                                        SizedBox(height: 10),
                                        Text(broadcasts[index]['message'].toString(), style: TextStyle(
                                            color: Colors.black, fontSize: 15
                                        ))
                                      ]
                                  )
                              )
                          );
                          return SizedBox.shrink();
                        }
                    )
                )
              )
    ])));
  }
}
