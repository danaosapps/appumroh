import 'dart:convert';

import 'package:appumroh/home.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'global.dart';

void main() {
  runApp(Splash(null, null));
}

class Splash extends StatefulWidget {
  final context, string;
  Splash(this.context, this.string);

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> with WidgetsBindingObserver {
  var progressShown = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void init() async {
    setState(() {
      progressShown = true;
    });
    await Future.delayed(Duration(seconds: 0));
    setState(() {
      progressShown = false;
    });
    Global.replaceScreen(context, Home(context, widget.string));
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "splash";
    });
    //await Global.writeString("sign_in_method", "");
    print("Getting themes...");
    print(Global.API_URL+"/user/get_themes");
    Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_themes"),
        onSuccess: (response) async {
          print("get_themes response:");
          print(response);
          var themes = jsonDecode(response);
          print("ALL THEMES:");
          print(themes);
          var themeID = await Global.readInt("current_theme_id", 1);
          print("CURRENT THEME ID:");
          print(themeID);
          for (var theme in themes) {
            if (int.parse(theme['id']) == themeID) {
              setState(() {
                Global.CURRENT_THEME = theme;
              });
              break;
            }
          }
          var signInMethod = await Global.readString("sign_in_method", "");
          print("SIGN IN METHOD:");
          print(signInMethod);
          var password = await Global.readString("password", "");
          if (signInMethod == "email") {
            var email = await Global.readString("email", "");
            var rememberMe = (await Global.readString("remember_me", "")).trim();
            var signInDate = (await Global.readString("sign_in_date", "")).trim();
            print("SIGN IN DATE:");
            print(signInDate);
            var diff = Jiffy(DateTime.now()).diff(Jiffy(signInDate, "yyyy-MM-dd HH:mm:ss"), Units.DAY);
            if (diff < 0) {
              diff = -diff;
            }
            print("SIGN IN DATE DIFFERENCE:");
            print(diff);
            print("REMEMBER ME?:");
            print(rememberMe);
            if (rememberMe == "0") {
              if (diff < 15) {
                Global.httpPost(
                    widget.string, Uri.parse(Global.API_URL + "/user/login"),
                    body: <String, String>{
                      "email": email,
                      "password": password
                    }, onSuccess: (response) {
                  setState(() {
                    Global.USER_INFO = jsonDecode(response);
                    Global.USER_ID = int.parse(Global.USER_INFO['id'].toString());
                  });
                  init();
                });
              } else {
                init();
              }
            } else if (rememberMe == "1") {
              if (diff < 30) {
                Global.httpPost(
                    widget.string, Uri.parse(Global.API_URL + "/user/login"),
                    body: <String, String>{
                      "email": email,
                      "password": password
                    }, onSuccess: (response) {
                  setState(() {
                    Global.USER_INFO = jsonDecode(response);
                    Global.USER_ID = int.parse(Global.USER_INFO['id'].toString());
                  });
                  init();
                });
              } else {
                init();
              }
            }
          } else if (signInMethod == "google") {
            var email = await Global.readString("email", "");
            Global.httpPost(
                widget.string, Uri.parse(Global.API_URL + "/user/login_with_google_temp_password"),
                body: <String, String>{
                  "email": email,
                  "password": password
                }, onSuccess: (response) {
              print("login_with_google_temp_password response:");
              print(response);
              var obj = jsonDecode(response);
              var responseCode = int.parse(obj['response_code'].toString());
              if (responseCode == 1) {
                setState(() {
                  Global.USER_INFO = jsonDecode(response);
                  Global.USER_ID = int.parse(Global.USER_INFO['id'].toString());
                });
              }
              init();
            });
          } else if (signInMethod == "facebook") {
            var facebookUID = await Global.readString("facebook_uid", "");
            print("FACEBOOK UID:");
            print(facebookUID);
            print("PASSWORD:");
            print(password);
            Global.httpPost(
                widget.string, Uri.parse(Global.API_URL + "/user/login_with_facebook_temp_password"),
                body: <String, String>{
                  "facebook_uid": facebookUID,
                  "password": password
                }, onSuccess: (response) {
              print("login_with_facebook_temp_password response:");
              print(response);
              setState(() {
                Global.USER_INFO = jsonDecode(response);
                Global.USER_ID = int.parse(Global.USER_INFO['id'].toString());
              });
              init();
            });
          } else {
            init();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white,
            Color(0xff4c945c)
          ]
        )
      ),
      child: Stack(
        children: [
          Center(
            child: Image.asset("assets/images/sprinkles.png", width: width, height: 300)
          ),
          Center(
            child: Image.asset("assets/images/moon.png", width: width, height: 200)
          ),
          (() {
            if (progressShown) {
              return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 50),
                      child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(color: Colors.white)
                      )
                  )
              );
            } else {
              return SizedBox.shrink();
            }
          }())
        ]
      )
    )));
  }
}
