import 'dart:convert';
import 'package:appumroh/incoming_voice_call.dart';
import 'package:appumroh/outgoing_video_call.dart';
import 'package:appumroh/select_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/rendering.dart';
import 'package:appumroh/outgoing_voice_call.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:permission_handler/permission_handler.dart';
import 'global.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(PrivateMessage(null, null, null, null));
}

class PrivateMessage extends StatefulWidget {
  final context, string, chatID, opponent;
  PrivateMessage(this.context, this.string, this.chatID, this.opponent);

  @override
  PrivateMessageState createState() => PrivateMessageState();
}

class PrivateMessageState extends State<PrivateMessage> with WidgetsBindingObserver {
  static var messages = [];
  var messageController = TextEditingController(text: "");
  var progressShown = false;
  static ScrollController messagesScrollController = new ScrollController();
  var channel = null;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_private_messages_by_chat_id"), body: <String, String>{
      "chat_id": widget.chatID.toString()
    }, onSuccess: (response) {
      var _messages = jsonDecode(response);
      setState(() {
        messages = _messages;
        progressShown = false;
      });
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        messagesScrollController.animateTo(messagesScrollController.position.maxScrollExtent,
          duration: Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
      });
    });
    setState(() {
      Global.CURRENT_SCREEN = "private_message";
      Global.privateMessageSetState = setState;
    });
    await Global.setupXmpp();
    final _channel = WebSocketChannel.connect(
      Uri.parse('ws://'+Global.WS_SERVER+':8080?user_id='+Global.USER_ID.toString()),
    );
    setState(() {
      channel = _channel;
    });
    setState(() {
      Global.XMPP_MESSAGE_LISTENER = (messageBody) {
        var message = jsonDecode(messageBody);
        setState(() {
          messages.add(message);
        });
        Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_message_read_status"), body: <String, String>{
          "id": message['id'].toString(),
          "status": "read"
        });
        new Future.delayed(const Duration(seconds: 1), () {
          messagesScrollController.animateTo(messagesScrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          );
        });
      };
    });
  }

  static void addMessage(message) {
    if (Global.privateMessageSetState != null) {
      Global.privateMessageSetState(() {
        messages.add(message);
      });
      new Future.delayed(const Duration(seconds: 1), () {
        messagesScrollController.animateTo(messagesScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      });
    }
  }

  void sendMessage() async {
    var message = messageController.text;
    if (message.trim() == "") {
      return;
    }
    messageController.text = "";
    Global.hideKeyboard(context);
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/send_message"), body: <String, String>{
      "chat_id": widget.chatID.toString(),
      "sender_id": Global.USER_ID.toString(),
      "receiver_id": widget.opponent['id'].toString(),
      "message": message,
      "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
    }, onSuccess: (response) async {
      var messageObj = jsonDecode(response);
      await Global.sendMessage(jsonEncode(messageObj));
      setState(() {
        messages.add(messageObj);
      });
      new Future.delayed(const Duration(seconds: 1), () {
        messagesScrollController.animateTo(messagesScrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      });
    });
  }

  void goBack(context) {
    Navigator.pop(context);
  }

  Future<bool> onWillPop() async {
    goBack(widget.context);
    return false;
  }

  void sendWebSocketMessage(message) async {
    channel.sink.add(jsonEncode({
      "from": Global.USER_ID.toString(),
      "to": widget.opponent['id'].toString(),
      "message": message
    }));
  }

  void messageReceived(context, message) async {
    var messageObj = jsonDecode(message);
    var obj = jsonDecode(messageObj['message'].toString());
    print("Message received:");
    print(obj);
    var type = obj['type'].toString();
    if (type == "incoming_voice_call") {
      Global.navigate(context, IncomingVoiceCall(context, widget.string,
          int.parse(messageObj['from'].toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(body: SafeArea(child: Stack(
            children: [
              Image.asset("assets/images/chat_bg.png", width: width, height: height,
                  fit: BoxFit.cover),
              Padding(
                  padding: EdgeInsets.only(top: 60, bottom: 100),
                  child: (() {
                    if (progressShown) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return ListView.builder(
                          controller: messagesScrollController,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var message = messages[index];
                            var senderID = int.parse(message['sender_id'].toString());
                            var receiverID = int.parse(message['receiver_id'].toString());
                            if (senderID == Global.USER_ID) {
                              if (message['message_type'].toString() == "location") {
                                return Padding(
                                    padding: EdgeInsets.only(left: 20, right: 20),
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                            padding: EdgeInsets.only(left: 30, top: 4, bottom: 4),
                                            child: Card(
                                                elevation: 5,
                                                clipBehavior: Clip.antiAlias,
                                                shadowColor: Color(0x4C888888),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20)
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Flexible(
                                                              child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                  children: [
                                                                    Text(messages[index]['message'].toString(), style: TextStyle(
                                                                        color: Color(0xff529658), fontSize: 13
                                                                    ), textAlign: TextAlign.end),
                                                                    Text("http://maps.google.com/maps?q="+messages[index]['latitude'].toString()+","+messages[index]['longitude'].toString(), style: TextStyle(
                                                                        color: Color(0xff529658), fontSize: 13
                                                                    ), textAlign: TextAlign.end)
                                                                  ]
                                                              )
                                                          ),
                                                          SizedBox(width: 30),
                                                          Text(Jiffy(messages[index]['date'].toString(), "yyyy-MM-dd HH:mm:ss").format("HH:mm"),
                                                              style: TextStyle(color: Color(0xffa0aaa1), fontSize: 10
                                                              )),
                                                          SizedBox(width: 8),
                                                          (() {
                                                            var status = messages[index]['status'].toString();
                                                            if (status == "unsent") {
                                                              return Container(width: 10, height: 10, decoration: BoxDecoration(
                                                                  border: Border.all(width: 1, color: Color(0xffe6e6e6)),
                                                                  borderRadius: BorderRadius.circular(5)
                                                              ));
                                                            } else if (status == "sent") {
                                                              return Container(width: 10, height: 10, decoration: BoxDecoration(
                                                                  border: Border.all(width: 1, color: Color(0xff619065)),
                                                                  borderRadius: BorderRadius.circular(5)
                                                              ));
                                                            } else if (status == "read") {
                                                              return Container(width: 10, height: 10, decoration: BoxDecoration(
                                                                  color: Color(0xff549658),
                                                                  borderRadius: BorderRadius.circular(5)
                                                              ));
                                                            } else {
                                                              return SizedBox.shrink();
                                                            }
                                                          }())
                                                        ]
                                                    )
                                                )
                                            )
                                        )
                                    )
                                );
                              } else {
                                return Padding(
                                    padding: EdgeInsets.only(left: 20, right: 20),
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                            padding: EdgeInsets.only(left: 30, top: 4, bottom: 4),
                                            child: Card(
                                                elevation: 5,
                                                clipBehavior: Clip.antiAlias,
                                                shadowColor: Color(0x4C888888),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20)
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Flexible(
                                                              child: Text(messages[index]['message'].toString(), style: TextStyle(
                                                                  color: Color(0xff529658), fontSize: 13
                                                              ), textAlign: TextAlign.end)
                                                          ),
                                                          SizedBox(width: 30),
                                                          Text(Jiffy(messages[index]['date'].toString(), "yyyy-MM-dd HH:mm:ss").format("HH:mm"),
                                                              style: TextStyle(color: Color(0xffa0aaa1), fontSize: 10
                                                              )),
                                                          SizedBox(width: 8),
                                                          (() {
                                                            var status = messages[index]['status'].toString();
                                                            if (status == "unsent") {
                                                              return Container(width: 10, height: 10, decoration: BoxDecoration(
                                                                  border: Border.all(width: 1, color: Color(0xffe6e6e6)),
                                                                  borderRadius: BorderRadius.circular(5)
                                                              ));
                                                            } else if (status == "sent") {
                                                              return Container(width: 10, height: 10, decoration: BoxDecoration(
                                                                  border: Border.all(width: 1, color: Color(0xff619065)),
                                                                  borderRadius: BorderRadius.circular(5)
                                                              ));
                                                            } else if (status == "read") {
                                                              return Container(width: 10, height: 10, decoration: BoxDecoration(
                                                                  color: Color(0xff549658),
                                                                  borderRadius: BorderRadius.circular(5)
                                                              ));
                                                            } else {
                                                              return SizedBox.shrink();
                                                            }
                                                          }())
                                                        ]
                                                    )
                                                )
                                            )
                                        )
                                    )
                                );
                              }
                            } else if (receiverID == Global.USER_ID) {
                              return Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                          padding: EdgeInsets.only(right: 30, top: 4, bottom: 4),
                                          child: Card(
                                              elevation: 5,
                                              clipBehavior: Clip.antiAlias,
                                              shadowColor: Color(0x4C888888),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20)
                                              ),
                                              color: Color(0xff549658),
                                              child: Padding(
                                                  padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                                                  child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Flexible(
                                                          child: Text(messages[index]['message'].toString(), style: TextStyle(
                                                              color: Colors.white, fontSize: 13
                                                          ))
                                                        ),
                                                        SizedBox(width: 30),
                                                        Text(Jiffy(messages[index]['date'].toString(), "yyyy-MM-dd HH:mm:ss").format("HH:mm"),
                                                            style: TextStyle(color: Color(0xff334934), fontSize: 10
                                                            ))
                                                      ]
                                                  )
                                              )
                                          )
                                      )
                                  )
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          }
                      );
                    }
                  }())
              ),
              Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                      elevation: 5,
                      clipBehavior: Clip.antiAlias,
                      shadowColor: Color(0x4C888888),
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)
                      ),
                      child: Container(
                          width: width,
                          child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(width: 40, height: 40, child: GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: () {
                                                goBack(widget.context);
                                              },
                                              child: Center(child: Icon(Ionicons.chevron_back, color: Color(0xff2f5031), size: 20))
                                          )),
                                          SizedBox(width: 4),
                                          ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.network(Global.USERDATA_URL+widget.opponent['photo'].toString(),
                                                  width: 40, height: 40, fit: BoxFit.cover)
                                          ),
                                          SizedBox(width: 14),
                                          Text(widget.opponent['name'].toString(), style: TextStyle(color: Color(0xff2a452d), fontSize: 15, fontWeight: FontWeight.bold))
                                        ]
                                    ),
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(width: 35, height: 40, child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              Global.navigate(context, OutgoingVideoCall(context, widget.string, widget.opponent));
                                            },
                                            child: Center(
                                                child: Icon(Ionicons.videocam, color: Color(0xff529658), size: 20)
                                            )
                                          )),
                                          Container(width: 35, height: 40, child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              Global.navigate(context, OutgoingVoiceCall(context, widget.string, widget.opponent));
                                            },
                                            child: Center(
                                                child: Icon(Ionicons.call, color: Color(0xff529658), size: 20)
                                            )
                                          )),
                                          Container(width: 35, height: 40, child: Center(
                                              child: Image.asset("assets/images/menu.png", width: 30, height: 30)
                                          ))
                                        ]
                                    )
                                  ]
                              )
                          )
                      )
                  )
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                      elevation: 50,
                      clipBehavior: Clip.antiAlias,
                      shadowColor: Color(0x4C888888),
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)
                      ),
                      child: Container(
                          width: width,
                          height: 100,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Container(
                                  height: 100,
                                    child: TextField(decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text97, contentPadding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10)), textAlignVertical: TextAlignVertical.center, controller: messageController, keyboardType: TextInputType.multiline, maxLines: null, style: TextStyle(fontSize: 14))
                                )),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        width: 50,
                                        height: 60,
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                        title: Text(widget.string.text268),
                                                        content: Container(
                                                          width: width-10-10,
                                                          child: ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: 2,
                                                            itemBuilder: (BuildContext context, int index) {
                                                              if (index == 0) {
                                                                return ListTile(title: Text(widget.string.text262), onTap: () async {
                                                                  Navigator.pop(context);
                                                                  Map<Permission, PermissionStatus> statuses = await [
                                                                    Permission.location
                                                                  ].request();
                                                                  LatLng location = await Global.navigateAndWait(context, SelectLocation(context, widget.string));
                                                                  List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
                                                                  print("ALL PLACEMARKS:");
                                                                  print(placemarks);
                                                                  Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/send_location"),
                                                                    body: <String, String>{
                                                                      "chat_id": widget.chatID.toString(),
                                                                      "lat": location.latitude.toString(),
                                                                      "lng": location.longitude.toString(),
                                                                      "sender_id": Global.USER_ID.toString(),
                                                                      "receiver_id": widget.opponent['id'].toString(),
                                                                      "message_type": "location",
                                                                      "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
                                                                    }, onSuccess: (response) async {
                                                                        var messageObj = jsonDecode(response);
                                                                        setState(() {
                                                                          messages.add(messageObj);
                                                                        });
                                                                        new Future.delayed(const Duration(seconds: 1), () {
                                                                          messagesScrollController.animateTo(messagesScrollController.position.maxScrollExtent,
                                                                            duration: Duration(milliseconds: 500),
                                                                            curve: Curves.fastOutSlowIn,
                                                                          );
                                                                        });
                                                                    });
                                                                });
                                                              } else {
                                                                return ListTile(title: Text(widget.string.text117), onTap: () async {
                                                                  Navigator.pop(context);
                                                                  Map<Permission, PermissionStatus> statuses = await [
                                                                    Permission.location
                                                                  ].request();
                                                                });
                                                              }
                                                            },
                                                          ),
                                                        )
                                                    );
                                                  });
                                            },
                                            child: Center(
                                              child: Icon(Ionicons.attach, color: Color(0xffbdc3c7), size: 25)
                                            )
                                        )
                                    ),
                                    Container(
                                        width: 50,
                                        height: 60,
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              sendMessage();
                                            },
                                            child: Center(
                                                child: Icon(Ionicons.send, color: Color(0xfff3498db), size: 25)
                                            )
                                        )
                                    )
                                  ]
                                )
                              ]
                          )
                      )
                  )
              ),
              (() {
                if (channel == null) {
                  return SizedBox.shrink();
                } else {
                  return StreamBuilder(
                      stream: channel.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          messageReceived(context, snapshot.data);
                        }
                        return SizedBox.shrink();
                      }
                  );
                }
              }())
            ]
        )))
    );
  }
}
