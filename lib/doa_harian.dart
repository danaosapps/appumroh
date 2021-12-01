import 'dart:convert';
import 'package:appumroh/doa.dart';
import 'package:appumroh/info_sholat_sunnah.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(DoaHarian(null, null));
}

class DoaHarian extends StatefulWidget {
  final context, string;
  DoaHarian(this.context, this.string);

  @override
  DoaHarianState createState() => DoaHarianState();
}

class DoaHarianState extends State<DoaHarian> with WidgetsBindingObserver {
  var doas = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_doa_harian"),
        onSuccess: (response) {
          setState(() {
            doas = jsonDecode(response);
          });
        });
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
                    Text(widget.string.text248, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(width: 45, height: 45)
                  ]
              )
          ),
          Expanded(
              child: ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: doas.length,
                  itemBuilder: (context, index) {
                    return Card(
                        elevation: 5,
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Color(0xCC888888),
                        margin: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                        ),
                        child: Container(
                            width: width-10-10,
                            height: 60,
                            decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(30)),
                            child: Material(
                                color: Global.SECONDARY_COLOR,
                                child: new InkWell(
                                    onTap: () {
                                      Global.navigate(context, Doa(context, widget.string, doas[index]));
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 0, bottom: 0),
                                      child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.only(left: 20),
                                                  child: Text(doas[index]['title'].toString(), style: TextStyle(
                                                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                                  ), maxLines: 2)
                                              ),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.only(right: 20),
                                                child: Icon(Ionicons.arrow_forward_outline, color: Colors.white, size: 20)
                                            )
                                          ]
                                      )
                                    ))
                            )
                        )
                    );
                  }
              ))
        ])));
  }
}
