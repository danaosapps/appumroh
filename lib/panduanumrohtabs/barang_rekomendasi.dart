import 'dart:convert';
import 'package:appumroh/panduanumrohtabs/bacaan_talbiyah.dart';
import 'package:appumroh/panduanumrohtabs/niat_haji_umroh.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(BarangRekomendasi(null, null));
}

class BarangRekomendasi extends StatefulWidget {
  final context, string;
  BarangRekomendasi(this.context, this.string);

  @override
  BarangRekomendasiState createState() => BarangRekomendasiState();
}

class BarangRekomendasiState extends State<BarangRekomendasi> with WidgetsBindingObserver {
  var barangRekomendasi = {};

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_barang_rekomendasi"),
        onSuccess: (response) {
          var _barangRekomendasi = jsonDecode(response);
          setState(() {
            barangRekomendasi = _barangRekomendasi;
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
                    Text(widget.string.text235, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(width: 45, height: 45)
                  ]
              )
          ),
          Expanded(child: SingleChildScrollView(
              child: Column(
                  children: [
                    SizedBox(height: 10),
                    Padding(padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(barangRekomendasi['barang'].length.toString()+" "+widget.string.text236, style: TextStyle(color: Colors.black, fontSize: 14))),
                    SizedBox(height: 2),
                    Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(barangRekomendasi['description'].toString(), style: TextStyle(color: Colors.black, fontSize: 14)))),
                    SizedBox(height: 10),
                    ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: barangRekomendasi['barang'].length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 10),
                              child: Text((index+1).toString()+". "+barangRekomendasi['barang'][index]['title'].toString(), style: TextStyle(
                                color: Colors.black, fontSize: 13
                              )))),
                            SizedBox(height: 8),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(Global.USERDATA_URL+barangRekomendasi['barang'][index]['image'].toString(), width: width-40-40, height: 250,
                                    fit: BoxFit.cover)
                            ),
                            SizedBox(height: 8)
                          ]
                        );
                      }
                    )
                  ]
              )
          ))
        ]
    )));
  }
}
