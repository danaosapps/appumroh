import 'dart:convert';

import 'package:appumroh/juz_verses.dart';
import 'package:appumroh/reading_record.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';

void main() {
  runApp(Juz(null, null));
}

class Juz extends StatefulWidget {
  final context, string;
  Juz(this.context, this.string);

  @override
  JuzState createState() => JuzState();
}

class JuzState extends State<Juz> with WidgetsBindingObserver {
  var progressShown = false;
  var versesCount = [];
  int lastJuz = 0, lastChapter = 0, lastVerse = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "juz";
    });
    getLastData();
  }

  void getLastData() {
    setState(() {
      progressShown = true;
    });
    Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_all_juz_verses_count"),
        onSuccess: (response) {
          setState(() {
            versesCount = jsonDecode(response);
          });
          Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_last_juz"),
              body: <String, String>{
                "user_id": Global.USER_ID.toString()
              }, onSuccess: (response) {
                print("get_last_juz response:");
                print(response);
                var obj = jsonDecode(response);
                setState(() {
                  lastJuz = int.parse(obj['last_juz'].toString());
                  lastChapter = int.parse(obj['last_chapter'].toString());
                  lastVerse = int.parse(obj['last_verse'].toString());
                  progressShown = false;
                });
              });
        });
  }

  double getLastBarWidth(width, height) {
    if (versesCount.length <= 0) {
      return 0;
    }
    if (lastJuz <= 0) {
      return 0;
    }
    return width/int.parse(versesCount[lastJuz-1]['verses'].toString())*lastVerse;
  }

  double getBarWidth(width, height, juz) {
    if (versesCount.length <= 0) {
      return 0;
    }
    if (juz < lastJuz) {
      return width;
    } else if (juz == lastJuz) {
      if (juz > 0) {
        return width / int.parse(versesCount[juz - 1]['verses'].toString()) * lastVerse;
      } else {
        return 0;
      }
    } else {
      return 0;
    }
    return 0;
  }

  bool isMarkingShown(juz) {
    if (juz < lastJuz) {
      return false;
    } else if (juz == lastJuz) {
      return true;
    } else {
      return true;
    }
    return false;
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
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 5),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Global.navigate(context, ReadingRecord(context, widget.string, versesCount, lastJuz, lastChapter, lastVerse));
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(width: 45, height: 45,
                                      margin: EdgeInsets.only(left: 10),
                                      child: Center(
                                          child: Image.asset("assets/images/quran_2.png", width: 45, height: 45)
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(widget.string.text24, style: TextStyle(
                                                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold
                                            )),
                                            Icon(Ionicons.chevron_forward_outline, color: Colors.white, size: 20)
                                          ]
                                      ))
                                ]
                            )
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(widget.string.juz+" "+lastJuz.toString(), style: TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                              ))
                            )
                          ),
                          SizedBox(height: 2),
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
                                    width: getLastBarWidth(width, height),
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 100,
                              height: 20,
                              margin: EdgeInsets.only(top: 4, right: 10),
                              decoration: BoxDecoration(
                                color: Global.SECONDARY_COLOR,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_last_juz"),
                                      body: <String, String>{
                                        "user_id": Global.USER_ID.toString(),
                                        "juz": lastJuz.toString(),
                                        "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
                                      }, onSuccess: (response) {
                                      });
                                  var result = await Global.navigateAndWait(context, JuzVerses(context, widget.string, lastJuz, int.parse(versesCount[lastJuz-1]['verses'].toString()), lastChapter, lastVerse, false));
                                  setState(() {
                                    lastChapter = int.parse(result['last_chapter'].toString());
                                    lastVerse = int.parse(result['last_verse'].toString());
                                  });
                                  getLastData();
                                },
                                child: Center(
                                  child: Text(widget.string.text25, style: TextStyle(
                                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold
                                  ))
                                )
                              )
                            )
                          ),
                          SizedBox(height: 10)
                        ]
                      )
                  )
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  child: Text(widget.string.text26, style: TextStyle(
                    color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold
                  ))
              )),
              (() {
                if (progressShown) {
                  return Expanded(
                    child: Container(width: width-10-10,
                        decoration: BoxDecoration(
                            color: Global.MAIN_COLOR,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white
                      )
                    ))
                  );
                } else {
                  return Flexible(
                      child: ListView.builder(
                          itemCount: 30,
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
                                                child: Text(widget.string.juz+" "+(index+1).toString(), style: TextStyle(
                                                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                                ))),
                                            Container(
                                                height: 20,
                                                decoration: BoxDecoration(
                                                    color: Global.SECONDARY_COLOR,
                                                    borderRadius: BorderRadius.circular(4)
                                                ),
                                                margin: EdgeInsets.only(right: 10),
                                                padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                                                child: GestureDetector(
                                                    behavior: HitTestBehavior.translucent,
                                                    onTap: () async {
                                                      await Global.showProgressDialog(context, widget.string.text29);
                                                      Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_last_verse"),
                                                          body: <String, String>{
                                                            "user_id": Global.USER_ID.toString(),
                                                            "last_juz": (index+1).toString(),
                                                            "last_chapter": versesCount[index]['last_chapter'].toString(),
                                                            "last_verse": versesCount[index]['last_verse'].toString()
                                                          }, onSuccess: (response) async {
                                                            print("update_last_verse response:");
                                                            print(response);
                                                            await Global.hideProgressDialog(context);
                                                            setState(() {
                                                              if (index <= 28) {
                                                                lastJuz = index + 2;
                                                              }
                                                              lastChapter = int.parse(versesCount[index]['last_chapter'].toString());
                                                              lastVerse = 0;
                                                            });
                                                          });
                                                      Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/insert_khatam_history"),
                                                          body: <String, String>{
                                                            "user_id": Global.USER_ID.toString(),
                                                            "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
                                                          }, onSuccess: (response) async {
                                                          });
                                                    },
                                                    child: Center(
                                                        child: Text(widget.string.text27, style: TextStyle(
                                                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold
                                                        ))
                                                    )
                                                )
                                            )
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
                                                    width: getBarWidth(width, height, index+1),
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
                                                    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_last_juz"),
                                                        body: <String, String>{
                                                          "user_id": Global.USER_ID.toString(),
                                                          "juz": (index+1).toString(),
                                                          "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
                                                        }, onSuccess: (response) {
                                                        });
                                                    var result = await Global.navigateAndWait(context, JuzVerses(context, widget.string, index+1, int.parse(versesCount[index]['verses'].toString()), lastChapter, lastVerse, index<=lastJuz));
                                                    setState(() {
                                                      lastChapter = int.parse(result['last_chapter'].toString());
                                                      lastVerse = int.parse(result['last_verse'].toString());
                                                    });
                                                    getLastData();
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
                  );
                }
              }())
            ]
        ));
  }
}
