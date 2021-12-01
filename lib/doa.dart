import 'dart:convert';
import 'package:appumroh/info_sholat_sunnah.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(Doa(null, null, null));
}

class Doa extends StatefulWidget {
  final context, string, doa;
  Doa(this.context, this.string, this.doa);

  @override
  DoaState createState() => DoaState();
}

class DoaState extends State<Doa> with WidgetsBindingObserver {

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
          Container(
              width: width,
              height: 45,
              color: Global.SECONDARY_COLOR,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 45, height: 45, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Get.back();
                        },
                        child: Center(
                            child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                        )
                    )),
                    Text(widget.doa['title'].toString(), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(width: 45, height: 45)
                  ]
              )
          ),
          Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(widget.doa['title'].toString(), style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold))
                      )
                    ),
                    SizedBox(height: 15),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(widget.doa['arab'].toString(), style: TextStyle(color: Colors.black, fontSize: 19)))
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Text(widget.string.text250, style: TextStyle(color: Color(0xffe74c3c), fontSize: 13, fontStyle: FontStyle.italic))),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(widget.doa['latin'].toString(), style: TextStyle(color: Colors.black, fontSize: 15))),
                    SizedBox(height: 5),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(widget.string.text249, style: TextStyle(color: Color(0xffe74c3c), fontSize: 13, fontStyle: FontStyle.italic))),
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(widget.doa['meaning'].toString(), style: TextStyle(color: Colors.black, fontSize: 15))),
                    SizedBox(height: 20),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(widget.string.text251, style: TextStyle(color: Color(0xffe74c3c), fontSize: 13, fontStyle: FontStyle.italic)))
                    ),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: EdgeInsets.only(left: 40, right: 10),
                            child: Text(widget.doa['source'].toString(), style: TextStyle(color: Colors.black, fontSize: 12), textAlign: TextAlign.end))
                    ),
                    SizedBox(height: 5)
                  ]
                )
              ))
        ])));
  }
}
