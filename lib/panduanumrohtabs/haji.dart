import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';

void main() {
  runApp(Haji(null, null));
}

class Haji extends StatefulWidget {
  final context, string;
  Haji(this.context, this.string);

  @override
  HajiState createState() => HajiState();
}

class HajiState extends State<Haji> with WidgetsBindingObserver {

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
          Card(
              elevation: 5,
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
                        elevation: 5,
                        margin: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 4),
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Color(0xCC888888),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Image.asset("assets/images/Haji.jpg", width: 200, height: 200, fit: BoxFit.cover)
                    ),
                    SizedBox(height: 5)
                  ]
              )
          ),
          SizedBox(height: 5),
          Card(
              elevation: 5,
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
                        elevation: 5,
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
          )
        ]
    );
  }
}
