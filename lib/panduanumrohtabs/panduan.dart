import 'package:appumroh/panduanumrohtabs/panduan_haji.dart';
import 'package:appumroh/panduanumrohtabs/panduan_umroh.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';

void main() {
  runApp(Panduan(null, null));
}

class Panduan extends StatefulWidget {
  final context, string;
  Panduan(this.context, this.string);

  @override
  PanduanState createState() => PanduanState();
}

class PanduanState extends State<Panduan> with WidgetsBindingObserver {

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
    return Column(
        children: [
          Container(width: width-5-5, child: Card(
              elevation: 3,
              margin: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 4),
              clipBehavior: Clip.antiAlias,
              shadowColor: Color(0xCC888888),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Material(
                  child: new InkWell(
                      onTap: () {
                        Global.navigate(context, PanduanUmroh(context, widget.string));
                      }, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 5),
                        Text(widget.string.text218, style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Card(
                            elevation: 0,
                            margin: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 4),
                            clipBehavior: Clip.antiAlias,
                            shadowColor: Color(0xCC888888),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Image.asset("assets/images/umroh.jpg", width: 200, height: 200, fit: BoxFit.cover)
                        ),
                        SizedBox(height: 5)
                      ]
                  ))
              )
          )),
          SizedBox(height: 5),
          Container(width: width-5-5, child: Card(
              elevation: 3,
              margin: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 4),
              clipBehavior: Clip.antiAlias,
              shadowColor: Color(0xCC888888),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Material(
                  child: new InkWell(
                      onTap: () {
                        Global.navigate(context, PanduanHaji(context, widget.string));
                      }, child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 5),
                        Text(widget.string.text219, style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Card(
                            elevation: 0,
                            margin: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 4),
                            clipBehavior: Clip.antiAlias,
                            shadowColor: Color(0xCC888888),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Image.asset("assets/images/haji.jpg", width: 200, height: 200, fit: BoxFit.cover)
                        ),
                        SizedBox(height: 5)
                      ]
                  ))
              )
          ))
        ]
    );
  }
}
