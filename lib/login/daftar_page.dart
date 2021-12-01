// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, must_be_immutable, use_key_in_widget_constructors

import 'dart:convert';

import 'package:appumroh/global.dart';
import 'package:appumroh/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jiffy/jiffy.dart';

class DaftarPage extends StatefulWidget {
  final context, string;
  DaftarPage(this.context, this.string);

  @override
  DaftarPageState createState() => DaftarPageState();
}

class DaftarPageState extends State<DaftarPage> {
  // const DaftarPage({Key? key}) : super(key: key);
  final TextEditingController namaController = TextEditingController(text: "App Umroh 123");
  final TextEditingController emailController = TextEditingController(text: "appumroh123@gmail.com");
  final TextEditingController passwordController = TextEditingController(text: "HaloDunia123");
  final TextEditingController konfirmasiPasswordController = TextEditingController(text: "HaloDunia123");
  final _formKey = GlobalKey<FormState>();
  var valSyarat = '0';
  var acceptTOSShown = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "signup";
    });
  }

  void loginWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    setState(() {
      Global.GOOGLE_SIGN_IN_INSTANCE = googleSignIn;
    });
    try {
      var account = await googleSignIn.signIn();
      print(account);
      if (account != null) {
        await Global.showProgressDialog(context, widget.string.text144);
        Global.httpPost(widget.string,
            Uri.parse(Global.API_URL + "/user/sign_in_with_google"),
            body: <String, String>{
              "google_uid": account.id,
              "name": account.displayName!,
              "photo": account.photoUrl!,
              "email": account.email
            }, onSuccess: (response) async {
              print("sign_in_with_google response:");
              print(response);
              var obj = jsonDecode(response);
              var tempPassword = obj['temp_password'].toString();
              await Global.writeString("sign_in_method", "google");
              await Global.writeString("email", account.email);
              await Global.writeString("password", tempPassword);
              await Global.writeString("sign_in_date",
                  Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss"));
              setState(() {
                Global.USER_INFO = obj;
                Global.USER_ID = int.parse(obj['id']);
              });
              await Global.hideProgressDialog(context);
              Navigator.pop(context, true);
            });
      }
    } catch (error) {
      print(error);
    }
  }

  void loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email']
    );
    print("LOGIN RESULT:");
    print(result.status);
    print(result.message);
    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken!;
      print("ACCESS TOKEN:");
      print(accessToken.token);
      final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)"
      );
      print("FACEBOOK USER DATA:");
      print(userData);
      await Global.showProgressDialog(context, widget.string.text144);
      Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/sign_in_with_facebook"),
          body: <String, String>{
            "facebook_uid": userData['id'].toString(),
            "name": userData['name'].toString(),
            "photo": userData['picture']['data']['url'].toString(),
            "email": userData['email'].toString()
          }, onSuccess: (response) async {
            print("sign_in_with_facebook response:");
            print(response);
            var obj = jsonDecode(response);
            var tempPassword = obj['temp_password'].toString();
            await Global.writeString("sign_in_method", "facebook");
            await Global.writeString("facebook_uid", userData['id'].toString());
            await Global.writeString("password", tempPassword);
            await Global.writeString("sign_in_date", Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss"));
            setState(() {
              Global.USER_INFO = obj;
              Global.USER_ID = int.parse(obj['id']);
            });
            await Global.hideProgressDialog(context);
            Navigator.pop(context, true);
          });
    } else {
      print(result.status);
      print(result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFF549558),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
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
            Image.asset(
              'assets/images/Doted.png',
              fit: BoxFit.cover,
              height: 400,
            ),
            Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(25, 260, 25, 50),
                children: [
                  Center(
                    child: Text(
                      widget.string.signup,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D4F2F),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // *Nama
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      child: Text(widget.string.name),
                    ),
                  ),
                  TextFormField(
                    controller: namaController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.withOpacity(0.3),
                      filled: true,
                      hintText: widget.string.text128,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/Icon Nama.png',
                          height: 5,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.string.text129;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  // *Email
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      child: Text(widget.string.email),
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.withOpacity(0.3),
                      filled: true,
                      hintText: widget.string.text122,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/Icon Email.png',
                          height: 5,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.string.text123;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  // *Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      child: Text(widget.string.password),
                    ),
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.withOpacity(0.3),
                      filled: true,
                      hintText: widget.string.text124,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/Icon Gembok.png',
                          height: 5,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.string.text125;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  // *Konfirmasi Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                      child: Text(widget.string.text130),
                    ),
                  ),
                  TextFormField(
                    controller: konfirmasiPasswordController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.withOpacity(0.3),
                      filled: true,
                      hintText: widget.string.text131,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/Icon Gembok.png',
                          height: 5,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return widget.string.text132;
                      } else if (value != passwordController.text) {
                        return widget.string.text133;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // *Syarat Dan Ketentuan
                  Row(
                    children: [
                      Container(
                        width: 30, height: 30, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              if (valSyarat == '0') {
                                valSyarat = '1';
                              } else {
                                valSyarat = '0';
                              }
                              if (valSyarat == '1') {
                                acceptTOSShown = false;
                              }
                            });
                          },
                          child: Center(
                            child: Container(width: 20, height: 20, decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 2, color: Global.SECONDARY_COLOR)
                            ), child: Center(
                                child: (() {
                                  if (valSyarat == '1') {
                                    return Container(width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                            color: Global.SECONDARY_COLOR,
                                            borderRadius: BorderRadius.circular(10)
                                        ));
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                }())
                            ))
                          )
                        )
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            valSyarat == '1' ? valSyarat = '0' : valSyarat = '1';
                            if (valSyarat == '1') {
                              acceptTOSShown = false;
                            }
                          });
                          print(valSyarat);
                        },
                        child: SizedBox(
                          width: 285,
                          child: RichText(
                              text: TextSpan(
                                  text: widget.string.text134+" ",
                                  style: TextStyle(color: Color(0xFF2D4F2F)),
                                  children: [
                                TextSpan(
                                  text: widget.string.text135+' ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: widget.string.text136+' '),
                                TextSpan(
                                  text: widget.string.text137+' ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: widget.string.text138)
                              ])),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  (() {
                    if (acceptTOSShown) {
                      return Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Text(widget.string.text139, style: TextStyle(color: Color(0xffc0392b), fontSize: 12)));
                    } else {
                      return SizedBox.shrink();
                    }
                  }()),
                  SizedBox(height: 15),
                  // *Tombol Daftar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100),
                    child: ElevatedButton(
                      child: Text(widget.string.signup),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF2D4F2F),
                        onPrimary: Colors.white,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var name = namaController.text.trim();
                          var email = emailController.text.trim();
                          var password = passwordController.text;
                          var konfirmasiPassword = konfirmasiPasswordController.text;
                          if (valSyarat == '0') {
                            Global.alert(context, widget.string, widget.string.information, widget.string.text154);
                            return;
                          }
                          setState(() {
                            if (valSyarat == '0') {
                              acceptTOSShown = true;
                            } else {
                              acceptTOSShown = false;
                            }
                          });
                          if (name == "" || email == "" || password.trim() == "" || konfirmasiPassword.trim() == "") {
                            Global.show(widget.string.text140);
                            return;
                          }
                          await Global.showProgressDialog(context, widget.string.text141);
                          Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/signup"),
                            body: <String, String>{
                              "name": name,
                              "email": email,
                              "password": password,
                              "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
                            }, onSuccess: (response) async {
                              print("SIGNUP RESPONSE:");
                              print(response);
                              await Global.hideProgressDialog(context);
                              var obj = jsonDecode(response);
                              var responseCode = int.parse(obj['response_code'].toString());
                              if (responseCode == 1) {
                                Global.alert(context, widget.string, widget.string.information, widget.string.text142);
                              } else if (responseCode == -1) {
                                Global.alert(context, widget.string, widget.string.information, widget.string.text143);
                              }
                            });
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 35),
                  SizedBox(
                    child: Stack(
                      children: [
                        Divider(
                          thickness: 2,
                          indent: 50,
                          endIndent: 50,
                        ),
                        Center(
                          child: Container(
                            color: Colors.transparent,
                            child: Text(
                              " "+widget.string.or+" ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2D4F2F),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),

                  // *Tombol Masuk
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100),
                    child: ElevatedButton(
                      child: Text(widget.string.login),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF93C993),
                        onPrimary: Color(0xFF2D4F2F),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: BorderSide(color: Colors.black38),
                        ),
                      ),
                      onPressed: () {
                        Global.replaceScreen(context, LoginPage(context, widget.string));
                      }
                    ),
                  ),
                  SizedBox(height: 20),
                  // *Tombol Google
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Stack(
                      children: [
                        ElevatedButton(
                          child: Padding(
                            padding: EdgeInsets.only(left: 40),
                            child: Text('Google'),
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(150, 10),
                            primary: Color(0xFF2D4F2F),
                            onPrimary: Colors.white,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () {
                            loginWithGoogle();
                          },
                        ),
                        Image.asset(
                          'assets/images/Logo Google.png',
                          // fit: BoxFit.cover,
                          height: 45,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),

                  // *Tombol Facebook
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 70),
                    child: Stack(
                      children: [
                        ElevatedButton(
                          child: Padding(
                            padding: EdgeInsets.only(left: 40),
                            child: Text('facebook'),
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(150, 10),
                            primary: Color(0xFF2D4F2F),
                            onPrimary: Colors.white,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () {
                            loginWithFacebook();
                          }
                        ),
                        Image.asset(
                          'assets/images/Logo Facebook.png',
                          // fit: BoxFit.cover,
                          height: 45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
