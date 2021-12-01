import 'dart:convert';
import 'package:appumroh/bottom_bar.dart';
import 'package:appumroh/homemenus/create_rundown_acara.dart';
import 'package:appumroh/homemenus/edit_rundown_acara.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import '../global.dart';
import 'package:timelines/timelines.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/src/material/refresh_indicator.dart' as RefreshIndicator;

void main() {
  runApp(RundownAcara(null, null));
}

class RundownAcara extends StatefulWidget {
  final context, string;

  RundownAcara(this.context, this.string);

  @override
  RundownAcaraState createState() => RundownAcaraState();
}

class RundownAcaraState extends State<RundownAcara>
    with WidgetsBindingObserver {
  var rundowns = [];
  var player;
  bool currentAudioPlaying = false;
  int currentAudioIndex = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "rundown_acara";
      player = AudioPlayer();
    });
    player.onPlayerCompletion.listen((event) {});
    player.onPlayerStateChanged.listen((PlayerState s) {});
    player.onDurationChanged.listen((Duration duration) {});
    player.onAudioPositionChanged.listen((Duration duration) {});
    /*await player.setPlaybackRate(1);
    await player.setReleaseMode(ReleaseMode.LOOP);
    playAudio("https://dl.salamquran.com/ayat/mansouri-murattal-40/001001.mp3");*/
    getRundowns();
  }

  void getRundowns() {
    Global.httpPost(
        widget.string, Uri.parse(Global.API_URL + "/user/get_rundowns"),
        body: <String, String>{"user_id": Global.USER_ID.toString()},
        onSuccess: (response) {
      setState(() {
        rundowns = jsonDecode(response);
      });
    });
  }

  void playAudio(url) async {
    if (currentAudioPlaying) {
      await player.stop();
      await player.release();
    }
    setState(() {
      currentAudioPlaying = true;
    });
    print("========= PLAYING AUDIO =========");
    await player.play(url);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      Container(
          width: width,
          height: 50,
          color: Global.MAIN_COLOR,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                width: 50,
                height: 50,
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                        child: Icon(Ionicons.arrow_back_outline,
                            color: Colors.white, size: 20)))),
            Text(widget.string.text44,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Container(width: 50, height: 50)
          ])),
      Expanded(
          child: Stack(children: [
        RefreshIndicator.RefreshIndicator(
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 50),
              child: FixedTimeline.tileBuilder(
                theme: TimelineThemeData(
                  nodePosition: 0,
                  color: Color(0xff989898),
                  indicatorTheme: IndicatorThemeData(
                    position: 0,
                    size: 20.0,
                  ),
                  connectorTheme: ConnectorThemeData(
                    thickness: 2.5,
                  ),
                ),
                builder: TimelineTileBuilder.connected(
                  connectionDirection: ConnectionDirection.before,
                  itemCount: rundowns.length,
                  contentsBuilder: (_, index) {
                    return Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Container(
                            margin: EdgeInsets.only(top: 8, bottom: 8),
                            child: Card(
                                elevation: 5,
                                margin: EdgeInsets.only(right: 10),
                                clipBehavior: Clip.antiAlias,
                                shadowColor: Color(0xCC888888),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0)),
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      await Global.navigateAndWait(
                                          context,
                                          EditRundownAcara(context,
                                              widget.string, rundowns[index]));
                                      getRundowns();
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(rundowns[index]['activity_name'].toString(), style: TextStyle(
                                                      color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold
                                                    ))
                                                  ]
                                                )
                                              ),
                                              Container(
                                                height: 30,
                                                padding: EdgeInsets.only(left: 10, right: 10),
                                                decoration: BoxDecoration(
                                                  color: Global.MAIN_COLOR,
                                                  borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: () {},
                                                  child: Center(
                                                    child: Text(widget.string.edit, style: TextStyle(
                                                      color: Colors.white, fontSize: 13
                                                    ))
                                                  )
                                                )
                                              ),
                                              SizedBox(width: 2),
                                              Container(
                                                  height: 30,
                                                  padding: EdgeInsets.only(left: 10, right: 10),
                                                  decoration: BoxDecoration(
                                                      color: Global.MAIN_COLOR,
                                                      borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: GestureDetector(
                                                      behavior: HitTestBehavior.translucent,
                                                      onTap: () {},
                                                      child: Center(
                                                          child: Text(widget.string.done, style: TextStyle(
                                                              color: Colors.white, fontSize: 13
                                                          ))
                                                      )
                                                  )
                                              )
                                            ]
                                          ),
                                          SizedBox(height: 8),
                                          Row(children: [
                                            Expanded(
                                                child: Image.network(
                                                    Global.USERDATA_URL +
                                                        rundowns[index]['photo']
                                                            .toString(),
                                                    height: 120,
                                                    fit: BoxFit.cover))
                                          ]),
                                          Text(rundowns[index]['panduan'].toString(), style: TextStyle(
                                              color: Colors.white, fontSize: 10
                                          ), maxLines: 5)
                                        ]))))));
                  },
                  indicatorBuilder: (_, index) {
                    return DotIndicator(
                      color: Color(0xff66c97f),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12.0,
                      ),
                    );
                  },
                  connectorBuilder: (_, index, ___) => SolidLineConnector(
                    color: Color(0xff66c97f),
                  ),
                ),
              ),
            )),
            onRefresh: () {
              return Future.delayed(
                Duration(seconds: 0), () {
                  getRundowns();
                },
              );
            }),
        Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () async {
                  var success = await Global.navigateAndWait(
                      context, CreateRundownAcara(context, widget.string));
                  if (success) {
                    getRundowns();
                  }
                },
                child: Container(
                    width: 200,
                    height: 35,
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: Global.SECONDARY_COLOR),
                    child: Center(
                        child: Text(widget.string.text48,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold))))))
      ])),
      BottomBar(context, widget.string, 1, "rundown_acara")
    ])));
  }
}
