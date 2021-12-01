import 'dart:convert';

import 'package:appumroh/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'global.dart';
import 'home.dart';
import 'test.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'dart:io' show Platform;
import 'package:device_info/device_info.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appName = 'App Umroh';
    return GetMaterialApp(
      title: appName,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('id', '')
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> firebaseInitialization = Firebase.initializeApp();

  Future<String> init(context, string) async {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      // FOR TEST ONLY
      /*DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      var deviceModel = androidInfo.model;
      print("DEVICE MODEL = "+deviceModel);
      if (deviceModel == "CPH1923") {
        //if (deviceModel == "SM-G965F") {
        Global.USER_ID = 2;
      } else {
        Global.USER_ID = 1;
      }*/
      //
      await Global.initUniLinks(context, string);
      Global.replaceScreen(context, Splash(context, string));
    });
    return "";
  }

  @override
  Widget build(BuildContext context) {
    var string = AppLocalizations.of(context)!;
    return FutureBuilder(
      future: firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Global.initFCM(context, string);
          return Scaffold(
              body: SafeArea(
                  child: FutureBuilder<String>(
                      future: init(context, string),
                      builder: (context, snapshot) {
                        return Container();
                      }
                  )
              )
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
