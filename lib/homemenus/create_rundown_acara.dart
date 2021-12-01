import 'dart:io';
import 'dart:async';
import 'package:appumroh/bottom_bar.dart';
import 'package:appumroh/homemenus/create_rundown_acara.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:appumroh/global.dart';
import 'package:jiffy/jiffy.dart';
import 'package:timelines/timelines.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

void main() {
  runApp(CreateRundownAcara(null, null));
}

class CreateRundownAcara extends StatefulWidget {
  final context, string;
  CreateRundownAcara(this.context, this.string);

  @override
  CreateRundownAcaraState createState() => CreateRundownAcaraState();
}

class CreateRundownAcaraState extends State<CreateRundownAcara> with WidgetsBindingObserver, TickerProviderStateMixin {
  /*var titleController = TextEditingController(text: "Judul kegiatan");
  var placeNameController = TextEditingController(text: "Nama tempat");
  var panduanController = TextEditingController(text: "Panduan 1");
  var laranganController = TextEditingController(text: "Larangan 1");
  var doaController = TextEditingController(text: "Doa 1");*/
  var titleController = TextEditingController(text: "");
  var placeNameController = TextEditingController(text: "");
  var panduanController = TextEditingController(text: "");
  var laranganController = TextEditingController(text: "");
  var doaController = TextEditingController(text: "");
  var startTime = null;
  var endTime = null;
  final ImagePicker imagePicker = ImagePicker();
  var selectedPhoto = null;
  bool isRecording = false;
  var recordingTextShown = true;
  final audioRecorder = Record();
  var savedAudioPath = null;
  var isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  var useDefaultVoice = false;
  var isAudioLocal = false;
  var changesMade = false;
  var totalRecordingSeconds = 0;
  var recordingTimer = null;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "create_rundown_acara";
      if (Global.USER_INFO['default_voice_path']!=null
        && Global.USER_INFO['default_voice_path'].toString().trim()!="null"
          && Global.USER_INFO['default_voice_path'].toString().trim()!="") {
        useDefaultVoice = true;
        savedAudioPath = Global.USERDATA_URL+Global.USER_INFO['default_voice_path'].toString().trim();
        isAudioLocal = false;
      }
    });
    print("savedAudioPath:");
    print(savedAudioPath);
  }

  void goBack(context) {
    if (changesMade) {
      Global.confirm(context, widget.string,
          widget.string.confirmation,
          widget.string.text81, () {
            Navigator.pop(context);
          }, () {});
    } else {
      Navigator.pop(context);
    }
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
                  height: 50,
                  color: Global.MAIN_COLOR,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 50, height: 50, child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              goBack(context);
                            },
                            child: Center(
                                child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                            )
                        )
                        ),
                        Text(widget.string.text48, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Container(width: 50, height: 50)
                      ]
                  )
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.string.text49, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      DatePicker.showDatePicker(context,
                                          showTitleActions: true,
                                          onChanged: (date) {
                                            print('change $date');
                                          }, onConfirm: (date) async {
                                            final TimeOfDay newTime = (await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(hour: 7, minute: 15),
                                            ))!;
                                            setState(() {
                                              startTime = Jiffy({
                                                "year": date.year,
                                                "month": date.month,
                                                "day": date.day,
                                                "hour": newTime.hour,
                                                "minute": newTime.minute,
                                                "second": 0
                                              }).dateTime;
                                              changesMade = true;
                                            });
                                          },
                                          currentTime: DateTime.now()
                                      );
                                    },
                                    child: Container(
                                        height: 30,
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Ionicons.calendar_outline, color: Colors.black, size: 17),
                                              SizedBox(width: 4),
                                              Text(startTime==null?widget.string.text59:Jiffy(startTime).format("d MMMM yyyy HH:mm:ss"),
                                                  style: TextStyle(
                                                      color: Color(startTime==null?0xffbdc3c7:0xff000000),
                                                      fontSize: 12
                                                  ))
                                            ]
                                        )
                                    )
                                ),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 1,
                                    color: Global.MAIN_COLOR
                                ),
                                SizedBox(height: 8),
                                Text(widget.string.text50, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      DatePicker.showDatePicker(context,
                                          showTitleActions: true,
                                          onChanged: (date) {
                                            print('change $date');
                                          }, onConfirm: (date) async {
                                            final TimeOfDay newTime = (await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay(hour: 7, minute: 15),
                                            ))!;
                                            setState(() {
                                              endTime = Jiffy({
                                                "year": date.year,
                                                "month": date.month,
                                                "day": date.day,
                                                "hour": newTime.hour,
                                                "minute": newTime.minute,
                                                "second": 0
                                              }).dateTime;
                                              changesMade = true;
                                            });
                                          },
                                          currentTime: DateTime.now()
                                      );
                                    },
                                    child: Container(
                                        height: 30,
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Ionicons.calendar_outline, color: Colors.black, size: 17),
                                              SizedBox(width: 4),
                                              Text(endTime==null?widget.string.text60:Jiffy(endTime).format("d MMMM yyyy HH:mm:ss"),
                                                  style: TextStyle(
                                                      color: Color(endTime==null?0xffbdc3c7:0xff000000),
                                                      fontSize: 12
                                                  ))
                                            ]
                                        )
                                    )
                                ),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 1,
                                    color: Global.MAIN_COLOR
                                ),
                                SizedBox(height: 16),
                                Text(widget.string.text51, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 30,
                                    child: TextField(onChanged: (value) {
                                      setState(() {
                                        changesMade = true;
                                      });
                                    }, decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text61, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: titleController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))
                                ),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 1,
                                    color: Global.MAIN_COLOR
                                ),
                                SizedBox(height: 16),
                                Text(widget.string.text52, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 30,
                                    child: TextField(onChanged: (value) {
                                      setState(() {
                                        changesMade = true;
                                      });
                                    }, decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text62, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: placeNameController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))
                                ),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 1,
                                    color: Global.MAIN_COLOR
                                ),
                                SizedBox(height: 16),
                                Text(widget.string.text53, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      if (!kIsWeb) {
                                        Map<Permission, PermissionStatus> statuses = await [
                                          Permission.camera
                                        ].request();
                                        if (statuses[Permission.camera] == PermissionStatus.granted) {
                                          final XFile? photo = await imagePicker.pickImage(source: ImageSource.camera);
                                          setState(() {
                                            selectedPhoto = photo;
                                            changesMade = true;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(
                                        width: width-10-10,
                                        height: 150,
                                        decoration: BoxDecoration(
                                            color: Color(0x7f4c945c),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Center(
                                            child: selectedPhoto==null?Icon(Ionicons.image, color: Colors.white, size: 80):
                                            Image.file(File(selectedPhoto.path), width: 150, height: 150, fit: BoxFit.cover)
                                        )
                                    )
                                ),
                                SizedBox(height: 16),
                                Text(widget.string.text54, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 120,
                                    decoration: BoxDecoration(
                                        color: Color(0xffeeeeee),
                                        border: Border.all(width: 1, color: Color(0x7f000000))
                                    ),
                                    child: TextField(onChanged: (value) {
                                      setState(() {
                                        changesMade = true;
                                      });
                                    }, decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text63, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: panduanController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))
                                ),
                                SizedBox(height: 16),
                                Text(widget.string.text55, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 120,
                                    decoration: BoxDecoration(
                                        color: Color(0xffeeeeee),
                                        border: Border.all(width: 1, color: Color(0x7f000000))
                                    ),
                                    child: TextField(onChanged: (value) {
                                      setState(() {
                                        changesMade = true;
                                      });
                                    }, decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text64, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: laranganController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))
                                ),
                                SizedBox(height: 16),
                                Text(widget.string.text56, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                Container(
                                    width: width-10-10,
                                    height: 120,
                                    decoration: BoxDecoration(
                                        color: Color(0xffeeeeee),
                                        border: Border.all(width: 1, color: Color(0x7f000000))
                                    ),
                                    child: TextField(onChanged: (value) {
                                      setState(() {
                                        changesMade = true;
                                      });
                                    }, decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text65, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: doaController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))
                                ),
                                SizedBox(height: 16),
                                Text(widget.string.text57, style: TextStyle(
                                    color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold
                                )),
                                SizedBox(height: 2),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          height: 20,
                                          padding: EdgeInsets.only(left: 8, right: 8),
                                          decoration: BoxDecoration(
                                              color: useDefaultVoice?Color(0x7f4c945c):Global.MAIN_COLOR,
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: () {
                                                if (!useDefaultVoice) {
                                                  Global.confirm(context, widget.string, widget.string.confirmation, widget.string.text67, () {}, () {});
                                                }
                                              },
                                              child: Center(
                                                  child: Text(widget.string.text58, style: TextStyle(
                                                      color: Colors.white, fontSize: 10
                                                  ))
                                              )
                                          )
                                      ),
                                      GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () async {
                                            Map<Permission, PermissionStatus> statuses = await [
                                              Permission.microphone
                                            ].request();
                                            if (statuses[Permission.microphone] == PermissionStatus.granted) {
                                              await audioPlayer.stop();
                                              await audioPlayer.release();
                                              setState(() {
                                                isRecording = !isRecording;
                                                isPlaying = false;
                                              });
                                              if (isRecording) {
                                                var timer = Timer.periodic(Duration(seconds: 1),
                                                        (Timer t) {
                                                          setState(() {
                                                            totalRecordingSeconds += 1;
                                                          });
                                                        });
                                                setState(() {
                                                  recordingTimer = timer;
                                                });
                                                await audioRecorder.start();
                                              } else {
                                                if (recordingTimer != null) {
                                                  recordingTimer.cancel();
                                                }
                                                final path = await audioRecorder.stop();
                                                setState(() {
                                                  savedAudioPath = path;
                                                  changesMade = true;
                                                  recordingTimer = null;
                                                });
                                              }
                                            }
                                          },
                                          child: Padding(
                                              padding: EdgeInsets.only(top: 8, bottom: 8),
                                              child: Container(
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(width: 1, color: Color(0xffe74c3c)),
                                                      borderRadius: BorderRadius.circular(12)
                                                  ),
                                                  child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            width: 20, height: 20, decoration: BoxDecoration(
                                                            color: Color(0xffe74c3c),
                                                            borderRadius: BorderRadius.circular(12)
                                                        ),
                                                            child: Center(
                                                                child: Container(
                                                                    width: 14, height: 14, decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.circular(7)
                                                                ),
                                                                    child: (() {
                                                                      if (isRecording) {
                                                                        return Icon(Ionicons.stop, color: Colors.black, size: 10);
                                                                      } else {
                                                                        return Icon(Ionicons.mic, color: Colors.black, size: 12);
                                                                      }
                                                                    }())
                                                                )
                                                            )
                                                        ),
                                                        SizedBox(width: 10),
                                                        (() {
                                                          if (isRecording) {
                                                            late final AnimationController animationController = AnimationController(
                                                              duration: const Duration(seconds: 1),
                                                              vsync: this,
                                                            )..repeat(reverse: true);
                                                            late final Animation<double> _animation = CurvedAnimation(
                                                              parent: animationController,
                                                              curve: Curves.easeIn,
                                                            );
                                                            return FadeTransition(
                                                                opacity: animationController.drive(CurveTween(curve: Curves.easeOut)),
                                                                child: Text(widget.string.text66,
                                                                    style: TextStyle(
                                                                        color: Color(0xffe74c3c),
                                                                        fontSize: 9
                                                                    ))
                                                            );
                                                          } else {
                                                            return Text(widget.string.record,
                                                                style: TextStyle(
                                                                    color: Color(0xffe74c3c),
                                                                    fontSize: 9
                                                                ));
                                                          }
                                                        }()),
                                                        (() {
                                                          if (isRecording) {
                                                            return SizedBox(width: 2);
                                                          } else {
                                                            return SizedBox.shrink();
                                                          }
                                                        }()),
                                                        (() {
                                                          if (isRecording) {
                                                            var duration = Duration(seconds: totalRecordingSeconds);
                                                            return Text(duration.inHours.toString()+":"+duration.inSeconds.remainder(60).toString()+":"+duration.inSeconds.remainder(60).toString(), style: TextStyle(
                                                              color: Colors.black,
                                                                fontSize: 9
                                                            ));
                                                          } else {
                                                            return SizedBox.shrink();
                                                          }
                                                        }()),
                                                        SizedBox(width: 10)
                                                      ]
                                                  )
                                              )
                                          )
                                      ),
                                      Container(
                                          width: 70,
                                          child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(width: 25, height: 20, child: GestureDetector(
                                                    behavior: HitTestBehavior.translucent,
                                                    onTap: () async {
                                                      if (isPlaying) {
                                                        setState(() {
                                                          isPlaying = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          isPlaying = true;
                                                        });
                                                      }
                                                      await audioPlayer.setReleaseMode(ReleaseMode.LOOP);
                                                      if (isPlaying) {
                                                        await audioPlayer.play(savedAudioPath, isLocal: true);
                                                      } else {
                                                        await audioPlayer.pause();
                                                      }
                                                    },
                                                    child: Center(
                                                        child: Icon(isPlaying?Ionicons.pause:Ionicons.play, color: savedAudioPath==null?Color(0x7f4c945c):Global.MAIN_COLOR, size: 20)
                                                    )
                                                ))
                                              ]
                                          )
                                      )
                                    ]
                                )
                              ]
                          )
                      )
                  )
              ),
              Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 2),
                                child: Center(
                                    child: Container(
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: Color(0xffe74c3c),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              goBack(context);
                                            },
                                            child: Center(
                                                child: Text(widget.string.cancel, style: TextStyle(
                                                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold
                                                ))
                                            )
                                        )
                                    )
                                )
                            )
                        ),
                        Expanded(
                            child: Padding(
                                padding: EdgeInsets.only(left: 2, right: 10),
                                child: Center(
                                    child: Container(
                                        height: 35,
                                        decoration: BoxDecoration(
                                            color: Color(0xff2f3542),
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () async {
                                              if (startTime == null) {
                                                Global.show(widget.string.text68);
                                                return;
                                              }
                                              if (endTime == null) {
                                                Global.show(widget.string.text69);
                                                return;
                                              }
                                              if (titleController.text.trim() == "") {
                                                Global.show(widget.string.text70);
                                                return;
                                              }
                                              if (placeNameController.text.trim() == "") {
                                                Global.show(widget.string.text71);
                                                return;
                                              }
                                              if (selectedPhoto == null) {
                                                Global.show(widget.string.text72);
                                                return;
                                              }
                                              if (panduanController.text.trim() == "") {
                                                Global.show(widget.string.text73);
                                                return;
                                              }
                                              if (laranganController.text.trim() == "") {
                                                Global.show(widget.string.text74);
                                                return;
                                              }
                                              if (doaController.text.trim() == "") {
                                                Global.show(widget.string.text75);
                                                return;
                                              }
                                              await Global.showProgressDialog(context, widget.string.uploading);
                                              try {
                                                var request = new http.MultipartRequest("POST", Uri.parse(Global.API_URL + "/user/add_rundown"));
                                                request.fields['user_id'] = Global.USER_ID.toString();
                                                request.fields['date_start'] = Jiffy(startTime).format("yyyy-MM-dd HH:mm:ss");
                                                request.fields['date_end'] = Jiffy(endTime).format("yyyy-MM-dd HH:mm:ss");
                                                request.fields['activity_name'] = titleController.text.trim();
                                                request.fields['place_name'] = placeNameController.text.trim();
                                                request.files.add(await http.MultipartFile('photo', File(selectedPhoto!.path).readAsBytes().asStream(), File(selectedPhoto!.path).lengthSync(), filename: Uuid().v1() + ".jpg"));
                                                request.fields['panduan'] = panduanController.text.trim();
                                                request.fields['larangan'] = laranganController.text.trim();
                                                request.fields['doa'] = doaController.text.trim();
                                                if (savedAudioPath == null) {
                                                  request.fields['voice_recorded'] = "0";
                                                } else {
                                                  request.fields['voice_recorded'] = "1";
                                                  request.files.add(await http.MultipartFile('voice', File(savedAudioPath).readAsBytes().asStream(), File(savedAudioPath).lengthSync(), filename: Uuid().v1() + ".jpg"));
                                                }
                                                request.send().then((responseStream) async {
                                                  var response = await responseStream.stream.bytesToString();
                                                  Global.show("add_rundown response: "+response);
                                                  await Global.hideProgressDialog(context);
                                                  //Global.show(widget.string.text76);
                                                  Navigator.pop(context, true);
                                                });
                                              } catch (e) {
                                                print(e);
                                              }
                                            },
                                            child: Center(
                                                child: Text(widget.string.create, style: TextStyle(
                                                    color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold
                                                ))
                                            )
                                        )
                                    )
                                )
                            )
                        )
                      ]
                  )
              ),
              SizedBox(height: 10),
              BottomBar(context, widget.string, 1, "create_rundown_acara")
            ]
        )))
    );
  }
}
