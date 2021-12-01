import 'dart:convert';
import 'package:appumroh/panduanumrohtabs/bacaan_talbiyah.dart';
import 'package:appumroh/panduanumrohtabs/niat_haji_umroh.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(DaftarBenda(null, null));
}

class DaftarBenda extends StatefulWidget {
  final context, string;
  DaftarBenda(this.context, this.string);

  @override
  DaftarBendaState createState() => DaftarBendaState();
}

class DaftarBendaState extends State<DaftarBenda> with WidgetsBindingObserver {
  var DaftarBenda = {};

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_perjalanan_haji"),
        onSuccess: (response) {
          var _DaftarBenda = jsonDecode(response);
          setState(() {
            DaftarBenda = _DaftarBenda;
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
                    Text(widget.string.text234, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(width: 45, height: 45)
                  ]
              )
          ),
          Expanded(child: SingleChildScrollView(
              child: Column(
                  children: [
                    SizedBox(height: 10),
                    Padding(padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(widget.string.text234, style: TextStyle(color: Colors.black, fontSize: 14))),
                    SizedBox(height: 10),
                    ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(Global.USERDATA_URL+DaftarBenda['image'].toString(), width: width-10-10, height: 400, fit: BoxFit.cover))
                  ]
              )
          ))
        ]
    )));
  }
}
