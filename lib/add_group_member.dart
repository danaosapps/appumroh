import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'global.dart';

void main() {
  runApp(AddGroupMember(null, null, null));
}

class AddGroupMember extends StatefulWidget {
  final context, string, group;
  AddGroupMember(this.context, this.string, this.group);

  @override
  AddGroupMemberState createState() => AddGroupMemberState();
}

class AddGroupMemberState extends State<AddGroupMember> with WidgetsBindingObserver {
  var contacts = [];
  var selectedRoleIndex = 0;
  var reloadingContacts = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "add_group_member";
    });
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts
    ].request();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    var syncedContacts = jsonDecode(await Global.readString("synced_contacts", "[]"));
    if (syncedContacts.length > 0) {
      setState(() {
        contacts = syncedContacts;
      });
    } else {
      List<Contact> systemContacts = await ContactsService.getContacts();
      var _contacts = [];
      for (var i=0; i<systemContacts.length; i++) {
        var phone = "";
        var email = "";
        if (systemContacts[i].phones!.length > 0) {
          phone = systemContacts[i].phones![0].value!;
        }
        if (systemContacts[i].emails!.length > 0) {
          email = systemContacts[i].emails![0].value!;
        }
        _contacts.add({
          "phone": phone,
          "email": email
        });
      }
      Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/check_users_registered"),
          body: <String, String>{
            "users": jsonEncode(_contacts)
          }, onSuccess: (response) async {
            var checkedUsers = jsonDecode(response);
            setState(() {
              contacts = checkedUsers;
            });
            await Global.writeString("synced_contacts", jsonEncode(checkedUsers));
          });
    }
  }

  Future<String> getContacts() async {
    var response = await Global.httpPostSync(widget.string,
        Uri.parse(Global.API_URL+"/user/get_contacts_by_group"), body: <String, String>{
          "user_id": Global.USER_ID.toString(),
          "group_id": widget.group['id'].toString()
        });
    return response.body;
  }

  Future<void> onContactRefresh() async {
    getContacts();
  }

  int getTotalCheckedMembers() {
    int total = 0;
    for (var contact in contacts) {
      if (contact['checked'] == 1) {
        total++;
      }
    }
    return total;
  }

  getSelectedUserIDs() {
    var ids = [];
    for (var contact in contacts) {
      if (contact['checked'] == 1) {
        ids.add(int.parse(contact['contact_user_id']));
      }
    }
    return ids;
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
              Text(widget.string.text164, style: TextStyle(color: Colors.white, fontSize: 16)),
              Row(
                children: [
                  Container(width: 45, height: 40, child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        Global.show(widget.string.text254);
                        setState(() {
                          reloadingContacts = true;
                        });
                        List<Contact> systemContacts = await ContactsService.getContacts();
                        var _contacts = [];
                        for (var i=0; i<systemContacts.length; i++) {
                          var phone = "";
                          var email = "";
                          if (systemContacts[i].phones!.length > 0) {
                            phone = systemContacts[i].phones![0].value!;
                          }
                          if (phone == null) phone = "";
                          phone = phone.trim();
                          if (phone.startsWith("0")) {
                            phone = phone.substring(1, phone.length);
                          }
                          if (phone.startsWith("62")) {
                            phone = "+"+phone;
                          }
                          if (!phone.startsWith("+") && !phone.startsWith("+62")) {
                            phone = "+62"+phone;
                          }
                          if (systemContacts[i].emails!.length > 0) {
                            email = systemContacts[i].emails![0].value!;
                          }
                          _contacts.add({
                            "phone": phone,
                            "email": email
                          });
                        }
                        print("SYSTEM CONTACTS:");
                        print(_contacts);
                        Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/check_users_registered"),
                            body: <String, String>{
                              "users": jsonEncode(_contacts)
                            }, onSuccess: (response) async {
                              print("check_users_registered response:");
                              print(response);
                              var checkedUsers = jsonDecode(response);
                              await Global.writeString("synced_contacts", jsonEncode(checkedUsers));
                              setState(() {
                                contacts = checkedUsers;
                                reloadingContacts = false;
                              });
                            });
                      },
                      child: Center(child: Icon(Ionicons.reload, color: Colors.white, size: 20))
                  ))
                ]
              )
            ]
        )),
        Container(
          width: width,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Card(
            elevation: 5,
            clipBehavior: Clip.antiAlias,
            shadowColor: Color(0x4C888888),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Padding(padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8), child: Text(widget.string.text171, style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold))),
                SizedBox(height: 8),
                Padding(padding: EdgeInsets.only(left: 12, right: 12), child: Container(width: width-10-10, height: 1, color: Color(0x4f888888))),
                SizedBox(height: 8),
                Padding(padding: EdgeInsets.only(left: 12, right: 12), child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.string.text172, style: TextStyle(color: Colors.black, fontSize: 14)),
                    Container(width: 40, height: 40, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            selectedRoleIndex = 0;
                          });
                        },
                        child: Center(child:
                          Icon(selectedRoleIndex==0?Ionicons.checkmark_circle:Ionicons.checkmark_circle_outline,
                            color: selectedRoleIndex==0?Global.SECONDARY_COLOR:Color(0x7f4c945c), size: 23))
                    ))
                  ]
                )),
                Padding(padding: EdgeInsets.only(left: 12, right: 12), child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.string.text166, style: TextStyle(color: Colors.black, fontSize: 14)),
                      Container(width: 40, height: 40, child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              selectedRoleIndex = 1;
                            });
                          },
                          child: Center(child:
                          Icon(selectedRoleIndex==1?Ionicons.checkmark_circle:Ionicons.checkmark_circle_outline,
                              color: selectedRoleIndex==1?Global.SECONDARY_COLOR:Color(0x7f4c945c), size: 23))
                      ))
                    ]
                )),
                Padding(padding: EdgeInsets.only(left: 12, right: 12), child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.string.text167, style: TextStyle(color: Colors.black, fontSize: 14)),
                      Container(width: 40, height: 40, child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              selectedRoleIndex = 2;
                            });
                          },
                          child: Center(child:
                          Icon(selectedRoleIndex==2?Ionicons.checkmark_circle:Ionicons.checkmark_circle_outline,
                              color: selectedRoleIndex==2?Global.SECONDARY_COLOR:Color(0x7f4c945c), size: 23))
                      ))
                    ]
                )),
                Padding(padding: EdgeInsets.only(left: 12, right: 12), child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.string.text168, style: TextStyle(color: Colors.black, fontSize: 14)),
                      Container(width: 40, height: 40, child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              selectedRoleIndex = 3;
                            });
                          },
                          child: Center(child:
                          Icon(selectedRoleIndex==3?Ionicons.checkmark_circle:Ionicons.checkmark_circle_outline,
                              color: selectedRoleIndex==3?Global.SECONDARY_COLOR:Color(0x7f4c945c), size: 23))
                      ))
                    ]
                ))
              ]
            )
          )
        ),
        Expanded(
          child: (() {
            if (reloadingContacts) {
              return Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator()));
            } else {
              return ListView.builder(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            if (contacts[index]['checked'] == 0) {
                              contacts[index]['checked'] = 1;
                            } else {
                              contacts[index]['checked'] = 0;
                            }
                          });
                        },
                        child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: Image.network(Global.USERDATA_URL+contacts[index]['photo'].toString(),
                                                width: 40, height: 40,
                                                fit: BoxFit.cover)
                                        ),
                                        SizedBox(width: 10),
                                        Text(contacts[index]['name'].toString(), style: TextStyle(color: Color(0xff529654), fontSize: 13, fontWeight: FontWeight.bold))
                                      ]
                                  ),
                                  Container(width: 45, height: 45, child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        setState(() {
                                          if (contacts[index]['checked'] == 0) {
                                            contacts[index]['checked'] = 1;
                                          } else {
                                            contacts[index]['checked'] = 0;
                                          }
                                        });
                                      },
                                      child: Center(child: Icon(
                                          contacts[index]['checked']==0?Ionicons.checkmark_circle_outline:Ionicons.checkmark_circle,
                                          color: contacts[index]['checked']==0?Color(0x7f4c945c):Global.SECONDARY_COLOR, size: 27))
                                  ))
                                ]
                            )
                        )
                    );
                  }
              );
            }
          }())
        ),
        Container(width: width, height: 45, decoration: BoxDecoration(color: Global.SECONDARY_COLOR),
          child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () async {
            if (getTotalCheckedMembers() <= 0) {
              Global.show(widget.string.text169);
              return;
            }
            await Global.showProgressDialog(context, widget.string.text170);
            Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/add_group_member"),
                body: <String, String>{
                  "group_id": widget.group['id'].toString(),
                  "user_ids": getSelectedUserIDs().toString(),
                  "role": selectedRoleIndex==0?"member":selectedRoleIndex==1?"leader":selectedRoleIndex==2?"officer":selectedRoleIndex==3?"driver":"member"
                }, onSuccess: (response) async {
                  await Global.hideProgressDialog(context);
                  Navigator.pop(context);
                });
          },
            child: Center(child: Text(widget.string.text253, style: TextStyle(color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.bold)))))
      ]
    )));
  }
}
