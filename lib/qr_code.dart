import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(QRCode(null, null, null));
}

class QRCode extends StatefulWidget {
  final context, string, group;
  QRCode(this.context, this.string, this.group);

  @override
  QRCodeState createState() => QRCodeState();
}

class QRCodeState extends State<QRCode> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "qr_code";
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(children: [
      Container(width: width, height: 45, color: Global.SECONDARY_COLOR, child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 45, height: 45, child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20))
          )),
          Text(widget.string.text180, style: TextStyle(color: Colors.white, fontSize: 16)),
          Container(width: 45, height: 45)
        ]
      )),
      Expanded(
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Card(
                              elevation: 5,
                              clipBehavior: Clip.antiAlias,
                              shadowColor: Color(0xCC888888),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)
                              ),
                              child: Container(width: width-20-20, decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)
                              ), child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 50),
                                    Text(widget.group['title'].toString(), style: TextStyle(color: Colors.black, fontSize: 15)),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(widget.string.text161, style: TextStyle(color: Colors.black, fontSize: 13)),
                                          SizedBox(width: 10),
                                          Text(widget.group['unique_id'].toString(), style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold))
                                        ]
                                    ),
                                    SizedBox(height: 20),
                                    Image.network(Global.USERDATA_URL+widget.group['qr_image'].toString(),
                                      width: 200, height: 200),
                                    SizedBox(height: 40)
                                  ]
                              ))
                          )
                        ),
                        Align(alignment: Alignment.topCenter, child: Container(
                          width: 90, height: 90, child: Card(
                            elevation: 5,
                            clipBehavior: Clip.antiAlias,
                            shadowColor: Color(0xCC888888),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(45)
                            ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.network(Global.USERDATA_URL+widget.group['photo'].toString(),
                                  width: 90, height: 90, fit: BoxFit.cover)
                          )
                          )
                        ))
                      ]
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Text(widget.string.text183, style: TextStyle(color: Colors.black, fontSize: 15),
                          textAlign: TextAlign.center)
                    ),
                    SizedBox(height: 30)
                  ]
              ))
        )
      )
    ])));
  }
}
