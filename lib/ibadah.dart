import 'package:appumroh/arah_kiblat.dart';
import 'package:appumroh/doa_harian.dart';
import 'package:appumroh/ibadah/quran.dart';
import 'package:appumroh/jadwal_sholat.dart';
import 'package:appumroh/panduan_umroh.dart';
import 'package:appumroh/sholat_sunnah.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'bottom_bar.dart';
import 'global.dart';

void main() {
  runApp(Ibadah(null, null));
}

class Ibadah extends StatefulWidget {
  final context, string;
  Ibadah(this.context, this.string);

  @override
  IbadahState createState() => IbadahState();
}

class IbadahState extends State<Ibadah> with WidgetsBindingObserver {
  var menus = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "ibadah";
      menus = [
        {"name": widget.string.text2, "image": "quran.jpg", "screen": Quran(widget.context, widget.string)},
        {"name": widget.string.text3, "image": "clock.jpg", "screen": JadwalSholat()},
        {"name": widget.string.text4, "image": "mecca.jpg", "screen": ArahKiblat()},
        {"name": widget.string.text7, "image": "sunnah_prayer.jpg", "screen": SholatSunnah(widget.context, widget.string)},
        {"name": widget.string.text8, "image": "daily_prayer.jpg", "screen": DoaHarian(widget.context, widget.string)},
        {"name": widget.string.text5, "image": "tasbih.jpg", "screen": null},
        {"name": widget.string.text6, "image": "hajj.jpg", "screen": PanduanUmroh(widget.context, widget.string)},
        {"name": widget.string.text9, "image": "public_places.jpg", "screen": null},
        {"name": widget.string.text10, "image": "travel_info.jpg", "screen": null}
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(
        child: Stack(
            children: [
              Container(width: width, height: height-50, child: Center(
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    children: List.generate(9, (index) {
                      return Container(width: width/3, child: Center(
                          child: Container(
                              width: 100, height: 100,
                              child: Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset("assets/images/"+menus[index]['image'].toString(),
                                            width: 100, height: 100, fit: BoxFit.cover)
                                    ),
                                    Container(width: 100, height: 100, decoration: BoxDecoration(
                                        color: Color(0x7F000000),
                                        borderRadius: BorderRadius.circular(50)
                                    ), child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          if (menus[index]['screen'] != null) {
                                            Global.navigate(context, menus[index]['screen']);
                                          }
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.only(left: 10, right: 10),
                                            child: Center(
                                                child: Text(menus[index]['name'].toString(), style: TextStyle(
                                                    color: Colors.white, fontSize: 12,
                                                    fontWeight: FontWeight.bold
                                                ), textAlign: TextAlign.center)
                                            )
                                        )
                                    ))
                                  ]
                              )
                          )
                      ));
                    }),
                  )
              )),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      width: width,
                      height: 50,
                      child: BottomBar(context, widget.string, 1, "ibadah")
                  )
              ),
            ]
        )
    )));
  }
}
