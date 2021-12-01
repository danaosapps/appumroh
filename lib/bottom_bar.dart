import 'package:appumroh/account.dart';
import 'package:appumroh/login/login_page.dart';
import 'package:appumroh/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'global.dart';
import 'home.dart';
import 'ibadah.dart';

void main() {
  runApp(BottomBar(null, null, null, null));
}

class BottomBar extends StatelessWidget {
  final context, string, selectedBottomIndex, from;
  BottomBar(this.context, this.string, this.selectedBottomIndex, this.from);
  var selectedGroupIndex = 0;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: selectedBottomIndex==0?Color(0xffe4e4e4):Colors.transparent,
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (from == "main_menu") {
                            Navigator.pop(context);
                          } else {
                            Global.navigate(context, Home(context, string));
                          }
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              (() {
                                if (selectedBottomIndex == 0) {
                                  return SizedBox.shrink();
                                } else {
                                  return Image.asset("assets/images/activity_group.png", width: 25, height: 25);
                                }
                              }()),
                              (() {
                                if (selectedBottomIndex == 0) {
                                  return SizedBox.shrink();
                                } else {
                                  return SizedBox(width: 2);
                                }
                              }()),
                              Text(string.text261,
                                  style: TextStyle(color: selectedBottomIndex==0?Color(0xff4b4b4b):Color(0xffe4e4e4),
                                      fontSize: 12, fontWeight: FontWeight.bold))
                            ]
                        )
                      )
                  )
              ),
              Expanded(
                  child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: selectedBottomIndex==1?Color(0xffe4e4e4):Colors.transparent,
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Global.navigate(context, MainMenu(context, string));
                        },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                (() {
                                  if (selectedBottomIndex == 1) {
                                    return SizedBox.shrink();
                                  } else {
                                    return Image.asset("assets/images/moon_2.png", width: 25, height: 25);
                                  }
                                }()),
                                (() {
                                  if (selectedBottomIndex == 1) {
                                    return SizedBox.shrink();
                                  } else {
                                    return SizedBox(width: 2);
                                  }
                                }()),
                                Text(string.home,
                                    style: TextStyle(color: selectedBottomIndex==1?Color(0xff4b4b4b):Color(0xffe4e4e4),
                                        fontSize: 12, fontWeight: FontWeight.bold))
                              ]
                          )
                      )
                  )
              ),
              Expanded(
                  child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                          color: selectedBottomIndex==2?Color(0xffe4e4e4):Colors.transparent,
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (Global.USER_ID == 0) {
                            var result = await Global.navigateAndWait(context, LoginPage(context, string));
                            if (result == "login_success") {
                              HomeState.initGroups(string);
                            }
                          } else {
                            var result = await Global.navigateAndWait(context, Account(context, string));
                            if (result == "logout") {
                              HomeState.initGroups(string);
                            }
                          }
                        },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                (() {
                                  if (selectedBottomIndex == 2) {
                                    return SizedBox.shrink();
                                  } else {
                                    return Image.asset("assets/images/account.png", width: 25, height: 25);
                                  }
                                }()),
                                (() {
                                  if (selectedBottomIndex == 2) {
                                    return SizedBox.shrink();
                                  } else {
                                    return SizedBox(width: 2);
                                  }
                                }()),
                                Text(string.text13,
                                    style: TextStyle(color: selectedBottomIndex==2?Color(0xff4b4b4b):Color(0xffe4e4e4),
                                        fontSize: 12, fontWeight: FontWeight.bold))
                              ]
                          )
                      )
                  )
              )
            ]
        )
    );
  }
}
