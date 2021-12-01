import 'dart:convert';
import 'package:appumroh/main_tab.dart';
import 'package:appumroh/private_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:jiffy/jiffy.dart';

void main() {
  runApp(Chat(null, null));
}

class Chat extends StatefulWidget {
  final context, string;
  Chat(this.context, this.string);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> with WidgetsBindingObserver {
  var chats = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "message";
    });
    refreshMessages();
  }

  Future<void> refreshMessages() async {
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_chats"),
        body: <String, String>{
          "user_id": Global.USER_ID.toString()
        }, onSuccess: (response) {
          print("get_chats response:");
          print(response);
          setState(() {
            chats = jsonDecode(response);
          });
          print("ALL CHATS:");
          print(chats);
        });
  }

  Future<void> onRefreshMessages() async {
    MainTabState.refreshUnreadMessages(widget.string);
    refreshMessages();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: RefreshIndicator(
      onRefresh: onRefreshMessages,
      child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            if (chats[index]['messages'].length > 0) {
              return Material(
                  child: new InkWell(
                      onTap: () async {
                        await Global.navigateAndWait(context, PrivateMessage(
                            context, widget.string, int.parse(chats[index]['id']),
                            chats[index]['opponent']));
                        refreshMessages();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: 10),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(Global.USERDATA_URL +
                                      chats[index]['opponent']['photo'].toString(),
                                      width: 40, height: 40, fit: BoxFit.cover)
                              ),
                              SizedBox(width: 10),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(chats[index]['opponent']['name'].toString(),
                                        style: TextStyle(
                                            color: Color(0xff2b492d),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                        )),
                                    SizedBox(height: 4),
                                    Container(
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .center,
                                            children: [
                                              (() {
                                                var status = chats[index]['status']
                                                    .toString();
                                                if (status == "unsent") {
                                                  return Container(width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(width: 1,
                                                              color: Color(
                                                                  0xffe6e6e6)),
                                                          borderRadius: BorderRadius
                                                              .circular(5)
                                                      ));
                                                } else if (status == "sent") {
                                                  return Container(width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(width: 1,
                                                              color: Color(
                                                                  0xff619065)),
                                                          borderRadius: BorderRadius
                                                              .circular(5)
                                                      ));
                                                } else if (status == "read") {
                                                  return Container(width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                          color: Color(0xff549658),
                                                          borderRadius: BorderRadius
                                                              .circular(5)
                                                      ));
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              }()),
                                              SizedBox(width: 5),
                                              (() {
                                                if (chats[index]['messages'].length >
                                                    0) {
                                                  return Container(
                                                      width: width - 130,
                                                      child: Text(
                                                          chats[index]['messages'][chats[index]['messages']
                                                              .length - 1]['message']
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff2b492d),
                                                              fontSize: 10
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis)
                                                  );
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              }())
                                            ]
                                        )
                                    )
                                  ]
                              ),
                              SizedBox(width: 10)
                            ]
                        )
                      )
                  )
              );
            } else {
              return SizedBox.shrink();
            }
          }
      )
    )));
  }
}
