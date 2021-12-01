import 'package:appumroh/home.dart';
import 'package:appumroh/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'global.dart';
import 'dart:convert';
import 'package:appumroh/global.dart';
import 'package:appumroh/login/daftar_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() {
  runApp(ResetPassword(null, null, null));
}

class ResetPassword extends StatefulWidget {
  final context, string, userID;
  ResetPassword(this.context, this.string, this.userID);

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends State<ResetPassword> with WidgetsBindingObserver {
  final TextEditingController passwordController = TextEditingController(text: "HaloDunia123");
  final TextEditingController repeatPasswordController = TextEditingController(text: "HaloDunia123");
  final _formKey = GlobalKey<FormState>();
  var valIngatkan = '0';

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "reset_password";
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
      await Global.showProgressDialog(context, widget.string.text144);
      Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/sign_in_with_google"),
          body: <String, String>{
            "google_uid": account!.id,
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
            await Global.writeString("sign_in_date", Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss"));
            setState(() {
              Global.USER_INFO = obj;
              Global.USER_ID = int.parse(obj['id']);
            });
            await Global.hideProgressDialog(context);
            Navigator.pop(context, true);
          });
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

  void resetPassword() async {
    var password = passwordController.text;
    var repeatedPassword = repeatPasswordController.text;
    if (password == "" || repeatedPassword == "") {
      return;
    }
    if (password != repeatedPassword) {
      Global.alert(context, widget.string, widget.string.information, widget.string.text149);
      return;
    }
    await Global.showProgressDialog(context, widget.string.text148);
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/reset_password"),
      body: <String, String>{
        "id": widget.userID.toString(),
        "password": password
      }, onSuccess: (response) async {
        await Global.hideProgressDialog(context);
        await Global.writeString("sign_in_method", "");
        await Global.writeString("email", "");
        await Global.writeString("password", "");
        //Global.clearNavigationStack(context, Main());
        Get.off(Home(context, widget.string));
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
                        widget.string.text145,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D4F2F),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // *Email
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          child: Text(widget.string.password),
                        )
                    ),
                    TextFormField(
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
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
                            'assets/images/Icon Gembok.png',
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
                        child: Text(widget.string.text146),
                      ),
                    ),
                    TextFormField(
                      controller: repeatPasswordController,
                      obscureText: true,
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
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return widget.string.text125;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // *Tombol Masuk
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 70),
                      child: ElevatedButton(
                          child: Text(widget.string.text145),
                          style: ElevatedButton.styleFrom(
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
                            if (_formKey.currentState!.validate()) {
                              resetPassword();
                            }
                          }
                      ),
                    ),
                    SizedBox(height: 35)
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
