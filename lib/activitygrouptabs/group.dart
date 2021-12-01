import 'dart:convert';

import 'package:appumroh/group_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';

void main() {
  runApp(Group(null, null));
}

class Group extends StatefulWidget {
  final context, string;
  Group(this.context, this.string);

  @override
  GroupState createState() => GroupState();
}

class GroupState extends State<Group> with WidgetsBindingObserver {
  var groups = [];
  var progressShown = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "group";
    });
    refreshGroups();
  }

  void refreshGroups() async {
    setState(() {
      progressShown = true;
    });
    var _groups = jsonDecode(await getGroups());
    setState(() {
      groups = _groups;
      progressShown = false;
    });
  }

  Future<String> getGroups() async {
    var response = await Global.httpPostSync(widget.string,
        Uri.parse(Global.API_URL+"/user/get_groups"), body: <String, String>{
          "user_id": Global.USER_ID.toString()
        });
    return response.body;
  }

  Future<void> onGroupRefresh() async {
    refreshGroups();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(
        width: width,
        child: (() {
          if (progressShown) {
            return Expanded(
              child: Container(
                width: width,
                child: Center(
                    child: CircularProgressIndicator()
                )
              )
            );
          } else {
            return RefreshIndicator(
              onRefresh: onGroupRefresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Global.navigate(context, GroupInfo(context, widget.string, groups[index]));
                      },
                      child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(width: 10),
                                      Container(
                                          width: 40,
                                          height: 40,
                                          child: Stack(
                                              children: [
                                                Container(
                                                    width: 40, height: 40, decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20)
                                                ),
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(20),
                                                        child: Image.network(
                                                            Global.USERDATA_URL+groups[index]['photo'].toString(),
                                                            width: 40, height: 40, fit: BoxFit.cover)
                                                    )
                                                ),
                                                Align(
                                                    alignment: Alignment.bottomRight,
                                                    child: Container(
                                                        width: 14, height: 14, decoration: BoxDecoration(
                                                        color: Colors.white, borderRadius: BorderRadius.circular(7)
                                                    ), child: Center(
                                                        child: Image.asset("assets/images/marker.png", width: 10, height: 10)
                                                    )
                                                    )
                                                )
                                              ]
                                          )
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(groups[index]['title'].toString(), style: TextStyle(
                                                color: Color(0xff324b34), fontSize: 12, fontWeight: FontWeight.bold
                                            )),
                                            SizedBox(height: 2),
                                            Row(
                                                children: [
                                                  Container(
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          color: Color(0xff549658),
                                                          borderRadius: BorderRadius.circular(30)
                                                      ),
                                                      child: GestureDetector(
                                                          behavior: HitTestBehavior.translucent,
                                                          onTap: () {},
                                                          child: Padding(
                                                              padding: EdgeInsets.only(left: 20, right: 20),
                                                              child: Center(
                                                                  child: Text(widget.string.text46, style: TextStyle(
                                                                      color: Colors.white, fontSize: 10
                                                                  ))
                                                              )
                                                          )
                                                      )
                                                  ),
                                                  SizedBox(width: 5),
                                                  Row(
                                                      children: [
                                                        Container(
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                                color: Color(0xff536396),
                                                                borderRadius: BorderRadius.circular(30)
                                                            ),
                                                            child: GestureDetector(
                                                                behavior: HitTestBehavior.translucent,
                                                                onTap: () {},
                                                                child: Padding(
                                                                    padding: EdgeInsets.only(left: 20, right: 20),
                                                                    child: Center(
                                                                        child: Text(widget.string.tracking, style: TextStyle(
                                                                            color: Colors.white, fontSize: 10
                                                                        ))
                                                                    )
                                                                )
                                                            )
                                                        )
                                                      ]
                                                  ),
                                                  SizedBox(width: 5),
                                                  Row(
                                                      children: [
                                                        Container(
                                                            height: 30,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(30)
                                                            ),
                                                            child: GestureDetector(
                                                                behavior: HitTestBehavior.translucent,
                                                                onTap: () {
                                                                  AlertDialog alert = AlertDialog(
                                                                      content: Padding(
                                                                          padding: EdgeInsets.all(10),
                                                                          child: Image.network(Global.USERDATA_URL+groups[index]['qr_image'].toString(), width: 200, height: 200)
                                                                      )
                                                                  );
                                                                  showDialog(
                                                                      barrierDismissible: true,
                                                                      context: context,
                                                                      builder: (BuildContext context){
                                                                        return alert;
                                                                      }
                                                                  );
                                                                },
                                                                child: Center(
                                                                    child: Icon(Ionicons.qr_code, color: Color(0xff4d9951), size: 20)
                                                                )
                                                            )
                                                        )
                                                      ]
                                                  )
                                                ]
                                            )
                                          ]
                                      )
                                    ]
                                ),
                                Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(Jiffy(groups[index]['last_modified_date'].toString(), "yyyy-MM-dd HH:mm:ss").format("dd-MM-yyyy"), style: TextStyle(
                                              color: Color(0xff2d4e2f),
                                              fontSize: 10
                                          )),
                                          SizedBox(height: 2),
                                          (() {
                                            var unreadMessages = int.parse(groups[index]['unread_messages'].toString());
                                            if (unreadMessages <= 0) {
                                              return SizedBox.shrink();
                                            } else {
                                              return Container(
                                                  width: 20, height: 20,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffe65252),
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: Center(
                                                      child: Text(groups[index]['unread_messages'].toString(),
                                                          style: TextStyle(color: Colors.white, fontSize: 9))
                                                  )
                                              );
                                            }
                                          }())
                                        ]
                                    )
                                )
                              ]
                          )
                      )
                    );
                  }
              )
            );
          }
        }())
    )));
  }
}
