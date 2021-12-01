import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';

void main() {
  runApp(Umroh(null, null));
}

class Umroh extends StatefulWidget {
  final context, string;
  Umroh(this.context, this.string);

  @override
  UmrohState createState() => UmrohState();
}

class UmrohState extends State<Umroh> with WidgetsBindingObserver {

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
              child: Column(
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
              child: Column(
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
              )
          ))
        ]
    );
  }
}
