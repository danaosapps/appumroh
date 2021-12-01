import 'dart:convert';

import 'package:appumroh/bottom_bar.dart';
import 'package:appumroh/theme_preview.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'global.dart';

void main() {
  runApp(Chapter(null, null, null, null, null));
}

class Chapter extends StatefulWidget {
  final context, string, surah, needFocus, focusedVerse;
  Chapter(this.context, this.string, this.surah, this.needFocus, this.focusedVerse);

  @override
  ChapterState createState() => ChapterState();
}

class ChapterState extends State<Chapter> with WidgetsBindingObserver {
  var progressShown = true;
  var recitersShown = false;
  var playerShown = false;
  var themesShown = false;
  var isGettingAudios = false;
  var verses = [];
  var reciters = [];
  var audios = [];
  var themes = [];
  var currentAyatPosition = 0;
  var selectedReciter = null;
  var currentAudioDuration = 0;
  var currentAudioPosition = 0;
  double currentSpeed = 1.0;
  var repeatType = 0;
  double verseSize = 17.0;
  double spellingSize = 10.0;
  double meaningSize = 10.0;
  var juzSize = 10.0;
  // 0 = no repeat
  // 1 = repeat
  // 2 = shuffle
  var playing = false;
  var player = null;
  var themesLoading = true;
  ItemScrollController scrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "chapter";
    });
    double audioSpeed = await Global.readDouble("audio_speed", 1.0);
    setState(() {
      progressShown = true;
      player = AudioPlayer();
      currentSpeed = audioSpeed;
    });
    await player.setPlaybackRate(audioSpeed);
    await player.setReleaseMode(ReleaseMode.STOP);
    player.onPlayerCompletion.listen((event) {
      print("repeatType: "+repeatType.toString());
      print("currentAyatPosition: "+currentAyatPosition.toString());
      print("audios length: "+audios.length.toString());
      if (repeatType == 0) {
        playNextAyat();
      }
    });
    player.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        if (s == PlayerState.PLAYING) {
          playing = true;
        } else if (s == PlayerState.STOPPED) {
          playing = false;
        } else if (s == PlayerState.PAUSED) {
          playing = false;
        } else if (s == PlayerState.COMPLETED) {
          playing = false;
        }
      });
    });
    player.onDurationChanged.listen((Duration duration) {
      setState(() {
        currentAudioDuration = duration.inMilliseconds;
      });
      print("AUDIO DURATION UPDATED:");
      print(currentAudioDuration);
    });
    player.onAudioPositionChanged.listen((Duration duration) {
      print("currentAudioDuration: "+currentAudioDuration.toString());
      print("currentAudioPosition: "+duration.inMilliseconds.toString());
      if (playing && currentAudioDuration >= duration.inMilliseconds) {
        setState(() {
          currentAudioPosition = duration.inMilliseconds;
        });
      }
      print("AUDIO POSITION UPDATED:");
      print(currentAudioPosition);
    });
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_verses"),
      body: <String, String>{
        "chapter_id": widget.surah['id'].toString()
      }, onSuccess: (response) {
        print("ALL VERSES:");
        print(response);
        setState(() {
          verses = jsonDecode(response);
        });
        if (widget.needFocus) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            for (var i=0; i<verses.length; i++) {
              var verse = verses[i];
              if (int.parse(verse['verse_number']) == widget.focusedVerse) {
                scrollController.scrollTo(index: i, duration: Duration(seconds: 1));
                break;
              }
            }
          });
        }
        Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_reciters"),
            onSuccess: (response) async {
              setState(() {
                reciters = jsonDecode(response);
              });
              var currentReciterIndex = await Global.readInt("reciter_index", 0);
              if (reciters.length > 0) {
                setState(() {
                  selectedReciter = reciters[currentReciterIndex];
                  isGettingAudios = true;
                  progressShown = false;
                });
                getAudios(int.parse(selectedReciter['id'].toString()),
                  int.parse(verses[0]['id']));
              }
            });
        setState(() {
          themesLoading = true;
        });
        Global.httpGet(widget.string, Uri.parse(Global.API_URL+"/user/get_themes"),
          onSuccess: (response) {
            setState(() {
              themes = jsonDecode(response);
              themesLoading = false;
            });
          });
      });
  }

  void playPrevAyat() {
    if (currentAyatPosition > 0) {
      currentAyatPosition--;
    }
    print("Playing url: "+audios[currentAyatPosition]['url'].toString());
    (() async {
      await player.play(audios[currentAyatPosition]['url'].toString());
    }());
  }

  void playNextAyat() async {
    setState(() {
      if (currentAyatPosition < audios.length) {
        currentAyatPosition++;
      }
    });
    await player.play(audios[currentAyatPosition]['url'].toString());
    await player.setPlaybackRate(currentSpeed);
  }

  void getAudios(reciterID, verseID) {
    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/get_audios"),
      body: <String, String>{
        "reciter_id": reciterID.toString(),
        "chapter_id": widget.surah['id'].toString()
      }, onSuccess: (response) {
        setState(() {
          audios = jsonDecode(response);
          isGettingAudios = false;
        });
        print("ALL AUDIOS:");
        print(audios);
      });
  }

  void playAudio() async {
    if (isGettingAudios) {
      return;
    }
    if (!playerShown) {
      setState(() {
        playerShown = true;
        playing = true;
      });
      (() async {
        await player.play(audios[currentAyatPosition]['url'].toString());
      }());
    } else {
      setState(() {
        playing = !playing;
      });
      if (playing) {
        await player.resume();
      } else {
        await player.pause();
      }
    }
  }

  bool isPrevActive() {
    print("isPrevActive() currentAyatPosition: "+currentAyatPosition.toString());
    print("isPrevActive() audios length: "+audios.length.toString());
    if (currentAyatPosition > 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isNextActive() {
    print("isNextActive() currentAyatPosition: "+currentAyatPosition.toString());
    print("isNextActive() audios length: "+audios.length.toString());
    if (currentAyatPosition < audios.length) {
      return true;
    } else {
      return false;
    }
    return false;
  }

  void showSpeedDialog(width, height) {
    showDialog(context: context, builder: (BuildContext context) {
      var speed = currentSpeed;
      return StatefulBuilder(
        builder: (context, popupSetState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            title: Text(widget.string.text21),
            content: Container(
              width: width,
              height: 83,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Slider(
                    value: speed,
                    min: 1,
                    max: 10,
                    activeColor: Global.MAIN_COLOR,
                    thumbColor: Colors.white,
                    inactiveColor: Color(0xffecf0f1),
                    label: widget.string.speed,
                    onChanged: (double value) async {
                      popupSetState(() {
                        speed = value;
                      });
                    }
                  ),
                  SizedBox(height: 8),
                  Text(speed.toString()+"x", style: TextStyle(
                    color: Colors.black, fontSize: 20
                  ))
                ]
              )
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  setState(() {
                    currentSpeed = speed;
                  });
                  Navigator.pop(context);
                  await Global.writeDouble("audio_speed", currentSpeed);
                  await player.setPlaybackRate(currentSpeed);
                },
                child: Text(widget.string.ok),
              )
            ],
          );
        },
      );
    });
  }

  void goBack() async {
    if (themesShown) {
      setState(() {
        themesShown = false;
      });
    } else {
      if (playing) {
        await player.stop();
      }
      await player.release();
      Navigator.pop(widget.context);
    }
  }

  Future<bool> onWillPop() async {
    goBack();
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
            height: 50,
            color: Global.SECONDARY_COLOR,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 50, height: 50, child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        goBack();
                      },
                      child: Center(
                          child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                      )
                  )),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 8),
                        Text(widget.surah['chapter_id'].toString(), style: TextStyle(
                            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                        )),
                        SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text((widget.surah['classification'].toString()=="Makkiyah"?"Makkah":"Madinah"),
                                style: TextStyle(color: Colors.white, fontSize: 13)),
                            Text(" ( "+widget.surah['verses'].toString()+" "+widget.string.verses+" )",
                                style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic))
                          ]
                        )
                      ]
                  ),
                  Container(width: 50, height: 50)
                ]
            )
        ),
        Expanded(
          child: ScrollablePositionedList.builder(
              itemScrollController: scrollController,
              itemCount: verses.length,
              itemBuilder: (context, index) {
                return Column(
                children: [
                  Container(
                      width: width,
                      color: Global.getColorFromHex(Global.CURRENT_THEME['background_color'].toString()),
                      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Text(verses[index]['verse'].toString(), style: TextStyle(
                                color: Global.getColorFromHex(Global.CURRENT_THEME['verse_color']), fontSize: verseSize
                            ), textAlign: TextAlign.end)),
                            SizedBox(height: 8),
                            Text(verses[index]['spelling'].toString(), style: TextStyle(
                                color: Global.getColorFromHex(Global.CURRENT_THEME['spelling_color']), fontSize: spellingSize
                            ), textAlign: TextAlign.end),
                            SizedBox(height: 8),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text((int.parse(verses[index]['verse_number'].toString())).toString()+". "+verses[index]['meaning'].toString(), style: TextStyle(
                                    color: Global.getColorFromHex(Global.CURRENT_THEME['meaning_color']), fontSize: meaningSize
                                ), textAlign: TextAlign.start)
                            ),
                            Align(
                                alignment: Alignment.centerRight,
                                child: Text(widget.string.juz+" "+verses[index]['juz'].toString(), style: TextStyle(
                                    color: Global.getColorFromHex(Global.CURRENT_THEME['juz_color']), fontSize: juzSize, fontWeight: FontWeight.bold
                                ))
                            )
                          ]
                      )
                  ),
                  Container(width: width, height: 0.5, color: Color(0x7f000000))
                ]
              );
              }
          )
        ),
        (() {
          if (themesShown) {
            return Container(
                width: width,
                height: 242,
                decoration: BoxDecoration(
                    color: Global.SECONDARY_COLOR,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))
                ),
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(widget.string.text22, style: TextStyle(
                            color: Colors.white, fontSize: 13
                        ))
                      ),
                      SizedBox(height: 8),
                      (() {
                        if (themesLoading) {
                          return Container(
                            width: width,
                            height: 100,
                            child: Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: Colors.white
                                )
                              )
                            )
                          );
                        } else {
                          return Container(
                            width: width,
                            height: 130,
                            padding: EdgeInsets.only(left: 4, right: 4),
                            child: Flexible(
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: themes.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 150,
                                        height: 150,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () async {
                                            if (int.parse(themes[index]['premium']) != 1) {
                                              setState(() {
                                                Global.CURRENT_QURAN_THEME_ID = int.parse(themes[index]['id']);
                                                Global.CURRENT_THEME = themes[index];
                                              });
                                              await Global.writeInt("current_theme_id", int.parse(themes[index]['id'].toString()));
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                  margin: EdgeInsets.only(left: 4, right: 4),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 4,
                                                          color: Global.CURRENT_QURAN_THEME_ID==int.parse(themes[index]['id'])?Global.MAIN_COLOR:Colors.transparent
                                                      ),
                                                      borderRadius: BorderRadius.circular(25)
                                                  ),
                                                  child: ThemePreview(
                                                      context, widget.string,
                                                      int.parse(themes[index]['id']),
                                                      Global.getColorFromHex(themes[index]['background_color'].toString()),
                                                      themes[index]['background_image']==null?null
                                                          :themes[index]['background_image'].toString().trim()=="null"?null
                                                          :themes[index]['background_image'].toString().trim()==""?null
                                                          :themes[index]['background_image'].toString(),
                                                      Global.getColorFromHex(themes[index]['verse_color'].toString()),
                                                      Global.getColorFromHex(themes[index]['spelling_color'].toString()),
                                                      Global.getColorFromHex(themes[index]['meaning_color'].toString()),
                                                      Global.getColorFromHex(themes[index]['juz_color'].toString()),
                                                      int.parse(themes[index]['premium'])==1?true:false
                                                  )),
                                              (() {
                                                if (Global.CURRENT_QURAN_THEME_ID==int.parse(themes[index]['id'])) {
                                                  return Align(
                                                      alignment: Alignment.topRight,
                                                      child: Container(
                                                          width: 20, height: 20,
                                                          margin: EdgeInsets.only(top: 8, right: 8),
                                                          decoration: BoxDecoration(
                                                              color: Global.MAIN_COLOR,
                                                              borderRadius: BorderRadius.circular(10)
                                                          ),
                                                          child: Center(
                                                              child: Icon(Ionicons.checkmark, color: Colors.white, size: 17)
                                                          )
                                                      )
                                                  );
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              }())
                                            ]
                                        ))
                                      );
                                    }
                                )
                            )
                          );
                        }
                      }()),
                      SizedBox(height: 12),
                      Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(widget.string.text23, style: TextStyle(
                              color: Colors.white, fontSize: 13
                          ))
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 30, height: 30, decoration: BoxDecoration(
                                color: Global.MAIN_COLOR,
                                borderRadius: BorderRadius.circular(15)
                              ),
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        if (verseSize > 5) {
                                          verseSize--;
                                        }
                                        if (spellingSize > 5) {
                                          spellingSize--;
                                        }
                                        if (meaningSize > 5) {
                                          meaningSize--;
                                        }
                                        if (juzSize > 5) {
                                          juzSize--;
                                        }
                                      });
                                    },
                                    child: Center(
                                        child: Text("A-", style: TextStyle(
                                            color: Colors.white, fontSize: 17
                                        ))
                                    )
                                )
                            ),
                            Container(
                                width: 30, height: 30, decoration: BoxDecoration(
                                color: Global.MAIN_COLOR,
                                borderRadius: BorderRadius.circular(15)
                            ),
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        if (verseSize < 41) {
                                          verseSize++;
                                        }
                                        if (spellingSize < 34) {
                                          spellingSize++;
                                        }
                                        if (meaningSize < 34) {
                                          meaningSize++;
                                        }
                                        if (juzSize < 34) {
                                          juzSize++;
                                        }
                                      });
                                    },
                                    child: Center(
                                        child: Text("A+", style: TextStyle(
                                            color: Colors.white, fontSize: 17
                                        ))
                                    )
                                )
                            ),
                            Container(
                                width: 30, height: 30, decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)
                            ),
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {},
                                    child: Center(
                                        child: Container(
                                          width: 24, height: 24,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12)
                                          ),
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.asset("assets/images/color.png", width: 30, height: 30, fit: BoxFit.cover)
                                          )
                                        )
                                    )
                                )
                            )
                          ]
                        )
                      )
                    ]
                ));
          } else {
            return SizedBox.shrink();
          }
        }()),
        (() {
          if (playerShown) {
            return Container(width: width,
                decoration: BoxDecoration(
                    color: Global.SECONDARY_COLOR,
                    borderRadius:
                    (themesShown&&playerShown)?
                      BorderRadius.zero:
                      BorderRadius.only(topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))
                ),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8),
                Text(widget.surah['chapter_id'].toString(), style: TextStyle(
                  color: Colors.white, fontSize: 20
                )),
                (() {
                  if (selectedReciter == null) {
                    return SizedBox.shrink();
                  } else {
                    return Text(selectedReciter['name'].toString(), style: TextStyle(
                        color: Colors.white, fontSize: 13
                    ));
                  }
                }()),
                Container(
                    width: width,
                    child: Slider(
                      value: currentAudioPosition.toDouble(),
                      min: 0,
                      max: currentAudioDuration.toDouble(),
                      activeColor: Colors.white,
                      thumbColor: Colors.white,
                      inactiveColor: Global.MAIN_COLOR,
                      label: currentAudioPosition.round().toString(),
                      onChanged: (double value) async {
                        await player.seek(Duration(milliseconds: value.toInt()));
                      },
                    )),
                Container(
                  width: width,
                  child: Row(
                    children: [
                      Container(width: width/5, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          //showSpeedDialog(width, height);
                          setState(() {
                            if (currentSpeed == 1) {
                              currentSpeed = 1.25;
                            } else if (currentSpeed == 1.25) {
                              currentSpeed = 1.5;
                            } else if (currentSpeed == 1.5) {
                              currentSpeed = 1.75;
                            } else {
                              currentSpeed = 1;
                            }
                          });
                          await Global.writeDouble("audio_speed", currentSpeed);
                          await player.setPlaybackRate(currentSpeed);
                        },
                        child: Center(
                          child: Text(currentSpeed.toString()+"x", style: TextStyle(color: Colors.white, fontSize: 15))
                        )
                      )),
                      Container(width: width/5, child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            playPrevAyat();
                          },
                          child: Center(
                              child: Image.asset(isPrevActive()?"assets/images/prev_white.png":"assets/images/prev.png", width: 20, height: 20, fit: BoxFit.fill)
                          )
                      )),
                      Container(width: width/5, child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            playAudio();
                          },
                          child: Center(
                              child: Container(width: 20, height: 20, child: Center(
                                  child: playing?
                                  Icon(Ionicons.pause, color: Colors.white, size: 20):
                                  Image.asset("assets/images/play.png", width: 30, height: 30)
                              ))
                          )
                      )),
                      Container(width: width/5, child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            playNextAyat();
                          },
                          child: Center(
                              child: Image.asset(isNextActive()?"assets/images/next_white.png":"assets/images/next.png", width: 20, height: 20, fit: BoxFit.fill)
                          )
                      )),
                      Container(width: width/5, child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            setState(() {
                              if (repeatType == 0) {
                                repeatType = 1;
                              } else {
                                repeatType = 0;
                              }
                            });
                            if (repeatType == 0) {
                              await player.setReleaseMode(ReleaseMode.STOP);
                            } else if (repeatType == 1) {
                              await player.setReleaseMode(ReleaseMode.LOOP);
                            }
                          },
                          child: Center(
                              child: repeatType==0?Image.asset("assets/images/no_repeat.png", width: 17, height: 18, fit: BoxFit.fill):Image.asset("assets/images/repeat.png", width: 17, height: 18, fit: BoxFit.fill)
                          )
                      ))
                    ]
                  )
                ),
                SizedBox(height: 10)
              ]
            ));
          } else {
            return SizedBox.shrink();
          }
        }()),
        (() {
          if (recitersShown) {
            return Container(
              width: width,
              height: 120,
              color: Global.SECONDARY_COLOR,
              child: Padding(
                padding: EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: reciters.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(left: 4, right: 4),
                          decoration: BoxDecoration(color: Global.MAIN_COLOR, borderRadius: BorderRadius.circular(20)),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              await Global.writeInt("reciter_index", index);
                              setState(() {
                                selectedReciter = reciters[index];
                                isGettingAudios = true;
                              });
                              getAudios(int.parse(selectedReciter['id']), int.parse(verses[0]['id']));
                            },
                            child: Stack(
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(top: 8, bottom: 8),
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(
                                                borderRadius: BorderRadius.circular(35),
                                                child: Image.network(Global.USERDATA_URL+reciters[index]['photo'].toString(),
                                                    width: 50, height: 50, fit: BoxFit.cover)
                                            ),
                                            SizedBox(height: 8),
                                            Text(reciters[index]['name'].toString(),
                                                style: TextStyle(color: Colors.white, fontSize: 10),
                                                textAlign: TextAlign.center),
                                            SizedBox(height: 2),
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                      borderRadius: BorderRadius.circular(35),
                                                      child: Image.asset('icons/flags/png/'+reciters[index]['country_code'].toString()+'.png', package: 'country_icons',
                                                          width: 15, height: 15, fit: BoxFit.cover)
                                                  ),
                                                  SizedBox(width: 2),
                                                  Text(reciters[index]['country'].toString(),
                                                      style: TextStyle(color: Colors.white, fontSize: 10),
                                                      textAlign: TextAlign.center)
                                                ]
                                            )
                                          ]
                                      )
                                  ),
                                  (() {
                                    if (selectedReciter == reciters[index]) {
                                      return Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                              padding: EdgeInsets.only(left: 8, top: 8),
                                              child: Icon(Ionicons.checkmark_circle, color: Colors.white, size: 16)
                                          )
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  }())
                                ]
                            )
                          )
                        );
                        return Container();
                      }
                  )
              )
            );
          } else {
            return SizedBox.shrink();
          }
        }()),
        Container(
            width: width,
            color: Global.SECONDARY_COLOR,
            padding: EdgeInsets.only(top: 6, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          themesShown = !themesShown;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/monitor.png", width: 25, height: 25, fit: BoxFit.fill),
                          SizedBox(height: 5),
                          Text(widget.string.display, style: TextStyle(color: Colors.white, fontSize: 10))
                        ]
                      )
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            recitersShown = !recitersShown;
                          });
                        },
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/audio.png", width: 28, height: 23, fit: BoxFit.fill),
                              SizedBox(height: 7),
                              Text(widget.string.audio, style: TextStyle(color: Colors.white, fontSize: 10))
                            ]
                        )
                    )
                  ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            playPrevAyat();
                          },
                          child: Container(width: 20, height: 15, child: Center(
                            child: Image.asset(isPrevActive()?"assets/images/prev_white.png":"assets/images/prev.png", width: 30, height: 30)
                          ))
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            playAudio();
                          },
                          child: Container(width: 20, height: 20, child: Center(
                              child: playing?
                              Icon(Ionicons.pause, color: Colors.white, size: 20):
                              Image.asset("assets/images/play.png", width: 30, height: 30)
                          ))
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            playNextAyat();
                          },
                          child: Container(width: 20, height: 15, child: Center(
                              child: Image.asset(isNextActive()?"assets/images/next_white.png":"assets/images/next.png", width: 30, height: 30)
                          ))
                      ),
                      SizedBox(width: 10)
                    ]
                )
              ]
            )
        ),
        Container(
            width: width,
            height: 50,
            child: BottomBar(context, widget.string, 1, "chapter")
        )
      ]
    ))));
  }
}
