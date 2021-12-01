import 'dart:convert';
import 'package:appumroh/global.dart';
import 'package:appumroh/login/daftar_page.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

void main() {
  runApp(ForgotPassword(null, null));
}

class ForgotPassword extends StatefulWidget {
  final context, string;
  ForgotPassword(this.context, this.string);

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> with WidgetsBindingObserver {
  final TextEditingController emailController = TextEditingController(text: "appumroh123@gmail.com");
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "forgot_password";
    });
  }

  void sendResetPasswordEmail() async {
    var email = emailController.text.trim();
    if (email == "") {
      return;
    }
    var pd = await Global.showProgressDialog(context, widget.string.text157);
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/send_reset_password_email"),
      body: <String, String>{
        "email": email
      }, onSuccess: (response) async {
        await Global.hideProgressDialog(context);
        Global.alert(context, widget.string, widget.string.information, widget.string.text158);
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
                          widget.string.text155,
                          style: TextStyle(
                            fontSize: 23,
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
                      SizedBox(height: 20),
                      // *Tombol Masuk
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60),
                        child: ElevatedButton(
                            child: Text(widget.string.text156),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF2D4F2F),
                              onPrimary: Colors.white,
                              textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                sendResetPasswordEmail();
                              }
                            }
                        ),
                      ),
                      SizedBox(height: 35)
                    ],
                  ),
                )
              ],
            )
        )
    );
  }
}
