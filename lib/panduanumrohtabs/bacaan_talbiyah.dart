import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(BacaanTalbiyah(null, null));
}

class BacaanTalbiyah extends StatefulWidget {
  final context, string;
  BacaanTalbiyah(this.context, this.string);

  @override
  BacaanTalbiyahState createState() => BacaanTalbiyahState();
}

class BacaanTalbiyahState extends State<BacaanTalbiyah> with WidgetsBindingObserver {
  AudioPlayer player = AudioPlayer();
  bool playing = false;
  bool audioLoaded = false;
  bool loading = true;
  var bacaanTalbiyah = {};

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_bacaan_talbiyah"),
        onSuccess: (response) {
          setState(() {
            bacaanTalbiyah = jsonDecode(response);
            loading = false;
          });
        });
  }

  bool isPlaying() {
    return playing;
  }

  void playAudio() async {
    if (playing) {
      await player.pause();
      setState(() {
        playing = false;
      });
    } else {
      if (audioLoaded) {
        await player.resume();
        setState(() {
          playing = true;
        });
      } else {
        await player.play(Global.USERDATA_URL+bacaanTalbiyah['audio_path'].toString());
        setState(() {
          playing = true;
          audioLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(
        children: [
          Container(
              width: width,
              height: 45,
              color: Global.SECONDARY_COLOR,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 45, height: 45, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Get.back();
                        },
                        child: Center(
                            child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                        )
                    )),
                    Text(widget.string.text224, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Container(width: 45, height: 45)
                  ]
              )
          ),
          Expanded(child: SingleChildScrollView(
              child: Column(
                  children: [
                    SizedBox(height: 10),
                    Padding(padding: EdgeInsets.only(left: 10, right: 10),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20), child: Image.network(Global.USERDATA_URL+bacaanTalbiyah['image'].toString(), width: width-10-10, height: 150, fit: BoxFit.cover))),
                    SizedBox(height: 2),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 45, height: 45, child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                playAudio();
                              },
                              child: Center(
                                  child: Icon(playing?Ionicons.pause:Ionicons.play, color: Global.SECONDARY_COLOR, size: 24)
                              )
                          ))
                        ]
                    ),
                    SizedBox(height: 10)
                  ]
              )
          ))
        ]
    )));
  }
}
