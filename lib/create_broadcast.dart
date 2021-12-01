import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'global.dart';

void main() {
  runApp(CreateBroadcast(null, null, null));
}

class CreateBroadcast extends StatefulWidget {
  final context, string, group;
  CreateBroadcast(this.context, this.string, this.group);

  @override
  CreateBroadcastState createState() => CreateBroadcastState();
}

class CreateBroadcastState extends State<CreateBroadcast> with WidgetsBindingObserver {
  var messageController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(
      children: [
        Card(
          elevation: 5,
          clipBehavior: Clip.antiAlias,
          shadowColor: Color(0x4C888888),
            margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)
          ),
          child: Container(width: width, height: 50, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 50, height: 50, child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(child: Icon(Ionicons.arrow_back_outline, color: Global.SECONDARY_COLOR, size: 20))
              )),
              Text(widget.string.broadcast, style: TextStyle(color: Global.SECONDARY_COLOR, fontSize: 14, fontWeight: FontWeight.bold)),
              Container(width: 50, height: 50)
            ]
          ))
        ),
        Expanded(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: width-20-20, height: 150, decoration: BoxDecoration(color: Color(0xfff2f2f2), borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 10),
                              Icon(Ionicons.calendar, color: Color(0xff549658), size: 20),
                              SizedBox(width: 5),
                              Expanded(child: TextField(decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF888888), fontSize: 14), hintText: widget.string.text214, contentPadding: EdgeInsets.only(left: 5, right: 5, bottom: 28)), textAlignVertical: TextAlignVertical.center, controller: messageController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 12, color: Colors.black), maxLength: 200))
                            ]
                        )),
                    SizedBox(height: 15),
                    Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Color(0xCC888888),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        child: Container(
                            width: 180,
                            height: 45,
                            decoration: BoxDecoration(
                                color: Global.SECONDARY_COLOR,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  var message = messageController.text.trim();
                                  if (message == "") {
                                    Global.show(widget.string.text215);
                                    return;
                                  }
                                  var date = Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss");
                                  Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/broadcast_message"),
                                    body: <String, String>{
                                      "user_id": Global.USER_ID.toString(),
                                      "group_id": widget.group['id'].toString(),
                                      "message": message,
                                      "date": date
                                    },
                                    onSuccess: (response) async {
                                      Global.show(widget.string.text216);
                                      var broadcasts = await jsonDecode(await Global.readString("broadcasts", "[]"));
                                      broadcasts.add({
                                        "group_id": widget.group['id'].toString(),
                                        "user_id": Global.USER_ID.toString(),
                                        "message": message,
                                        "sender": jsonEncode(Global.USER_INFO),
                                        "date": date
                                      });
                                      await Global.writeString("broadcasts", jsonEncode(broadcasts));
                                      Navigator.pop(context, true);
                                    });
                                },
                                child: Center(child: Text(widget.string.create, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)))
                            )
                        )
                    ),
                    SizedBox(height: 30)
                  ]
              )
          )
        )
      ]
    )));
  }
}
