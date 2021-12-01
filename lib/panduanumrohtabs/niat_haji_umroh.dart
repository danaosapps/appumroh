import 'package:appumroh/panduanumrohtabs/niat_haji.dart';
import 'package:appumroh/panduanumrohtabs/niat_umroh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(NiatHajiUmroh(null, null));
}

class NiatHajiUmroh extends StatefulWidget {
  final context, string;
  NiatHajiUmroh(this.context, this.string);

  @override
  NiatHajiUmrohState createState() => NiatHajiUmrohState();
}

class NiatHajiUmrohState extends State<NiatHajiUmroh> with WidgetsBindingObserver {

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
              Text(widget.string.text223, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Container(width: 45, height: 45)
            ]
          )
        ),
        SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(padding: EdgeInsets.only(left: 10, right: 10),
                child: Text(widget.string.text229, style: TextStyle(color: Colors.black, fontSize: 14))),
              SizedBox(height: 4),
              Padding(padding: EdgeInsets.only(left: 10, right: 10),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Global.navigate(context, NiatHaji(context, widget.string));
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20), child: Image.asset("assets/images/haji.jpg", width: width-10-10, height: 150, fit: BoxFit.cover))
                  )),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 40, height: 40, child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {},
                      child: Center(
                          child: Icon(Ionicons.play_back, color: Color(0x7f4c945c), size: 24)
                      )
                  )),
                  Container(width: 45, height: 45, child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {},
                      child: Center(
                          child: Icon(Ionicons.play, color: Global.SECONDARY_COLOR, size: 24)
                      )
                  )),
                  Container(width: 40, height: 40, child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {},
                      child: Center(
                          child: Icon(Ionicons.play_forward, color: Color(0x7f4c945c), size: 24)
                      )
                  ))
                ]
              ),
              SizedBox(height: 10),
              Padding(padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(widget.string.text230, style: TextStyle(color: Colors.black, fontSize: 14))),
              SizedBox(height: 4),
              Padding(padding: EdgeInsets.only(left: 10, right: 10),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Global.navigate(context, NiatUmroh(context, widget.string));
                    },
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20), child: Image.asset("assets/images/haji.jpg", width: width-10-10, height: 150, fit: BoxFit.cover))
                  )),
              SizedBox(height: 2),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 40, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {},
                        child: Center(
                            child: Icon(Ionicons.play_back, color: Color(0x7f4c945c), size: 24)
                        )
                    )),
                    Container(width: 45, height: 45, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {},
                        child: Center(
                            child: Icon(Ionicons.play, color: Global.SECONDARY_COLOR, size: 24)
                        )
                    )),
                    Container(width: 40, height: 40, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {},
                        child: Center(
                            child: Icon(Ionicons.play_forward, color: Color(0x7f4c945c), size: 24)
                        )
                    ))
                  ]
              ),
              SizedBox(height: 10),
            ]
          )
        )]
    )));
  }
}
