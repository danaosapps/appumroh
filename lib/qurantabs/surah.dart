import 'dart:convert';
import 'package:appumroh/chapter.dart';
import 'package:appumroh/khatam_history.dart';
import 'package:appumroh/schedule_khatam.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(Surah(null, null));
}

class Surah extends StatefulWidget {
  final context, string;
  Surah(this.context, this.string);

  @override
  SurahState createState() => SurahState();
}

class SurahState extends State<Surah> with WidgetsBindingObserver {
  var surahs = [];
  var progressShown = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "surah";
      progressShown = true;
    });
    Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_chapters"),
        onSuccess: (response) {
          setState(() {
            surahs = jsonDecode(response);
            progressShown = false;
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
        Expanded(
            child: progressShown?Container(width: width, color: Colors.white, child: Center(
                child: CircularProgressIndicator()
            )):Container(
                child: ListView.builder(
                    itemCount: surahs.length,
                    itemBuilder: (context, index) {
                      return Column(
                          children: [
                            Container(
                                width: width,
                                height: 100,
                                color: Global.MAIN_COLOR,
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Global.navigate(context, Chapter(context, widget.string, surahs[index], false, 0));
                                    },
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 20),
                                          Text((index+1).toString()+".", style: TextStyle(color: Colors.white, fontSize: 15)),
                                          SizedBox(width: 20),
                                          Expanded(
                                              child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(surahs[index]['chapter_id'].toString(), style: TextStyle(
                                                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                                    )),
                                                    Text(surahs[index]['meaning'].toString()+" ("+surahs[index]['verses'].toString()+")", style: TextStyle(
                                                        color: Colors.white, fontSize: 15
                                                    ))
                                                  ]
                                              )
                                          ),
                                          SizedBox(width: 20),
                                          Padding(
                                              padding: EdgeInsets.only(right: 20),
                                              child: Text(jsonDecode(surahs[index]['chapter_ar'].toString())[0].toString(),
                                                  style: TextStyle(color: Colors.white, fontSize: 40, fontFamily: "SurahIcon"
                                                  )))
                                        ]
                                    )
                                )
                            ),
                            Container(width: width, height: 1, color: Color(0x30ffffff))
                          ]
                      );
                    }
                )
            )
        )
      ]
    ));
  }
}
