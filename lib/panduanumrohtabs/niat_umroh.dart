import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

void main() {
  runApp(NiatUmroh(null, null));
}

class NiatUmroh extends StatefulWidget {
  final context, string;
  NiatUmroh(this.context, this.string);

  @override
  NiatUmrohState createState() => NiatUmrohState();
}

class NiatUmrohState extends State<NiatUmroh> with WidgetsBindingObserver {
  var petunjukIhramsMale = [];
  var petunjukIhramsFemale = [];
  var currentGender = "male";
  var currentIndex = 0;
  AudioPlayer player = AudioPlayer();
  bool playing = false;
  bool audioLoaded = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_petunjuk_ihram"),
        body: <String, String>{
          "type": "umroh"
        },
        onSuccess: (response) {
          setState(() {
            petunjukIhramsMale = jsonDecode(response);
            petunjukIhramsFemale = jsonDecode(response);
            loading = false;
          });
        });
  }

  void playPrevAudio() async {
    await player.stop();
    setState(() {
      playing = false;
      if (currentGender == "male") {
        if (currentIndex > 0) {
          currentIndex--;
        } else {
          currentIndex = petunjukIhramsMale.length-1;
          currentGender = "female";
        }
      } else if (currentGender == "female") {
        if (currentIndex > 0) {
          currentIndex--;
        } else {
          currentIndex = petunjukIhramsFemale.length-1;
          currentGender = "male";
        }
      }
      audioLoaded = false;
    });
    playAudio();
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
        var petunjukIhrams = petunjukIhramsMale;
        if (currentGender == "female") {
          petunjukIhrams = petunjukIhramsFemale;
        }
        await player.play(Global.USERDATA_URL +
            petunjukIhrams[currentIndex]['audio_path'].toString());
        setState(() {
          playing = true;
          audioLoaded = true;
        });
      }
    }
  }

  void playNextAudio() async {
    await player.stop();
    setState(() {
      playing = false;
      if (currentGender == "male") {
        if (currentIndex < petunjukIhramsMale.length-1) {
          currentIndex++;
        } else {
          currentIndex = 0;
          currentGender = "female";
        }
      } else if (currentGender == "female") {
        if (currentIndex < petunjukIhramsFemale.length-1) {
          currentIndex++;
        } else {
          currentIndex = 0;
          currentGender = "male";
        }
      }
      audioLoaded = false;
    });
    playAudio();
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
                    Text(widget.string.text230, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
                            borderRadius: BorderRadius.circular(20), child: Image.asset("assets/images/haji.jpg", width: width-10-10, height: 150, fit: BoxFit.cover))),
                    SizedBox(height: 2),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 40, height: 40, child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                playPrevAudio();
                              },
                              child: Center(
                                  child: Icon(Ionicons.play_skip_back, color: Color(0x7f4c945c), size: 24)
                              )
                          )),
                          Container(width: 45, height: 45, child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                playAudio();
                              },
                              child: Center(
                                  child: Icon(playing?Ionicons.pause:Ionicons.play, color: Global.SECONDARY_COLOR, size: 24)
                              )
                          )),
                          Container(width: 40, height: 40, child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                playNextAudio();
                              },
                              child: Center(
                                  child: Icon(Ionicons.play_skip_forward, color: Color(0x7f4c945c), size: 24)
                              )
                          ))
                        ]
                    ),
                    SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 28, right: 10),
                        child: Text(widget.string.text231, style: TextStyle(color: Colors.black, fontSize: 17)))),
                    SizedBox(height: 5),
                    Padding(padding: EdgeInsets.only(left: 10, right: 10),
                        child: (() {
                          if (loading) {
                            return Container(width: width-10-10, height: 200, child: Center(child: CircularProgressIndicator()));
                          } else {
                            return ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: petunjukIhramsMale.length,
                                itemBuilder: (context, index) {
                                  return Padding(padding: EdgeInsets.only(top: 5, bottom: 5),
                                      child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text((index+1).toString()+".", style: TextStyle(
                                                color: Colors.black, fontSize: 12
                                            )),
                                            SizedBox(width: 5),
                                            Expanded(child: Text(petunjukIhramsMale[index]['petunjuk'].toString(), style: TextStyle(
                                                color: Colors.black, fontSize: 12
                                            )))
                                          ]
                                      ));
                                }
                            );
                          }
                        }())),
                    SizedBox(height: 10),
                    Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 28, right: 10),
                        child: Text(widget.string.text232, style: TextStyle(color: Colors.black, fontSize: 17)))),
                    SizedBox(height: 5),
                    Padding(padding: EdgeInsets.only(left: 10, right: 10),
                        child: (() {
                          if (loading) {
                            return Container(width: width-10-10, height: 200, child: Center(child: CircularProgressIndicator()));
                          } else {
                            return ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: petunjukIhramsFemale.length,
                                itemBuilder: (context, index) {
                                  return Padding(padding: EdgeInsets.only(top: 5, bottom: 5),
                                      child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text((index+1).toString()+".", style: TextStyle(
                                                color: Colors.black, fontSize: 12
                                            )),
                                            SizedBox(width: 5),
                                            Expanded(child: Text(petunjukIhramsFemale[index]['petunjuk'].toString(), style: TextStyle(
                                                color: Colors.black, fontSize: 12
                                            )))
                                          ]
                                      ));
                                }
                            );
                          }
                        }()))
                  ]
              )
          ))
        ]
    )));
  }
}
