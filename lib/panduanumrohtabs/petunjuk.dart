import 'package:appumroh/panduanumrohtabs/bacaan_talbiyah.dart';
import 'package:appumroh/panduanumrohtabs/barang_rekomendasi.dart';
import 'package:appumroh/panduanumrohtabs/cara_ihram.dart';
import 'package:appumroh/panduanumrohtabs/daftar_benda.dart';
import 'package:appumroh/panduanumrohtabs/niat_haji_umroh.dart';
import 'package:appumroh/panduanumrohtabs/perjalanan_haji.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';

void main() {
  runApp(Petunjuk(null, null));
}

class Petunjuk extends StatefulWidget {
  final context, string;
  Petunjuk(this.context, this.string);

  @override
  PetunjukState createState() => PetunjukState();
}

class PetunjukState extends State<Petunjuk> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Container(
                    height: 180, child: Card(
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    shadowColor: Color(0xCC888888),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    margin: EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
                    child: Material(
                        child: new InkWell(
                            onTap: () {
                              Global.navigate(context, NiatHajiUmroh(context, widget.string));
                            },
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(widget.string.text223, style: TextStyle(color: Colors.black, fontSize: 13), textAlign: TextAlign.center),
                                  SizedBox(height: 10),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset("assets/images/hajj.jpg", width: 100, height: 100, fit: BoxFit.cover)
                                  ),
                                  SizedBox(height: 10)
                                ]
                            ))
                    )
                ))),
                Expanded(child: Container(
                    height: 180, child: Card(
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    shadowColor: Color(0xCC888888),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    margin: EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
                    child: Material(
                        child: new InkWell(
                            onTap: () {
                              Global.navigate(context, BacaanTalbiyah(context, widget.string));
                            },
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(widget.string.text224, style: TextStyle(color: Colors.black, fontSize: 13), textAlign: TextAlign.center),
                                  SizedBox(height: 10),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset("assets/images/hajj.jpg", width: 100, height: 100, fit: BoxFit.cover)
                                  ),
                                  SizedBox(height: 10)
                                ]
                            ))
                    )
                )))
              ]
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Container(
                  height: 180, child: Card(
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    shadowColor: Color(0xCC888888),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    margin: EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
                    child: Material(
                        child: new InkWell(
                            onTap: () {
                              Global.navigate(context, PerjalananHaji(context, widget.string));
                            },
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(widget.string.text225, style: TextStyle(color: Colors.black, fontSize: 13), textAlign: TextAlign.center),
                                  SizedBox(height: 10),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset("assets/images/hajj.jpg", width: 100, height: 100, fit: BoxFit.cover)
                                  ),
                                  SizedBox(height: 10)
                                ]
                            ))
                    )
                ))),
                Expanded(child: Container(
                  height: 180, child: Card(
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    shadowColor: Color(0xCC888888),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    margin: EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
                    child: Material(
                        child: new InkWell(
                            onTap: () {
                              Global.navigate(context, DaftarBenda(context, widget.string));
                            },
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(widget.string.text226, style: TextStyle(color: Colors.black, fontSize: 13), textAlign: TextAlign.center),
                                  SizedBox(height: 10),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset("assets/images/hajj.jpg", width: 100, height: 100, fit: BoxFit.cover)
                                  ),
                                  SizedBox(height: 10)
                                ]
                            ))
                    )
                )))
              ]
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Container(
                height: 180, child: Card(
                    elevation: 5,
                    clipBehavior: Clip.antiAlias,
                    shadowColor: Color(0xCC888888),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    margin: EdgeInsets.only(left: 8, right: 4, top: 8, bottom: 8),
                    child: Material(
                        child: new InkWell(
                            onTap: () {
                              Global.navigate(context, BarangRekomendasi(context, widget.string));
                            },
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(widget.string.text227, style: TextStyle(color: Colors.black, fontSize: 13), textAlign: TextAlign.center),
                                  SizedBox(height: 10),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset("assets/images/hajj.jpg", width: 100, height: 100, fit: BoxFit.cover)
                                  ),
                                  SizedBox(height: 10)
                                ]
                            ))
                    )
                ))),
                Expanded(child: Container(
                  height: 180,
                  child: Card(
                      elevation: 5,
                      clipBehavior: Clip.antiAlias,
                      shadowColor: Color(0xCC888888),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      margin: EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
                      child: Material(
                          child: new InkWell(
                              onTap: () {
                                Global.navigate(context, CaraIhram(context, widget.string));
                              },
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(widget.string.text228, style: TextStyle(color: Colors.black, fontSize: 13), textAlign: TextAlign.center),
                                    SizedBox(height: 10),
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset("assets/images/hajj.jpg", width: 100, height: 100, fit: BoxFit.cover)
                                    ),
                                    SizedBox(height: 10)
                                  ]
                              ))
                      )
                  )
                ))
              ]
          )
        ]
    );
  }
}
