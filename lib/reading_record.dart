import 'dart:convert';

import 'package:appumroh/juz_verses.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'global.dart';

void main() {
  runApp(ReadingRecord(null, null, null, null, null, null));
}

class ReadingRecord extends StatefulWidget {
  final context, string, versesCount, lastJuz, lastChapter, lastVerse;
  ReadingRecord(this.context, this.string, this.versesCount, this.lastJuz, this.lastChapter, this.lastVerse);

  @override
  ReadingRecordState createState() => ReadingRecordState();
}

class ReadingRecordState extends State<ReadingRecord> with WidgetsBindingObserver {
  var versesCount = [];
  var histories = [];
  var lastJuz = 0;
  var lastChapter = 0;
  var lastVerse = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "reading_record";
      versesCount = widget.versesCount;
      lastJuz = widget.lastJuz;
      lastChapter = widget.lastChapter;
      lastVerse = widget.lastVerse;
    });
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_juz_histories"),
      body: <String, String>{
        "user_id": Global.USER_ID.toString()
      }, onSuccess: (response) {
        print("get_juz_histories response:");
        print(response);
        setState(() {
          histories = jsonDecode(response);
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
    return width/int.parse(versesCount[lastJuz-1]['verses'].toString())*widget.lastVerse;
  }

  double getBarWidth(width, height, juz) {
    if (versesCount.length <= 0) {
      return 0;
    }
    if (juz > 0) {
      var lastVerse = 30;
      return width / int.parse(versesCount[juz - 1]['verses'].toString()) * lastVerse;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(
      color: Global.SECONDARY_COLOR,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: 50, height: 50, child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                  child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
              )
          )
          ),
          Flexible(
            child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(Global.USER_INFO['name'].toString(), style: TextStyle(
                                          color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold
                                      )),
                                      Text(widget.string.text31, style: TextStyle(
                                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold
                                      )),
                                      (() {
                                        var date = Jiffy().format("d MMMM yyyy");
                                        try {
                                          date = Jiffy(Global.USER_INFO['last_read_date'].toString(), "yyyy-MM-dd HH:mm:ss").format("d MMMM yyyy");
                                        } catch (e) {}
                                        return Text(date, style: TextStyle(
                                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold
                                        ));
                                      }())
                                    ]
                                )
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Image.asset("assets/images/quran_2.png", width: 70, height: 70)
                            )
                          ]
                      ),
                      SizedBox(height: 20),
                      Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(widget.string.text32, style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ))),
                      SizedBox(height: 2),
                      Container(
                          width: width-20-20,
                          margin: EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: Global.MAIN_COLOR,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                          child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(lastJuz.toString(), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                              SizedBox(height: 2),
                                              Text(widget.string.text35, style: TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center)
                                            ]
                                        )
                                    )
                                ),
                                Container(width: 2, height: 70, color: Colors.white),
                                Expanded(
                                    child: Container(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text((30-lastJuz).toString(), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                              SizedBox(height: 2),
                                              Text(widget.string.text34, style: TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center)
                                            ]
                                        )
                                    )
                                )
                              ]
                          )
                      ),
                      SizedBox(height: 10),
                      Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(widget.string.text33, style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ))),
                      Container(
                          padding: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
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
                                        },
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(margin: EdgeInsets.only(left: 10),
                                                  child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Image.asset("assets/images/quran_2.png", width: 45, height: 45),
                                                        SizedBox(width: 2),
                                                        Text(widget.string.juz+" "+lastJuz.toString(), style: TextStyle(
                                                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                                        ))
                                                      ]
                                                  ))
                                            ]
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
                                                  var result = await Global.navigateAndWait(context, JuzVerses(context, widget.string, lastJuz, int.parse(versesCount[lastJuz-1]['verses'].toString()), lastChapter, widget.lastVerse, false));
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
                      Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(widget.string.history, style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ))),
                      ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          padding: EdgeInsets.only(bottom: 12),
                          itemCount: histories.length,
                          itemBuilder: (context, index) {
                            return Container(
                                width: width-20-20,
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 4, bottom: 4
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
                                                child: Text(widget.string.juz+" "+histories[index]['juz'].toString(), style: TextStyle(
                                                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                                ))),
                                            SizedBox.shrink()
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
                                                    var result = await Global.navigateAndWait(context, JuzVerses(context, widget.string, lastJuz, int.parse(versesCount[lastJuz-1]['verses'].toString()), lastChapter, widget.lastVerse, false));
                                                    setState(() {
                                                      lastChapter = int.parse(result['last_chapter'].toString());
                                                      lastVerse = int.parse(result['last_verse'].toString());
                                                    });
                                                    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_last_juz"),
                                                        body: <String, String>{
                                                          "user_id": Global.USER_ID.toString(),
                                                          "juz": histories[index]['juz'].toString(),
                                                          "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
                                                        }, onSuccess: (response) {
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
                    ]
                )
            )
          )
        ]
      )
    )));
  }
}
