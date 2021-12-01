import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'global.dart';

void main() {
  runApp(VerifyEmail(null, null, null, null));
}

class VerifyEmail extends StatefulWidget {
  final context, string, email, token;
  VerifyEmail(this.context, this.string, this.email, this.token);

  @override
  VerifyEmailState createState() => VerifyEmailState();
}

class VerifyEmailState extends State<VerifyEmail> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "verify_email";
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      print("VERIFYING");
      print("Email: "+widget.email);
      print("Token: "+widget.token);
      Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/verify_email"),
          body: <String, String>{
            "email": widget.email,
            "token": widget.token
          }, onSuccess: (response) async {
            print("verify_email response:");
            print(response);
            var obj = jsonDecode(response);
            var responseCode = int.parse(obj['response_code'].toString());
            if (responseCode == 1) {
              Global.alertConfirm(context, widget.string, widget.string.information, widget.string.text151,
                  () {
                    Get.back();
                  });
            } else if (responseCode == -1) {
              Global.alert(context, widget.string, widget.string.information, widget.string.text152);
            } else if (responseCode == -2) {
              Global.alert(context, widget.string, widget.string.information, widget.string.text152);
            } else if (responseCode == -3) {
              Global.alert(context, widget.string, widget.string.information, widget.string.text153);
            }
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Stack(
              children: [
                Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Color(0xFF549558),
                        ],
                      ),
                    )
                ),
                Image.asset(
                  'assets/images/Doted.png',
                  fit: BoxFit.cover,
                  height: 400,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.only(top: 65),
                    child: Image.asset(
                      'assets/images/Logo Bulan.png',
                      fit: BoxFit.cover,
                      height: 160,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(widget.string.text150, style: TextStyle(color: Colors.white, fontSize: 18)),
                          SizedBox(height: 32),
                          CircularProgressIndicator(color: Colors.white)
                        ]
                    )
                  )
                )
              ],
            )
        )
    );
  }
}
