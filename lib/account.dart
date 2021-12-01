import 'package:appumroh/biography.dart';
import 'package:appumroh/home.dart';
import 'package:appumroh/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(Account(null, null));
}

class Account extends StatefulWidget {
  final context, string;
  Account(this.context, this.string);

  @override
  AccountState createState() => AccountState();
}

class AccountState extends State<Account> with WidgetsBindingObserver {
  var accountController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "account";
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(
      children: [
        Container(width: width, height: 45, color: Global.SECONDARY_COLOR, child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 45, height: 45, child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20))
            )),
            Text(widget.string.text100, style: TextStyle(
              color: Colors.white, fontSize: 17
            )),
            Container(width: 45, height: 45)
          ]
        )),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Global.USER_INFO['name'].toString(), style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(Global.USER_INFO['email'].toString(), style: TextStyle(color: Colors.black, fontSize: 14)),
                Text(Global.USER_INFO['phone'].toString(), style: TextStyle(color: Colors.black, fontSize: 14)),
                Text(widget.string.text101, style: TextStyle(color: Colors.black, fontSize: 14)),
              ]
            ),
            (() {
              var photo = Global.USER_INFO['photo'];
              if (photo == null
                  || photo.toString().trim() == "null"
                  || photo.toString().trim() == "") {
                return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(Global.USERDATA_URL+Global.USER_INFO['photo'].toString(), width: 140, height: 140,
                        fit: BoxFit.cover)
                );
              } else {
                return SizedBox.shrink();
              }
            }())
          ]
        )),
        Container(width: width, height: 1, color: Global.MAIN_COLOR),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.string.text102, style: TextStyle(color: Colors.black, fontSize: 16)),
              SizedBox(height: 8),
              Container(width: width-10-10, height: 45, decoration: BoxDecoration(color: Color(0x7f888888), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    (() {
                      if (Global.ACCOUNT_LOGIN_TYPE == "email") {
                        return Icon(Ionicons.mail_outline, color: Color(0xff888888), size: 25);
                      } else if (Global.ACCOUNT_LOGIN_TYPE == "google") {
                        return Icon(Ionicons.logo_google, color: Color(0xff888888), size: 25);
                      } else {
                        return Icon(Ionicons.logo_facebook, color: Color(0xff888888), size: 25);
                      }
                    }()),
                    SizedBox(width: 8),
                    Text(Global.USER_INFO['email'].toString(), style: TextStyle(color: Colors.black, fontSize: 25))
                  ]
                )),
              SizedBox(height: 10),
              Container(width: width-10-10, height: 45, decoration: BoxDecoration(color: Global.SECONDARY_COLOR,
                borderRadius: BorderRadius.circular(10)), child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Global.navigate(context, Biography(context, widget.string));
                },
                child: Center(child: Text(widget.string.text103, style: TextStyle(color: Colors.white, fontSize: 16)))
              )),
              SizedBox(height: 7),
              Container(width: width-10-10, height: 45, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)), child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Global.confirm(context, widget.string, widget.string.confirmation, widget.string.text105,
                        () async {
                          setState(() {
                            Global.USER_ID = 0;
                            Global.USER_INFO = {};
                          });
                          if (Global.GOOGLE_SIGN_IN_INSTANCE != null) {
                            await Global.GOOGLE_SIGN_IN_INSTANCE.signOut();
                            setState(() {
                              Global.GOOGLE_SIGN_IN_INSTANCE = null;
                            });
                          }
                          Global.writeString("sign_in_method", "");
                          Global.writeString("email", "");
                          Global.writeString("password", "");
                          Navigator.pop(context, "logout");
                        }, () {});
                  },
                  child: Center(child: Text(widget.string.text104, style: TextStyle(color: Global.SECONDARY_COLOR, fontSize: 16)))
              ))
            ]
          )
        )
      ]
    )));
  }
}
