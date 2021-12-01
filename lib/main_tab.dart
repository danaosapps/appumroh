import 'dart:convert';

import 'package:appumroh/activitygrouptabs/phonebook.dart';
import 'package:appumroh/activitygrouptabs/group.dart';
import 'package:appumroh/activitygrouptabs/chat.dart';
import 'package:appumroh/bottom_bar.dart';
import 'package:appumroh/create_group.dart';
import 'package:appumroh/scan_qr_code.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'global.dart';

void main() {
  runApp(MainTab(null, null, null));
}

class MainTab extends StatefulWidget {
  var context, string, selectedMenu;
  MainTab(this.context, this.string, this.selectedMenu);

  @override
  MainTabState createState() => MainTabState();
}

class MainTabState extends State<MainTab> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedMenu = 0;
  static int unreadGroupMessages = 0;
  static int unreadMessages = 0;
  var groupIDController = TextEditingController(text: "0087456");

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "main_menu";
      selectedMenu = widget.selectedMenu;
    });
    refreshUnreadMessages(widget.string);
  }

  static void refreshUnreadMessages(string) {
    Global.httpPost(string, Uri.parse(Global.API_URL+"/user/get_group_unread_messages"),
        body: <String, String>{
          "user_id": Global.USER_ID.toString()
        }, onSuccess: (response) {
          if (Global.mainTabSetState != null) {
            Global.mainTabSetState(() {
              unreadGroupMessages = int.parse(response);
            });
          }
        });
    Global.httpPost(string, Uri.parse(Global.API_URL+"/user/get_unread_messages"),
        body: <String, String>{
          "user_id": Global.USER_ID.toString()
        }, onSuccess: (response) {
          if (Global.mainTabSetState != null) {
            Global.mainTabSetState(() {
              unreadMessages = int.parse(response);
            });
          }
        });
  }

  Future<String> getGroups() async {
    var response = await Global.httpPostSync(widget.string,
        Uri.parse(Global.API_URL+"/user/get_groups"), body: <String, String>{
          "user_id": Global.USER_ID.toString()
        });
    return response.body;
  }

  Widget getGroupActivityScreen(width, height, index) {
    if (index == 0) {
      return Group(context, widget.string);
    } else if (index == 1) {
      return Chat(context, widget.string);
    } else if (index == 2) {
      return Phonebook(context, widget.string);
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(key: scaffoldKey, body: SafeArea(child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xffe3e3e3),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: selectedMenu==0?Color(0xff529255):Colors.transparent,
                              borderRadius: BorderRadius.circular(30)
                          ),
                          height: 30,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              setState(() {
                                selectedMenu = 0;
                              });
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(widget.string.text92, style: TextStyle(
                                      color: Color(selectedMenu==0?0xffffffff:0xff7e8a7c)
                                  )),
                                  SizedBox(width: 4),
                                  Container(width: 18, height: 18, decoration: BoxDecoration(
                                      color: Color(selectedMenu==0?0xffffffff:0xff7e8a7c),
                                      borderRadius: BorderRadius.circular(9)
                                  ), child: Center(
                                      child: Text(unreadGroupMessages.toString(),
                                          style: TextStyle(color: Color(selectedMenu==0?0xff000000:0xffe3e3e3),
                                              fontSize: 10))
                                  ))
                                ]
                            )
                          )
                        )
                      ),
                      Expanded(
                          child: Container(decoration: BoxDecoration(
                              color: selectedMenu==1?Color(0xff529255):Colors.transparent,
                              borderRadius: BorderRadius.circular(30)
                          ),
                            height: 30,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  selectedMenu = 1;
                                });
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(widget.string.message, style: TextStyle(
                                        color: Color(selectedMenu==1?0xffffffff:0xff7e8a7c)
                                    )),
                                    (() {
                                      if (unreadMessages == 0) {
                                        return SizedBox.shrink();
                                      } else {
                                        return SizedBox(width: 4);
                                      }
                                    }()),
                                    (() {
                                      if (unreadMessages == 0) {
                                        return SizedBox.shrink();
                                      } else {
                                        return Container(width: 18, height: 18, decoration: BoxDecoration(
                                            color: Color(selectedMenu==1?0xffffffff:0xff7e8a7c),
                                            borderRadius: BorderRadius.circular(9)
                                        ), child: Center(
                                            child: Text(unreadMessages.toString(), style: TextStyle(color: Color(selectedMenu==1?0xff000000:0xffffffff), fontSize: 10))
                                        ));
                                      }
                                    }())
                                  ]
                              )
                            )
                          )
                      ),
                      Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: selectedMenu==2?Color(0xff529255):Colors.transparent,
                                  borderRadius: BorderRadius.circular(30)
                              ),
                            height: 30,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  selectedMenu = 2;
                                });
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(widget.string.contact, style: TextStyle(
                                        color: Color(selectedMenu==2?0xffffffff:0xff7e8a7c)
                                    ))
                                  ]
                              )
                            )
                          )
                      )
                    ]
                  )
                )
              ),
              Container(
                width: 45,
                height: 30,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    if (selectedMenu == 0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                              content: Container(
                                  width: width-20-20,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: 2,
                                      itemBuilder: (dialogContext, index) {
                                        if (index == 0) {
                                          return ListTile(title: Text(widget.string.text184), onTap: () async {
                                            Navigator.pop(dialogContext);
                                            var result = await Global.navigateAndWait(dialogContext, CreateGroup(dialogContext, widget.string));
                                            if (result == true) {
                                              getGroups();
                                            }
                                          });
                                        } else {
                                          return ListTile(title: Text(widget.string.text185), onTap: () async {
                                            Navigator.pop(dialogContext);
                                            showDialog(
                                              context: scaffoldKey.currentContext!,
                                              builder: (BuildContext dialogContext) {
                                                return AlertDialog(
                                                    content: Container(
                                                        width: width-20-20,
                                                        height: 215,
                                                        child: Padding(
                                                            padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                                                            child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(widget.string.text186, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                                                  Container(width: width-20-20-20-20, height: 45, child: TextField(onChanged: (value) {
                                                                    if (value.trim() == "") {
                                                                      return;
                                                                    }},
                                                                      decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text187, contentPadding: EdgeInsets.only(bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: groupIDController, keyboardType: TextInputType.name, style: TextStyle(fontSize: 14))),
                                                                  Container(width: width-20-20-20-20, height: 1, color: Color(0x7f4c945c)),
                                                                  SizedBox(height: 20),
                                                                  Align(
                                                                      alignment: Alignment.center,
                                                                      child: Container(
                                                                          width: width-20-20-20-20-40-40,
                                                                          height: 50,
                                                                          decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(20)),
                                                                          child: GestureDetector(
                                                                              behavior: HitTestBehavior.translucent,
                                                                              onTap: () async {
                                                                                Map<Permission, PermissionStatus> statuses = await [
                                                                                  Permission.camera
                                                                                ].request();
                                                                                var result = await Global.navigateAndWait(dialogContext, ScanQRCode(dialogContext, widget.string));
                                                                                if (result == true) {
                                                                                  Get.back();
                                                                                }
                                                                              },
                                                                              child: Center(child: Text(widget.string.scan, style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)))
                                                                          )
                                                                      )),
                                                                  SizedBox(height: 20),
                                                                  Align(
                                                                      alignment: Alignment.centerRight,
                                                                      child: Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            Expanded(child: Container(height: 40, decoration: BoxDecoration(
                                                                                color: Global.MAIN_COLOR, borderRadius: BorderRadius.circular(20)
                                                                            ), child: GestureDetector(
                                                                                behavior: HitTestBehavior.translucent,
                                                                                onTap: () {
                                                                                  Get.back();
                                                                                },
                                                                                child: Padding(
                                                                                    padding: EdgeInsets.only(left: 10, right: 10),
                                                                                    child: Center(child: Text(widget.string.cancel, style: TextStyle(
                                                                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold
                                                                                    )))
                                                                                )
                                                                            ))),
                                                                            SizedBox(width: 20),
                                                                            Expanded(child: Container(height: 40, decoration: BoxDecoration(
                                                                                color: Global.MAIN_COLOR, borderRadius: BorderRadius.circular(20)
                                                                            ), child: GestureDetector(
                                                                                behavior: HitTestBehavior.translucent,
                                                                                onTap: () async {
                                                                                  var groupID = groupIDController.text.trim();
                                                                                  if (groupID == "") {
                                                                                    return;
                                                                                  }
                                                                                  Get.back();
                                                                                  await Global.showProgressDialog(dialogContext, widget.string.text192);
                                                                                  Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/join_group"),
                                                                                      body: <String, String>{
                                                                                        "unique_id": groupID,
                                                                                        "user_id": Global.USER_ID.toString()
                                                                                      }, onSuccess: (response) async {
                                                                                        print("Response:");
                                                                                        print(response);
                                                                                        Get.back();
                                                                                        var obj = jsonDecode(response);
                                                                                        var responseCode = int.parse(obj['response_code'].toString());
                                                                                        print("Response code:");
                                                                                        print(responseCode);
                                                                                        if (responseCode == 1) {
                                                                                          var groups = obj['groups'];
                                                                                          print("Groups:");
                                                                                          print(groups);
                                                                                          if (groups.length > 0) {
                                                                                            var group = groups[0];
                                                                                            print("Group:");
                                                                                            print(group);
                                                                                            print("GROUP FCM KEY:");
                                                                                            print(group['user']['fcm_key'].toString());
                                                                                            Global.sendFCMMessage(group['user']['fcm_key'].toString(),
                                                                                                Global.USER_INFO['name'].toString()+" "+widget.string.text194, widget.string.text195,
                                                                                                {
                                                                                                  "group": group
                                                                                                });
                                                                                          }
                                                                                          Global.alertConfirm(scaffoldKey.currentContext!, widget.string, widget.string.information, widget.string.text193, () {
                                                                                          });
                                                                                        } else if (responseCode == -1) {
                                                                                          Global.alertConfirm(scaffoldKey.currentContext!, widget.string, widget.string.information, widget.string.text196, () {
                                                                                          });
                                                                                        } else if (responseCode == -2) {
                                                                                          Global.alertConfirm(scaffoldKey.currentContext!, widget.string, widget.string.information, widget.string.text197, () {
                                                                                          });
                                                                                        }
                                                                                      });
                                                                                },
                                                                                child: Padding(
                                                                                    padding: EdgeInsets.only(left: 10, right: 10),
                                                                                    child: Center(child: Text(widget.string.join, style: TextStyle(
                                                                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold
                                                                                    )))
                                                                                )
                                                                            )))
                                                                          ]
                                                                      )
                                                                  )
                                                                ]
                                                            )
                                                        )
                                                    )
                                                );
                                              },
                                            );
                                          });
                                        }
                                      }
                                  )
                              )
                          );
                        },
                      );
                    } else if (selectedMenu == 1) {
                      setState(() {
                        selectedMenu = 2;
                      });
                    } else if (selectedMenu == 2) {
                      await ContactsService.openContactForm();
                    }
                  },
                  child: Center(
                    child: Icon(Ionicons.add, color: Color(0xff529758), size: 20)
                  )
                )
              )
            ]
          )
        ),
        Expanded(
          child: Container(
            width: width,
            height: 50,
            child: Stack(
                children: [
                  getGroupActivityScreen(width, height, selectedMenu),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Card(
                          elevation: 50,
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          shadowColor: Color(0xCC888888),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)
                          ),
                          child: BottomBar(context, widget.string, 1, "main_tab")
                      )
                  )
                ]
            )
          )
        )
      ]
    )));
  }
}
