import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(DoaSholat(null, null, null));
}

class DoaSholat extends StatefulWidget {
  final context, string, sholat;
  DoaSholat(this.context, this.string, this.sholat);

  @override
  DoaSholatState createState() => DoaSholatState();
}

class DoaSholatState extends State<DoaSholat> with WidgetsBindingObserver {

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
                    Text(widget.string.text239, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(width: 45, height: 45)
                  ]
              )
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                      child: Text(widget.sholat['doa']['doa'].toString(), style: TextStyle(
                          color: Colors.black, fontSize: 13
                      ))
                  )))
        ])));
  }
}
