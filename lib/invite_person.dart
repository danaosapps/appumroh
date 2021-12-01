import 'package:appumroh/qr_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';
import 'package:share/share.dart';

void main() {
  runApp(InvitePerson(null, null, null));
}

class InvitePerson extends StatefulWidget {
  final context, string, group;
  InvitePerson(this.context, this.string, this.group);

  @override
  InvitePersonState createState() => InvitePersonState();
}

class InvitePersonState extends State<InvitePerson> with WidgetsBindingObserver {
  var linkText = "http://dev.jtindonesia.com/invitation?user_id="+Global.USER_ID.toString();

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "invite_person";
    });
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: linkText));
    Global.show(widget.string.text191);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(
    children: [
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
          Text(widget.string.text165, style: TextStyle(color: Colors.white, fontSize: 16)),
          Container(width: 45, height: 45)
        ]
      )),
      Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                Text(widget.string.text177, style: TextStyle(color: Colors.black, fontSize: 13)),
                SizedBox(height: 10),
                Container(width: width-20-20, decoration: BoxDecoration(color: Global.MAIN_COLOR,
                    borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          copyToClipboard();
                        },
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                                  child: Center(child: Icon(Ionicons.link, color: Global.SECONDARY_COLOR, size: 25)
                                  )),
                              SizedBox(width: 10),
                              Expanded(child: Text(linkText,
                                  style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.start))
                            ]
                        )
                      )
                ))
              ]
            )
          ),
          Container(width: width, height: 1, color: Color(0x4f4c945c)),
          Material(
            child: new InkWell(
              onTap: () {
                copyToClipboard();
              },
              child: new Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Ionicons.copy, color: Color(0x7f777777), size: 20),
                        SizedBox(width: 10),
                        Text(widget.string.text178, style: TextStyle(color: Colors.black, fontSize: 13))
                      ]
                  )
              )
            ),
            color: Colors.transparent
          ),
          Container(width: width, height: 1, color: Color(0x4f4c945c)),
          Material(
              child: new InkWell(
                  onTap: () {
                    Share.share(widget.string.text181+" "+widget.group['title'].toString()+widget.string.text182);
                  },
                  child: new Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Ionicons.share_social, color: Color(0x7f777777), size: 20),
                            SizedBox(width: 10),
                            Text(widget.string.text179, style: TextStyle(color: Colors.black, fontSize: 13))
                          ]
                      )
                  )
              ),
              color: Colors.transparent
          ),
          Container(width: width, height: 1, color: Color(0x4f4c945c)),
          Material(
              child: new InkWell(
                  onTap: () {
                    Global.navigate(context, QRCode(context, widget.string, widget.group));
                  },
                  child: new Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Ionicons.qr_code, color: Color(0x7f777777), size: 20),
                            SizedBox(width: 10),
                            Text(widget.string.text180, style: TextStyle(color: Colors.black, fontSize: 13))
                          ]
                      )
                  )
              ),
              color: Colors.transparent
          ),
          Container(width: width, height: 1, color: Color(0x4f4c945c))
        ]
      )
    ])));
  }
}
