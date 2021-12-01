import 'dart:convert';

import 'package:appumroh/private_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(Phonebook(null, null));
}

class Phonebook extends StatefulWidget {
  final context, string;
  Phonebook(this.context, this.string);

  @override
  PhonebookState createState() => PhonebookState();
}

class PhonebookState extends State<Phonebook> with WidgetsBindingObserver {
  var contacts = [];
  var searchController = TextEditingController(text: "");
  bool searching = false;
  bool progressShown = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "contact";
    });
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts
    ].request();
    refreshContacts();
  }

  Future<void> refreshContacts() async {
    setState(() {
      progressShown = true;
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
          progressShown = false;
        });
      });
    /*print("GETTING CONTACTS...");
    var _contacts = jsonDecode(await getContacts());
    print("ALL CONTACTS:");
    print(_contacts);
    setState(() {
      contacts = _contacts;
    });*/
  }

  Future<String> getContacts() async {
    var response = await Global.httpPostSync(widget.string,
        Uri.parse(Global.API_URL+"/user/get_contacts"), body: <String, String>{
          "user_id": Global.USER_ID.toString()
        });
    return response.body;
  }

  Future<void> onContactRefresh() async {
    getContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: (() {
        if (progressShown) {
          return Center(child: CircularProgressIndicator());
        } else {
          return SingleChildScrollView(
              child: Column(
                  children: [
                    Card(
                        elevation: 5,
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Color(0x4C888888),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)
                        ),
                        child: Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      height: 45,
                                      child: TextField(onChanged: (value) {
                                        setState(() {
                                          if (value.trim() == "") {
                                            searching = false;
                                          } else {
                                            searching = true;
                                          }
                                        });
                                      }, decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: searchController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))
                                  )
                              ),
                              Container(
                                  width: 40,
                                  height: 40,
                                  child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {},
                                      child: Center(
                                          child: Icon(Ionicons.search, color: Color(0xff434e4a), size: 20)
                                      )
                                  )
                              )
                            ]
                        )
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          if ((searching && contacts[index].displayName!.toLowerCase().trim().contains(searchController.text.toLowerCase().trim())) || !searching) {
                            return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  var phone = Global.getPhoneBookNumber(contacts[index].phones!);
                                  print("PHONE: "+phone!);
                                  if (phone == null) {
                                    Global.alert(context, widget.string, widget.string.information, widget.string.text207);
                                  } else {
                                    var pd = await Global.showProgressDialog(context, widget.string.loading);
                                    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_chat_by_phone"),
                                        body: <String, String>{
                                          "my_user_id": Global.USER_ID.toString(),
                                          "opponent_phone": phone,
                                          "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
                                        }, onSuccess: (response) async {
                                          print("get_chat_by_phone response:");
                                          print(response.substring(0, response.length));
                                          await Global.hideProgressDialog(context);
                                          var obj = jsonDecode(response);
                                          var responseCode = int.parse(obj['response_code'].toString());
                                          if (responseCode == 1) {
                                            Global.navigate(context, PrivateMessage(context, widget.string, int.parse(obj['id'].toString()), obj['opponent']));
                                          } else if (responseCode == -1) {
                                            Global.confirm(context, widget.string, widget.string.confirmation, widget.string.text208, () {
                                              Global.sendSMSMessage(phone, widget.string.text209);
                                            }, () {});
                                          }
                                        });
                                  }
                                },
                                child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 10, top: 8, bottom: 8),
                                    child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          /*(() {
                                            if (contacts[index].avatar!.length == 0) {
                                              return Container(width: 30, height: 30, child: Center(
                                                  child: Icon(Ionicons.person, color: Color(0xffcdcdcd), size: 25)
                                              ));
                                            } else {
                                              return ClipRRect(
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: Image.memory(contacts[index].avatar!,
                                                      width: 40, height: 40,
                                                      fit: BoxFit.cover)
                                              );
                                            }
                                          }()),*/
                                          ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.network(Global.USERDATA_URL+contacts[index]['photo'].toString(),
                                                  width: 40, height: 40,
                                                  fit: BoxFit.cover)
                                          ),
                                          SizedBox(width: 10),
                                          Text(contacts[index]['name'].toString(),
                                              style: TextStyle(color: Color(0xff529654),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold))
                                        ]
                                    )
                                )
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                          /*return Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 8, bottom: 8),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(Global.USERDATA_URL +
                                      contacts[index]['photo'].toString(),
                                      width: 40, height: 40,
                                      fit: BoxFit.cover)
                              ),
                              SizedBox(width: 10),
                              Text(contacts[index]['name'].toString(),
                                  style: TextStyle(color: Color(0xff529654),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold))
                            ]
                        )
                    );*/
                        }
                    )
                  ]
              )
          );
        }
      }())
    )));
  }
}
