import 'package:appumroh/doa_sholat.dart';
import 'package:appumroh/hukum_sholat.dart';
import 'package:appumroh/keutamaan_sholat.dart';
import 'package:appumroh/rakaat_sholat.dart';
import 'package:appumroh/waktu_sholat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(InfoSholatSunnah(null, null, null));
}

class InfoSholatSunnah extends StatefulWidget {
  final context, string, sholat;
  InfoSholatSunnah(this.context, this.string, this.sholat);

  @override
  InfoSholatSunnahState createState() => InfoSholatSunnahState();
}

class InfoSholatSunnahState extends State<InfoSholatSunnah> with WidgetsBindingObserver {

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
              Text(widget.sholat['name'].toString(), style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Container(width: 45, height: 45)
            ]
        )
    ),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                  elevation: 5,
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Color(0xCC888888),
                  margin: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Container(
                      width: width-10-10,
                      height: 50,
                      decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(30)),
                      child: Material(
                          color: Global.SECONDARY_COLOR,
                          child: new InkWell(
                              onTap: () {
                                Global.navigate(context, HukumSholat(context, widget.string, widget.sholat));
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(widget.string.text238, style: TextStyle(
                                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                        ))
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(Ionicons.arrow_forward_outline, color: Colors.white, size: 20)
                                    )
                                  ]
                              ))
                      )
                  )
              ),
              Card(
                  elevation: 5,
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Color(0xCC888888),
                  margin: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Container(
                      width: width-10-10,
                      height: 50,
                      decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(30)),
                      child: Material(
                          color: Global.SECONDARY_COLOR,
                          child: new InkWell(
                              onTap: () {
                                Global.navigate(context, WaktuSholat(context, widget.string, widget.sholat));
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(widget.string.text239, style: TextStyle(
                                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                        ))
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(Ionicons.arrow_forward_outline, color: Colors.white, size: 20)
                                    )
                                  ]
                              ))
                      )
                  )
              ),
              Card(
                  elevation: 5,
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Color(0xCC888888),
                  margin: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Container(
                      width: width-10-10,
                      height: 50,
                      decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(30)),
                      child: Material(
                          color: Global.SECONDARY_COLOR,
                          child: new InkWell(
                              onTap: () {
                                Global.navigate(context, RakaatSholat(context, widget.string, widget.sholat));
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(widget.string.text240, style: TextStyle(
                                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                        ))
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(Ionicons.arrow_forward_outline, color: Colors.white, size: 20)
                                    )
                                  ]
                              ))
                      )
                  )
              ),
              Card(
                  elevation: 5,
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Color(0xCC888888),
                  margin: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Container(
                      width: width-10-10,
                      height: 50,
                      decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(30)),
                      child: Material(
                          color: Global.SECONDARY_COLOR,
                          child: new InkWell(
                              onTap: () {
                                Global.navigate(context, DoaSholat(context, widget.string, widget.sholat));
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(widget.string.text241, style: TextStyle(
                                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                        ))
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(Ionicons.arrow_forward_outline, color: Colors.white, size: 20)
                                    )
                                  ]
                              ))
                      )
                  )
              ),
              Card(
                  elevation: 5,
                  clipBehavior: Clip.antiAlias,
                  shadowColor: Color(0xCC888888),
                  margin: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Container(
                      width: width-10-10,
                      height: 50,
                      decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(30)),
                      child: Material(
                          color: Global.SECONDARY_COLOR,
                          child: new InkWell(
                              onTap: () {
                                Global.navigate(context, KeutamaanSholat(context, widget.string, widget.sholat));
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(widget.string.text242, style: TextStyle(
                                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                                        ))
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Icon(Ionicons.arrow_forward_outline, color: Colors.white, size: 20)
                                    )
                                  ]
                              ))
                      )
                  )
              )
            ]
          )
        )
      ),
      SizedBox(height: 20)])));
  }
}
