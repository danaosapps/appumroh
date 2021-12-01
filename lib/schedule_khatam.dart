import 'package:appumroh/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'global.dart';

void main() {
  runApp(ScheduleKhatam(null, null));
}

class ScheduleKhatam extends StatefulWidget {
  final context, string;
  ScheduleKhatam(this.context, this.string);

  @override
  ScheduleKhatamState createState() => ScheduleKhatamState();
}

class ScheduleKhatamState extends State<ScheduleKhatam> with WidgetsBindingObserver {
  var currentDate = Jiffy(Global.USER_INFO['scheduled_khatam_date'].toString(), "yyyy-MM-dd HH:mm:ss").dateTime;
  var selectedDate = DateTime.now();
  var diffHours = 24;
  var invalidDateShown = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "schedule_khatam";
      var currentDateTime = Jiffy(currentDate);
      var day = currentDateTime.day;
      var month = currentDateTime.month;
      var year = currentDateTime.year;
      var today = Jiffy(DateTime.now());
      if (day == today.day && month == today.month && year == today.year) {
        selectedDate = Jiffy(currentDate).add(duration: Duration(days: 1)).dateTime;
      } else {
        selectedDate = currentDate;
      }
    });
  }

  String getDuration() {
    var perJuzDuration = diffHours.toDouble()/30.0;
    String duration = perJuzDuration.toString()+" "+widget.string.hour;
    if (perJuzDuration < 24) {
      duration = perJuzDuration.toInt().toString()+" "+widget.string.hour;
    } else if (perJuzDuration >= 24 && perJuzDuration < 24*7) {
      duration = (perJuzDuration/24).toInt().toString()+" "+widget.string.day;
    } else if (perJuzDuration >= 24*7 && perJuzDuration < 24*7*4) {
      duration = (perJuzDuration/24/7).toInt().toString()+" "+widget.string.week;
    } else if (perJuzDuration >= 24*7*4 && perJuzDuration < 24*7*4*30) {
      duration = (perJuzDuration/24/7/4).toInt().toString()+" "+widget.string.month;
    } else {
      duration = (perJuzDuration/24/7/4/30).toInt().toString()+" "+widget.string.year;
    }
    return duration;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(
      color: Global.SECONDARY_COLOR,
      child: Column(
        children: [
          Container(width: width, height: 50, child: Row(
            children: [
              Container(width: 50, height: 50, child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20))
              )),
              Text(widget.string.text36, style: TextStyle(color: Colors.white, fontSize: 15)),
              SizedBox.shrink()
            ]
          )),
          Expanded(
            child: Container(
              width: width,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.string.text37, style: TextStyle(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold
                      )),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        child: DatePickerWidget(
                            looping: false,
                            firstDate: Jiffy([
                              Jiffy(currentDate).year,
                              1,
                              Jiffy(currentDate).day
                            ]).add(duration: Duration(days: 1)).dateTime,
                            initialDate: selectedDate,
                            dateFormat: "d-MMM-yyyy",
                            onChange: (DateTime newDate, _) {
                              var _diffHours = Jiffy(currentDate).diff(newDate, Units.HOUR).abs().toInt();
                              if (_diffHours < 0) {
                                _diffHours = -_diffHours;
                              }
                              if (Jiffy(newDate).diff(Jiffy(currentDate)) > 0) {
                                setState(() {
                                  diffHours = _diffHours;
                                  invalidDateShown = false;
                                });
                              } else {
                                setState(() {
                                  diffHours = 0;
                                  invalidDateShown = true;
                                });
                              }
                              setState(() {
                                selectedDate = newDate;
                              });
                            },
                            pickerTheme: DateTimePickerTheme(
                                backgroundColor: Global.SECONDARY_COLOR,
                                itemTextStyle: TextStyle(color: Colors.white, fontSize: 17),
                                dividerColor: Colors.white
                            )
                        )
                      ),
                      SizedBox(height: 30),
                      Align(
                          alignment: Alignment.center,
                          child: Text(invalidDateShown?widget.string.text40:"", style: TextStyle(
                              color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold
                          ), textAlign: TextAlign.center)
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.only(left: 30, right: 30),
                        child: Text(widget.string.text38+" "+getDuration()+" "+widget.string.text39+" "+Jiffy(selectedDate).format("MMMM dd, yyyy"), style: TextStyle(
                          color: Colors.white, fontSize: 10
                      ), textAlign: TextAlign.center)),
                      SizedBox(height: 30),
                      Container(
                        width: width-30-30,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_scheduled_khatam_date"),
                              body: <String, String>{
                                "user_id": Global.USER_ID.toString(),
                                "scheduled_khatam_date": Jiffy(selectedDate).format("yyyy-MM-dd HH:mm:ss")
                              }, onSuccess: (response) {
                              });
                            setState(() {
                              Global.USER_INFO['scheduled_khatam_date'] = Jiffy(selectedDate).format("yyyy-MM-dd HH:mm:ss");
                            });
                            Navigator.pop(context);
                          },
                          child: Center(
                            child: Text(widget.string.text20, style: TextStyle(
                              color: Global.MAIN_COLOR, fontSize: 15, fontWeight: FontWeight.bold
                            ))
                          )
                        )
                      )
                    ]
                )
              )
            )
          ),
          Container(
              width: width,
              height: 10,
              color: Colors.white
          ),
          Container(
              width: width,
              height: 50,
              child: BottomBar(context, widget.string, 1, "schedule_khatam")
          )
        ]
      )
    )));
  }
}
