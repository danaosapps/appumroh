import 'dart:convert';

import 'package:appumroh/bottom_bar.dart';
import 'package:appumroh/juz_verses.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'global.dart';

void main() {
  runApp(KhatamHistory(null, null, null));
}

class KhatamHistory extends StatefulWidget {
  final context, string, histories;
  KhatamHistory(this.context, this.string, this.histories);

  @override
  KhatamHistoryState createState() => KhatamHistoryState();
}

class KhatamHistoryState extends State<KhatamHistory> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "khatam_history";
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(
      children: [
        Container(width: width, height: 50, color: Global.MAIN_COLOR, child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 50, height: 50, child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                      child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                  )
              )),
              Text(widget.string.text41, style: TextStyle(color: Colors.white, fontSize: 17)),
              Container(width: 50, height: 50)
            ]
        )),
        Expanded(
          child: Container(
            width: width,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              itemCount: widget.histories.length,
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
                                    child: Text(Jiffy(widget.histories[index]['date'].toString()).format("d MMMM yyyy HH:mm:ss"), style: TextStyle(
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
        ),
        Container(width: width, height: 10, color: Colors.white),
        Container(
            width: width,
            height: 50,
            child: BottomBar(context, widget.string, 1, "khatam_history")
        )
      ]
    )));
  }
}
