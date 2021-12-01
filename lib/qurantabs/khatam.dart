import 'dart:convert';

import 'package:appumroh/juz_verses.dart';
import 'package:appumroh/khatam_history.dart';
import 'package:appumroh/schedule_khatam.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';

void main() {
  runApp(Khatam(null, null));
}

class Khatam extends StatefulWidget {
  final context, string;
  Khatam(this.context, this.string);

  @override
  KhatamState createState() => KhatamState();
}

class KhatamState extends State<Khatam> with WidgetsBindingObserver {
  var histories = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "khatam";
    });
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_khatam_histories"),
      body: <String, String>{
        "user_id": Global.USER_ID.toString()
      }, onSuccess: (response) {
        setState(() {
          histories = jsonDecode(response);
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height-188,
        color: Colors.white,
      child: Column(
        children: [
          Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
              child: Container(
                  width: width-10-10,
                  decoration: BoxDecoration(
                      color: Global.MAIN_COLOR,
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Global.navigate(context, ScheduleKhatam(context, widget.string));
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 10),
                          Container(width: 80, height: 80,
                              child: Center(
                                  child: Image.asset("assets/images/quran_2.png", width: 70, height: 70)
                              )),
                          Container(
                              width: width-10-10-90-20,
                              margin: EdgeInsets.only(right: 20),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(widget.string.text19, style: TextStyle(
                                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold
                                    )),
                                    SizedBox(height: 2),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(widget.string.text20, style: TextStyle(
                                              color: Colors.white, fontSize: 13
                                          )),
                                          SizedBox(width: 0),
                                          Icon(Ionicons.chevron_down_outline, color: Colors.white, size: 15)
                                        ]
                                    )
                                  ]
                              ))
                        ]
                    )
                  )
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(widget.string.history, style: TextStyle(
                  color: Colors.black, fontSize: 13
                ))
              ),Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Global.MAIN_COLOR,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Global.navigate(context, KhatamHistory(context, widget.string, histories));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Center(
                            child: Text(widget.string.view_all, style: TextStyle(
                                color: Colors.white, fontSize: 10
                            ))
                        )
                      )
                    )
                  )
              )
            ]
          ),
          SizedBox(height: 8),
          Flexible(
              child: ListView.builder(
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    return Container(
                        width: width-10-10,
                        margin: EdgeInsets.only(
                            left: 10, right: 10, top: 4, bottom: 4
                        ),
                        decoration: BoxDecoration(
                            color: Global.MAIN_COLOR,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                            children: [
                              SizedBox(height: 8),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(widget.string.juz+" 30", style: TextStyle(
                                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                        ))),
                                    Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(Jiffy(histories[index]['date'].toString()).format("d MMMM yyyy HH:mm:ss"), style: TextStyle(
                                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold
                                        )))
                                  ]
                              ),
                              SizedBox(height: 8),
                              Container(
                                  width: width-10-10,
                                  height: 10,
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                      color: Color(0xff231f20),
                                      borderRadius: BorderRadius.circular(4)
                                  ),
                                  child: Stack(
                                      children: [
                                        Container(
                                            width: width-20-20,
                                            height: 10,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: <Color>[
                                                      Color(0xfff1c40f),
                                                      Color(0xfff39c12)
                                                    ]
                                                ),
                                                borderRadius: BorderRadius.circular(4)
                                            )
                                        )
                                      ]
                                  )
                              ),
                              SizedBox(height: 8),
                              Container(
                                  width: width-10-10,
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () async {
                                            await Global.showProgressDialog(context, widget.string.loading);
                                            Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_last_juz"),
                                                body: <String, String>{
                                                  "user_id": Global.USER_ID.toString(),
                                                  "juz": (index+1).toString(),
                                                  "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
                                                }, onSuccess: (response) {
                                                  Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_juz_verses_count"),
                                                      body: <String, String>{
                                                        "juz": (index+1).toString()
                                                      }, onSuccess: (response) async {
                                                        var obj = jsonDecode(response);
                                                        var verses = int.parse(obj['verses'].toString());
                                                        var lastChapter = int.parse(obj['last_chapter'].toString());
                                                        var lastVerse = int.parse(obj['last_verse'].toString());
                                                        await Global.hideProgressDialog(context);
                                                        var result = await Global.navigateAndWait(context, JuzVerses(context, widget.string, index+1, verses, lastChapter, lastVerse, true));
                                                      });
                                                });
                                          },
                                          child: Padding(
                                              padding: EdgeInsets.only(right: 10),
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(widget.string.text25, style: TextStyle(
                                                        color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold
                                                    )),
                                                    SizedBox(width: 2),
                                                    Icon(Ionicons.chevron_forward_outline, color: Colors.white, size: 17)
                                                  ]
                                              )
                                          )
                                      )
                                  )),
                              SizedBox(height: 8)
                            ]
                        )
                    );
                  }
              )
          )
        ]
      )
    );
  }
}
