import 'dart:convert';

import 'package:appumroh/add_group_member.dart';
import 'package:appumroh/invite_person.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'global.dart';

void main() {
  runApp(GroupInfo(null, null, null));
}

class GroupInfo extends StatefulWidget {
  final context, string, group;
  GroupInfo(this.context, this.string, this.group);

  @override
  GroupInfoState createState() => GroupInfoState();
}

class GroupInfoState extends State<GroupInfo> with WidgetsBindingObserver {
  bool isSearching = false;
  var searchController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "group_info";
    });
    refreshContacts();
  }

  String getGroupCreatorName() {
    if (int.parse(widget.group['user_id'].toString()) == Global.USER_ID) {
      return widget.string.text160;
    } else {
      return widget.group['user']['name'].toString();
    }
  }

  void refreshContacts() async {
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_group_members"),
      body: <String, String>{
        "group_id": widget.group['id'].toString()
      }, onSuccess: (response) {
        var group = jsonDecode(response);
        setState(() {
          widget.group['members'] = group['members'];
          widget.group['group_members'] = group['group_members'];
        });
        print("ALL GROUP MEMBERS:");
        print(widget.group['members']);
      });
  }

  bool isGroupAdmin(member) {
    print("isGroupAdmin member:");
    print(member);
    if (int.parse(member['id'].toString()) == Global.USER_ID) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(
      children: [
        Container(width: width, height: 45, color: Global.SECONDARY_COLOR, child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 45, height: 45, child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20))
            )),
            Text(widget.group['title'].toString(), style: TextStyle(color: Colors.white, fontSize: 16)),
            Container(width: 45, height: 45)
          ]
        )),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: Card(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Color(0xCC888888),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Image.network(Global.USERDATA_URL+widget.group['photo'].toString(), width: 200, height: 150, fit: BoxFit.cover)
                )),
                SizedBox(height: 10),
                Padding(padding: EdgeInsets.only(left: 15, right: 15), child: Text(widget.group['title'].toString(), style: TextStyle(color: Colors.black, fontSize: 17))),
                Padding(padding: EdgeInsets.only(left: 15, right: 15), child: Text(widget.string.text159+" "+getGroupCreatorName()+", "+widget.string.date+" "+Jiffy(widget.group['created_date'].toString(), "yyyy-MM-dd HH:mm:ss").format("yyyy-MM-dd"), style: TextStyle(color: Color(0xff888888), fontSize: 13))),
                SizedBox(height: 10),
                Container(width: width, height: 1, color: Color(0x7f888888), margin: EdgeInsets.only(left: 15, right: 15)),
                SizedBox(height: 8),
                Padding(padding: EdgeInsets.only(left: 15, right: 15), child: Row(
                    children: [
                      Text(widget.string.text161, style: TextStyle(color: Colors.black, fontSize: 13)),
                      SizedBox(width: 15),
                      Text(widget.group['unique_id'].toString(), style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold))
                    ]
                )),
                SizedBox(height: 8),
                Container(width: width, height: 1, color: Color(0x7f888888), margin: EdgeInsets.only(left: 15, right: 15)),
                SizedBox(height: 8),
                Padding(padding: EdgeInsets.only(left: 15, right: 15), child: Text(widget.string.text162, style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold))),
                SizedBox(height: 2),
                Padding(padding: EdgeInsets.only(left: 15, right: 15), child: Text(widget.group['description'].toString(), style: TextStyle(color: Colors.black, fontSize: 13))),
                SizedBox(height: 8),
                Container(width: width, height: 1, color: Color(0x7f888888), margin: EdgeInsets.only(left: 15, right: 15)),
                SizedBox(height: 8),
                Padding(padding: EdgeInsets.only(left: 15, right: 15), child: Text(widget.string.media, style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold))),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.only(right: 10),
                    clipBehavior: Clip.antiAlias,
                    shadowColor: Color(0xCC888888),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children: [
                        Container(height: 41, padding: EdgeInsets.only(left: 10, right: 10), child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (() {
                              if (isSearching) {
                                return Expanded(
                                  child: Column(
                                    children: [
                                      Container(height: 40, child: TextField(decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text203, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: searchController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))),
                                      Container(height: 1, color: Color(0x4f888888), margin: EdgeInsets.only(left: 10, right: 10))
                                    ]
                                  )
                                );
                              } else {
                                return Text(widget.group['members'].length.toString()+" "+widget.string.members, style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold));
                              }
                            }()),
                            Container(width: 40, height: 40, child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  isSearching = !isSearching;
                                });
                              },
                              child: Center(child: Icon(Ionicons.search, color: Colors.black, size: 20))
                            ))
                          ]
                        )),
                        (() {
                          if (int.parse(Global.USER_INFO['id'].toString()) == int.parse(widget.group['user_id'].toString())) {
                            return Container(height: 45, padding: EdgeInsets.only(left: 10, right: 10), child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  await Global.showProgressDialog(context, widget.string.loading);
                                  Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_contacts_count_by_group"),
                                      body: <String, String>{
                                        "user_id": Global.USER_ID.toString(),
                                        "group_id": widget.group['id'].toString()
                                      }, onSuccess: (response) async {
                                        await Global.hideProgressDialog(context);
                                        var remainingContactsCount = int.parse(response);
                                        if (remainingContactsCount <= 0) {
                                          Global.alert(context, widget.string, widget.string.information, widget.string.text174);
                                        } else {
                                          await Global.navigateAndWait(context, AddGroupMember(context, widget.string, widget.group));
                                          refreshContacts();
                                        }
                                      });
                                },
                                child: Row(
                                    children: [
                                      Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(width: 1, color: Global.MAIN_COLOR)), child: Center(
                                          child: Icon(Ionicons.person_add, color: Colors.black, size: 20)
                                      )),
                                      SizedBox(width: 10),
                                      Text(widget.string.text164, style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold))
                                    ]
                                )
                            ));
                          } else {
                            return SizedBox.shrink();
                          }
                        }()),
                        (() {
                          if (isSearching) {
                            return SizedBox(height: 10);
                          } else {
                            return SizedBox.shrink();
                          }
                        }()),
                        Container(height: 45, padding: EdgeInsets.only(left: 10, right: 10), child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Global.navigate(context, InvitePerson(context, widget.string, widget.group));
                          },
                          child: Row(
                              children: [
                                Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(width: 1, color: Global.MAIN_COLOR)), child: Center(
                                    child: Icon(Ionicons.share_social, color: Colors.black, size: 20)
                                )),
                                SizedBox(width: 10),
                                Text(widget.string.text165, style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold))
                              ]
                          )
                        )),
                        (() {
                          List<Widget> members = [];
                          for (var i=0; i<widget.group['members'].length; i++) {
                            var member = widget.group['members'][i];
                            if ((isSearching && member['name'].toString().toLowerCase().trim().contains(searchController.text.toLowerCase().trim())) || !isSearching) {
                              members.add(Container(height: 45, padding: EdgeInsets.only(left: 10, right: 10), child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                        children: [
                                          Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(width: 1, color: Global.MAIN_COLOR)), child: GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: () {},
                                              child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(18),
                                                  child: Image.network(Global.USERDATA_URL+member['photo'].toString(), width: 36, height: 36)
                                              )
                                          )),
                                          SizedBox(width: 10),
                                          Text(member['name'].toString(), style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold))
                                        ]
                                    ),
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          (() {
                                            var role = widget.group['group_members'][i]['role'].toString().trim();
                                            if (role == "member") {
                                              return SizedBox.shrink();
                                            } else if (role == "leader") {
                                              return Text(widget.string.text166, style: TextStyle(color: Colors.black, fontSize: 13));
                                            } else if (role == "officer") {
                                              return Text(widget.string.text167, style: TextStyle(color: Colors.black, fontSize: 13));
                                            } else {
                                              return Text(widget.string.text168, style: TextStyle(color: Colors.black, fontSize: 13));
                                            }
                                          }()),
                                          (() {
                                            var approved = int.parse(widget.group['group_members'][i]['approved'].toString().trim())==1?true:false;
                                            if (approved) {
                                              return SizedBox.shrink();
                                            } else {
                                              if (int.parse(Global.USER_INFO['id'].toString()) == int.parse(widget.group['user_id'].toString())) {
                                                return Container(height: 30, decoration: BoxDecoration(
                                                    color: Color(0x4f4c945c), borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(width: 1, color: Color(0x7f4c945c))
                                                ), margin: EdgeInsets.only(right: 8), child: Padding(
                                                    padding: EdgeInsets.only(left: 10, right: 10),
                                                    child: Center(child: Text(widget.string.text188, style: TextStyle(color: Global.MAIN_COLOR, fontSize: 13)))
                                                ));
                                              } else {
                                                return SizedBox.shrink();
                                              }
                                            }
                                          }()),
                                          (() {
                                            var approved = int.parse(widget.group['group_members'][i]['approved'].toString().trim())==1?true:false;
                                            if (approved) {
                                              return SizedBox.shrink();
                                            } else {
                                              if (int.parse(Global.USER_INFO['id'].toString()) == int.parse(widget.group['user_id'].toString())) {
                                                return Container(width: 30, height: 40, child: GestureDetector(
                                                    behavior: HitTestBehavior.translucent,
                                                    onTap: () async {
                                                      Global.confirm(context, widget.string, widget.string.confirmation,
                                                          widget.string.text189, () async {
                                                            await Global.showProgressDialog(context, widget.string.text190);
                                                            Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/approve_group_member"),
                                                                body: <String, String>{
                                                                  "id": widget.group['group_members'][i]['id'].toString()
                                                                }, onSuccess: (response) async {
                                                                  await Global.hideProgressDialog(context);
                                                                  setState(() {
                                                                    widget.group['group_members'][i]['approved'] = 1;
                                                                  });
                                                                  Global.sendFCMMessage(widget.group['members'][i]['fcm_key'],
                                                                      widget.string.text198, widget.string.text199, {
                                                                        "type": Global.NOTIFICATION_TYPE_GROUP_JOIN_ACCEPTED,
                                                                        "group": widget.group
                                                                      });
                                                                });
                                                          }, () {});
                                                    },
                                                    child: Center(child: Icon(Ionicons.checkmark_circle, color: Global.MAIN_COLOR, size: 20))
                                                ));
                                              } else {
                                                return SizedBox.shrink();
                                              }
                                            }
                                          }()),
                                          (() {
                                            if (int.parse(Global.USER_INFO['id'].toString()) == int.parse(widget.group['user_id'].toString())) {
                                              if (int.parse(Global.USER_INFO['id'].toString()) == int.parse(member['id'].toString())) {
                                                return SizedBox.shrink();
                                              } else {
                                                return Container(width: 30, height: 40, child: GestureDetector(
                                                    behavior: HitTestBehavior.translucent,
                                                    onTap: () async {
                                                      Global.confirm(context, widget.string, widget.string.confirmation,
                                                          widget.string.text176, () async {
                                                            await Global.showProgressDialog(context, widget.string.text175);
                                                            Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/delete_group_member"),
                                                                body: <String, String>{
                                                                  "group_id": widget.group['id'].toString(),
                                                                  "user_id": member['id'].toString()
                                                                }, onSuccess: (response) async {
                                                                  await Global.hideProgressDialog(context);
                                                                  refreshContacts();
                                                                });
                                                          }, () {});
                                                    },
                                                    child: Center(child: Icon(Ionicons.close_circle, color: Color(0xffe74c3c), size: 20))
                                                ));
                                              }
                                            } else {
                                              if (int.parse(member['id'].toString()) == Global.USER_ID) {
                                                return Container(width: 30, height: 40, child: GestureDetector(
                                                    behavior: HitTestBehavior.translucent,
                                                    onTap: () async {
                                                      Global.confirm(context, widget.string, widget.string.confirmation,
                                                          widget.string.text200, () async {
                                                            await Global.showProgressDialog(context, widget.string.text204);
                                                            Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/exit_group"),
                                                                body: <String, String>{
                                                                  "user_id": member['id'].toString(),
                                                                  "group_id": widget.group['id'].toString()
                                                                }, onSuccess: (response) async {
                                                                  Global.sendFCMMessage(widget.group['user']['fcm_key'].toString(),
                                                                      widget.group['user']['name'].toString()+" "+widget.string.text201+" "+widget.group['title'].toString(), widget.string.text202, {
                                                                        "type": Global.NOTIFICATION_TYPE_GROUP_EXITED,
                                                                        "group": widget.group
                                                                      });
                                                                  await Global.hideProgressDialog(context);
                                                                  refreshContacts();
                                                                });
                                                          }, () {});
                                                    },
                                                    child: Center(child: Icon(Ionicons.log_out, color: Color(0xffe74c3c), size: 20))
                                                ));
                                              } else {
                                                return SizedBox.shrink();
                                              }
                                            }
                                          }())
                                        ]
                                    )
                                  ]
                              )));
                            }
                          }
                          return Column(children: members);
                        }()),
                        SizedBox(height: 8)
                      ]
                    )
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
