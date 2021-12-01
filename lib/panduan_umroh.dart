import 'package:appumroh/panduanumrohtabs/haji.dart';
import 'package:appumroh/panduanumrohtabs/petunjuk.dart';
import 'package:appumroh/panduanumrohtabs/umroh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';
import 'panduanumrohtabs/panduan.dart';

void main() {
  runApp(PanduanUmroh(null, null));
}

class PanduanUmroh extends StatefulWidget {
  final context, string;
  PanduanUmroh(this.context, this.string);

  @override
  PanduanUmrohState createState() => PanduanUmrohState();
}

class PanduanUmrohState extends State<PanduanUmroh> with WidgetsBindingObserver {
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
  }

  Widget getTabContent() {
    if (selectedIndex == 0) {
      return Panduan(context, widget.string);
    } else {
      return Petunjuk(context, widget.string);
    }
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
                  Text(widget.string.text222, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  Container(width: 45, height: 45)
                ]
            )
        ),
        Container(width: width, child: Padding(
          padding: EdgeInsets.only(top: 5, bottom: 5),
            child: Row(
              children: [
                Expanded(child: Padding(padding: EdgeInsets.only(left: 5, right: 5),
                    child: Container(width: (width-10-10)/2, height: 40, decoration: BoxDecoration(
                      color: selectedIndex==0?Global.SECONDARY_COLOR:Colors.white, borderRadius: BorderRadius.circular(30)
                    ), child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          selectedIndex = 0;
                        });
                      },
                      child: Center(child: Text(widget.string.text54, style: TextStyle(color: selectedIndex==0?Colors.white:Global.SECONDARY_COLOR, fontSize: 15, fontWeight: FontWeight.bold)))
                    ))
                )),
                Expanded(child: Padding(padding: EdgeInsets.only(left: 5, right: 5),
                    child: Container(width: (width-10-10)/2, height: 40, decoration: BoxDecoration(
                        color: selectedIndex==1?Global.SECONDARY_COLOR:Colors.white, borderRadius: BorderRadius.circular(30)
                    ), child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                        },
                        child: Center(child: Text(widget.string.text222, style: TextStyle(color: selectedIndex==1?Colors.white:Global.SECONDARY_COLOR, fontSize: 15, fontWeight: FontWeight.bold)))
                    ))
                ))
              ]
            )
        )),
        getTabContent()
      ]
    )));
  }
}
