import 'dart:convert';

import 'package:appumroh/bottom_bar.dart';
import 'package:appumroh/chapter.dart';
import 'package:appumroh/qurantabs/juz.dart';
import 'package:appumroh/qurantabs/khatam.dart';
import 'package:appumroh/qurantabs/surah.dart';
import 'package:appumroh/search_page.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sprintf/sprintf.dart';

void main() {
  runApp(Quran(null, null));
}

class Quran extends StatefulWidget {
  final context, string;
  Quran(this.context, this.string);

  @override
  QuranState createState() => QuranState();
}

class QuranState extends State<Quran> with WidgetsBindingObserver {
  var currentTabIndex = 0;
  var searchShown = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "quran";
    });
  }

  Widget getQuranScreen() {
    if (currentTabIndex == 0) {
      return Surah(context, widget.string);
    } else if (currentTabIndex == 1) {
      return Juz(context, widget.string);
    } else {
      return Khatam(context, widget.string);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(backgroundColor: Global.MAIN_COLOR, body: SafeArea(
        child: Column(
      children: [
        (() {
          if (searchShown) {
            return Container(width: width, height: 50, color: Global.MAIN_COLOR, child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 50, height: 50, child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          searchShown = false;
                        });
                      },
                      child: Center(
                          child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                      )
                  )),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                            height: 40,
                            margin: EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2)
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Global.navigate(context, SearchPage(context, widget.string));
                              },
                              child: Center(
                                  child: Text(widget.string.text42, style: TextStyle(
                                      color: Color(0xff95a5a6),
                                      fontSize: 15
                                  ))
                              )
                            )
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 35, height: 40, child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                              },
                              child: Center(
                                child: Icon(Ionicons.close_outline, color: Color(0xff95a5a6), size: 20)
                              )
                            )
                          )
                        )
                      ]
                    )
                  ),
                  SizedBox(width: 20)
                ]
            ));
          } else {
            return Container(width: width, height: 50, color: Global.MAIN_COLOR, child: Row(
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
                  Text(widget.string.text15, style: TextStyle(color: Colors.white, fontSize: 17)),
                  Container(width: 50, height: 50, child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Global.navigate(context, SearchPage(context, widget.string));
                        /*setState(() {
                          searchShown = true;
                        });*/
                      },
                      child: Center(
                          child: Icon(Ionicons.search_outline, color: Colors.white, size: 20)
                      )
                  ))
                ]
            ));
          }
        }()),
        Container(
          width: width, height: 50, child: Row(
            children: [
              Container(width: width/3, height: 50, color: currentTabIndex==0?Global.SECONDARY_COLOR:Global.MAIN_COLOR, child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    currentTabIndex = 0;
                  });
                },
                child: Center(child: Text(widget.string.text16, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)))
              )),
              Container(width: width/3, height: 50, color: currentTabIndex==1?Global.SECONDARY_COLOR:Global.MAIN_COLOR, child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      currentTabIndex = 1;
                    });
                  },
                  child: Center(child: Text(widget.string.text17, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)))
              )),
              Container(width: width/3, height: 50, color: currentTabIndex==2?Global.SECONDARY_COLOR:Global.MAIN_COLOR, child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      currentTabIndex = 2;
                    });
                  },
                  child: Center(child: Text(widget.string.text18, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)))
              ))
            ]
          )
        ),
        Expanded(
          child: getQuranScreen()
        ),
        Container(width: width, height: 10, color: Colors.white),
        Container(
            width: width,
            height: 50,
            child: BottomBar(context, widget.string, 1, "quran")
        )
      ]
    )));
  }
}
