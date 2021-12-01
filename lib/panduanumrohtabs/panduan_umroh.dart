import 'dart:convert';
import 'package:appumroh/bottom_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:appumroh/global.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(PanduanUmroh(null, null));
}

class PanduanUmroh extends StatefulWidget {
  final context, string;
  PanduanUmroh(this.context, this.string);

  @override
  PanduanUmrohState createState() => PanduanUmrohState();
}

class PanduanUmrohState extends State<PanduanUmroh> with WidgetsBindingObserver {
  var duas = [];
  var videoPath = "";
  VideoPlayerController? videoController = null;
  bool audioPlaying = false;
  bool videoPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  var currentAudioIndex = -1;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_panduan_umroh"),
        onSuccess: (response) {
          var obj = jsonDecode(response);
          var _duas = obj['panduan'];
          setState(() {
            videoPath = obj['video_path'].toString();
            for (var dua in _duas) {
              dua['playing'] = false;
            }
            duas = _duas;
            videoController = VideoPlayerController.network(
                Global.USERDATA_URL+videoPath)
              ..initialize().then((_) {
                setState(() {});
              });
          });
        });
  }

  void goBack(context) {
    if (videoController != null) {
      videoController!.dispose();
    }
    if (audioPlaying) {
      audioPlayer.stop();
    }
    audioPlayer.dispose();
    Get.back();
  }

  Future<bool> onWillPop() async {
    goBack(widget.context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(body: SafeArea(child: Column(
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
                              goBack(context);
                            },
                            child: Center(
                                child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                            )
                        )),
                        Text(widget.string.text54, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        Container(width: 45, height: 45)
                      ]
                  )
              ),
              Expanded(
                  child: Stack(
                      children: [
                        SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 10),
                                  Text(widget.string.text220, style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  (() {
                                    if (videoController == null || !videoController!.value.isInitialized) {
                                      return SizedBox.shrink();
                                    } else {
                                      return Padding(
                                          padding: EdgeInsets.only(left: 10, right: 10),
                                          child: Container(
                                              width: width-10-10,
                                              height: 200,
                                              child: Stack(
                                                  children: [
                                                    AspectRatio(
                                                      aspectRatio: videoController!.value.aspectRatio,
                                                      child: VideoPlayer(videoController!),
                                                    ),
                                                    Container(
                                                        width: width-10-10,
                                                        height: 200,
                                                        color: videoPlaying?Colors.transparent:Color(0x7f000000),
                                                        child: Center(
                                                            child: Container(
                                                                width: width-10-10, height: 200,
                                                                child: GestureDetector(
                                                                    behavior: HitTestBehavior.translucent,
                                                                    onTap: () {
                                                                      if (videoController != null) {
                                                                        setState(() {
                                                                          videoPlaying = !videoPlaying;
                                                                        });
                                                                        if (videoPlaying) {
                                                                          videoController!.play();
                                                                        } else {
                                                                          videoController!.pause();
                                                                        }
                                                                      }
                                                                    },
                                                                    child: Center(
                                                                        child: Container(
                                                                            width: 50, height: 50,
                                                                            decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(25),
                                                                                border: Border.all(width: 5, color: videoPlaying?Colors.transparent:Colors.white)
                                                                            ),
                                                                            child: Center(child: videoPlaying?SizedBox.shrink():Icon(Ionicons.play, color: Colors.white, size: 30))
                                                                        )
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                  ]
                                              )
                                          ));
                                    }
                                  }()),
                                  SizedBox(height: 5),
                                  ListView.builder(
                                      primary: false,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.only(bottom: 50),
                                      itemCount: duas.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                                            child: Column(
                                                children: [
                                                  Container(width: width-8-8, height: 30, color: Global.SECONDARY_COLOR,
                                                      padding: EdgeInsets.only(left: 8, right: 8, top: 6),
                                                      child: Text(duas[index]['title'].toString(), style: TextStyle(
                                                          color: Colors.white, fontSize: 13
                                                      ))),
                                                  SizedBox(height: 4),
                                                  Text(duas[index]['description'].toString(), style: TextStyle(
                                                      color: Colors.black, fontSize: 10
                                                  )),
                                                  SizedBox(height: 4),
                                                  Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(width: 40, height: 40, child: GestureDetector(
                                                            behavior: HitTestBehavior.translucent,
                                                            onTap: () {
                                                              if (audioPlaying) {
                                                                audioPlayer.seek(Duration.zero);
                                                              }
                                                              setState(() {
                                                                audioPlaying = true;
                                                              });
                                                            },
                                                            child: Center(
                                                                child: Icon(Ionicons.play_skip_back, color: Color(0x7f4c945c), size: 24)
                                                            )
                                                        )),
                                                        Container(width: 45, height: 45, child: GestureDetector(
                                                            behavior: HitTestBehavior.translucent,
                                                            onTap: () async {
                                                              if (currentAudioIndex != index) {
                                                                setState(() {
                                                                  for (var dua in duas) {
                                                                    dua['playing'] = false;
                                                                  }
                                                                });
                                                                audioPlayer.stop();
                                                                audioPlayer.play(Global.USERDATA_URL+duas[index]['audio_path'].toString());
                                                              } else if (currentAudioIndex == index) {
                                                                if (duas[index]['playing']) {
                                                                  audioPlayer.pause();
                                                                } else {
                                                                  audioPlayer.resume();
                                                                }
                                                              }
                                                              setState(() {
                                                                audioPlaying = true;
                                                                currentAudioIndex = index;
                                                                duas[index]['playing'] = !duas[index]['playing'];
                                                              });
                                                            },
                                                            child: Center(
                                                                child: Icon(duas[index]['playing']?Ionicons.pause:Ionicons.play, color: Global.SECONDARY_COLOR, size: 24)
                                                            )
                                                        )),
                                                        Container(width: 40, height: 40, child: GestureDetector(
                                                            behavior: HitTestBehavior.translucent,
                                                            onTap: () {
                                                              if (audioPlaying) {
                                                                audioPlayer.stop();
                                                              }
                                                              audioPlayer.play(Global.USERDATA_URL+duas[index]['audio_path'].toString());
                                                              setState(() {
                                                                audioPlaying = true;
                                                              });
                                                            },
                                                            child: Center(
                                                                child: Icon(Ionicons.play_skip_forward, color: Color(0x7f4c945c), size: 24)
                                                            )
                                                        ))
                                                      ]
                                                  )
                                                ]
                                            )
                                        );
                                        return SizedBox.shrink();
                                      }
                                  )
                                ]
                            )
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Card(
                                elevation: 50,
                                margin: EdgeInsets.zero,
                                clipBehavior: Clip.antiAlias,
                                shadowColor: Color(0xCC888888),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0)
                                ),
                                child: BottomBar(context, widget.string, 0, "home")
                            )
                        )
                      ]
                  )
              )
            ]
        )))
    );
  }
}
