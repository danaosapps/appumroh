import 'dart:async';
import 'dart:convert';
import 'package:appumroh/broadcasts.dart';
import 'package:appumroh/create_broadcast.dart';
import 'package:appumroh/forgot_password.dart';
import 'package:appumroh/homemenus/rundown_acara.dart';
import 'package:appumroh/main_menu.dart';
import 'package:appumroh/main_tab.dart';
import 'package:appumroh/panduan_umroh.dart';
import 'package:appumroh/panduanumrohtabs/panduan_haji.dart';
import 'package:appumroh/reset_password.dart';
import 'package:appumroh/test.dart';
import 'package:appumroh/verify_email.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'activitygrouptabs/chat.dart';
import 'bottom_bar.dart';
import 'global.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(Home(null, null));
}

class Home extends StatefulWidget {
  final context, string;
  Home(this.context, this.string);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
  var selectedIndex = 1;
  var selectedBottomIndex = 0;
  static var selectedGroupIndex = 0;
  GlobalKey<ExpandableBottomSheetState> key = new GlobalKey();
  int _contentAmount = 0;
  ExpansionStatus _expansionStatus = ExpansionStatus.contracted;
  var queryController = TextEditingController(text: "");
  static late GoogleMapController mapController;
  final mapCompleter = Completer<GoogleMapController>();
  static var groups = [];
  var ad = BannerAd(
    adUnitId: Global.BANNER_AD_ID,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  var menuShown = false;
  static Map<MarkerId, RippleMarker> markers = <MarkerId, RippleMarker>{};
  static Map<CircleId, Circle> circles = <CircleId, Circle>{};
  static var markerUserIDs = [];
  static Map<MarkerId, RippleMarker> highlightedMarkers = <MarkerId, RippleMarker>{};
  bool clicked = false;
  static bool broadcastMessageDismissed = true;
  bool nearBusRadiusMessageDismissed = false;
  static String broadcastMessage = "";

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    //await Global.writeString("broadcasts", jsonEncode([]));
    setState(() {
      Global.homeSetState = setState;
    });
    await Global.initFCMListener(context, widget.string);
    setState(() {
      Global.CURRENT_SCREEN = "home";
    });
    Global.updateFCMToken(widget.string);
    //Global.navigate(context, Test());
    ad.load();
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location
    ].request();
    Timer.periodic(new Duration(seconds: 10), (timer) async {
      var position = await Global.getCurrentPosition();
      Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_location"),
          body: <String, String>{
            "user_id": Global.USER_ID.toString(),
            "lat": position.latitude.toString(),
            "lng": position.longitude.toString()
          }, onSuccess: (response) {
          });
    });
    initGroups(widget.string);
  }

  static void initGroups(string) async {
    if (groups == null) {
      if (Global.homeSetState != null) {
        Global.homeSetState(() {
          groups = [];
        });
      }
    }
    if (Global.homeSetState != null) {
      Global.homeSetState(() {
        markers.clear();
        circles.clear();
        print("Line127 groups is null? "+(groups==null).toString());
        if (groups == null) {
          groups = [];
        }
        groups.clear();
        groups.add({
          "title": string.text85
        });
      });
    }
    if (Global.USER_ID != 0) {
      var _groups = jsonDecode(await getGroups(string));
      print("ALL GROUPS:");
      print(_groups);
      if (Global.homeSetState != null) {
        Global.homeSetState(() {
          groups = _groups;
        });
      }
      print("Line146 groups is null? "+(groups==null).toString());
      for (var group in groups) {
        print("GROUP:");
        print(group);
      }
      print("Line151 groups is null? "+(groups==null).toString());
      if (groups != null && groups.length == 0) {
        groups.add({
          "title": string.text85
        });
      } else {
        groups.add({
          "title": string.text91
        });
      }
      refreshMarkers(string);
    }
  }

  bool isGroupAdmin(member) {
    print("isGroupAdmin member:");
    print(member);
    if (int.parse(member['id'].toString()) == Global.USER_ID) {
      return true;
    }
    return false;
  }

  Widget getHomeWidget(width, height) {
    if (selectedIndex == 0) {
      return Container();
    } else if (selectedIndex == 1) {
      if (kIsWeb) {
        return Container(
                width: width,
                margin: EdgeInsets.only(bottom: 50),
                padding: EdgeInsets.only(left: 30, right: 30),
                color: Color(0xff2c3e50),
                child: Center(
                    child: Text(widget.string.text14, style: TextStyle(
                        color: Colors.white
                    ), textAlign: TextAlign.center)
                )
            );
      } else {
        return Container(
                width: width,
                margin: EdgeInsets.only(bottom: 50),
                child: Stack(
                    children: [
                      Animarker(
                          curve: Curves.ease,
                          rippleRadius: 0.05,
                          mapId: mapCompleter.future.then<int>((value) => value.mapId),
                          markers: highlightedMarkers.values.toSet(),
                          child: GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(Global.CURRENT_LATITUDE, Global.CURRENT_LONGITUDE),
                                zoom: 14.4746,
                              ),
                              onMapCreated: (gController) async {
                                mapCompleter.complete(gController);
                                setState(() {
                                  mapController = gController;
                                });
                                var position = await Global.getCurrentPosition();
                                mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                                    target: LatLng(position.latitude, position.longitude),
                                    zoom: 19.151926040649414)));
                                setState(() {
                                  Global.CURRENT_LATITUDE = position.latitude;
                                  Global.CURRENT_LONGITUDE = position.longitude;
                                });
                                Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/update_location"),
                                    body: <String, String>{
                                      "user_id": Global.USER_ID.toString(),
                                      "lat": position.latitude.toString(),
                                      "lng": position.longitude.toString()
                                    }, onSuccess: (response) {
                                    });
                              },
                              markers: markers.values.toSet(),
                              circles: circles.values.toSet()
                          )
                      ),
                      /*Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      alignment: Alignment.center,
                      child: AdWidget(ad: ad),
                      width: ad.size.width.toDouble(),
                      height: ad.size.height.toDouble(),
                    )
                  )*/
                    ]
                )
            );
      }
    } else if (selectedIndex == 2) {
      return Container();
    }
    return Container();
  }

  static void highlightMarker(string, userID, lat, lng) async {
    print("HIGHLIGHTING USER ID:");
    print(userID);
    for (var markerUserID in markerUserIDs) {
      for (MarkerId markerID in markers.keys) {
        if (markerID.value == markerUserID['marker_id'].toString()) {
          var newMarkerID = MarkerId(Global.generateUUID());
          var icon = await Global.getMarkerIcon(groups[selectedGroupIndex], userID);
          if (Global.homeSetState != null) {
            Global.homeSetState(() {
              highlightedMarkers[newMarkerID] = RippleMarker(
                  markerId: newMarkerID,
                  icon: icon,
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(title: string.text205, snippet: string.text217, onTap: () async {
                    await launch("https://www.google.com/maps/dir/?api=1&origin="+Global.CURRENT_LATITUDE.toString()+","+Global.CURRENT_LONGITUDE.toString()+"&destination="+lat.toString()+","+lng.toString());
                  }),
                  ripple: true
              );
              mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 19.151926040649414)));
            });
          }
          break;
        }
      }
    }
    /*var markerID = MarkerId(Global.generateUUID());
    var icon = await Global.getMarkerIcon(groups[selectedGroupIndex], userID);
    final RippleMarker marker = RippleMarker(
        markerId: markerID,
        icon: icon,
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: string.text205, snippet: '*'),
        ripple: true
    );
    if (Global.homeSetState != null) {
      Global.homeSetState(() {
        highlightedMarkers[markerID] = marker;
      });
    }
    print("ALL HIGHLIGHTED MARKERS:");
    print(highlightedMarkers);*/
  }

  static void showBroadcastMessage(message) {
    if (Global.homeSetState != null) {
      Global.homeSetState(() {
        broadcastMessageDismissed = false;
        broadcastMessage = message;
      });
    }
  }

  static void refreshMarkers(string) async {
    if (groups != null && groups.length <= 0) {
      return;
    }
    var group = groups[selectedGroupIndex];
    var members = group['members'];
    print("GROUP:");
    print(group);
    print("MEMBERS:");
    print(members);
    if (Global.homeSetState != null) {
      Global.homeSetState(() {
        markers.clear();
        circles.clear();
      });
    }
    for (var member in members) {
      final String markerIdVal = Global.generateUUID();
      final MarkerId markerId = MarkerId(markerIdVal);
      /*final Marker marker = Marker(
          markerId: markerId,
          icon: (int.parse(member['id'].toString()) == int.parse(groups[selectedGroupIndex]['user_id'].toString()))?
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange):BitmapDescriptor.defaultMarker,
          position: LatLng(double.parse(member['lat'].toString()), double.parse(member['lng'].toString())),
          infoWindow: InfoWindow(title: markerIdVal, snippet: '*')
      );*/
      var icon = await Global.getMarkerIcon(group, int.parse(member['id'].toString()));
      final RippleMarker marker = RippleMarker(
          markerId: markerId,
          icon: icon,
          /*icon: (int.parse(member['id'].toString()) == int.parse(groups[selectedGroupIndex]['user_id'].toString()))?
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange):BitmapDescriptor.defaultMarker,*/
          position: LatLng(double.parse(member['lat'].toString()), double.parse(member['lng'].toString())),
          infoWindow: InfoWindow(title: string.text205, snippet: string.text217, onTap: () async {
            await launch("https://www.google.com/maps/dir/?api=1&origin="+Global.CURRENT_LATITUDE.toString()+","+Global.CURRENT_LONGITUDE.toString()+"&destination="+member['lat'].toString()+","+member['lng'].toString());
          }),
          ripple: false
      );
      if (groups != null && groups.length > 0 && Global.getGroupMemberRole(groups[selectedGroupIndex], int.parse(member['id'].toString())) == "driver"
          && member['driver_status'].toString()=="parkir") {
        final String driverMarkerIdVal = "bus_marker";
        final MarkerId driverMarkerId = MarkerId(driverMarkerIdVal);
        icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30, 30)), "assets/images/marker_bus.png");
        final RippleMarker marker = RippleMarker(
            markerId: driverMarkerId,
            icon: icon,
            position: LatLng(double.parse(member['parking_lat'].toString()), double.parse(member['parking_lng'].toString())),
            infoWindow: InfoWindow(title: string.text205, snippet: string.text217, onTap: () async {
              await launch("https://www.google.com/maps/dir/?api=1&origin="+Global.CURRENT_LATITUDE.toString()+","+Global.CURRENT_LONGITUDE.toString()+"&destination="+member['parking_lat'].toString()+","+member['parking_lng'].toString());
            }),
            ripple: false
        );
        if (Global.homeSetState != null) {
          Global.homeSetState(() {
            markers[driverMarkerId] = marker;
            markerUserIDs.add({
              "user_id": int.parse(member['id'].toString()),
              "marker_id": driverMarkerIdVal
            });
          });
        }
        String circleIdVal = "bus_circle";
        final CircleId circleId = CircleId(circleIdVal);
        final Circle circle = Circle(
            circleId: circleId,
            consumeTapEvents: true,
            strokeColor: Color(0x7f43925f),
            fillColor: Color(0x4f43925f),
            strokeWidth: 0,
            center: LatLng(double.parse(member['parking_lat'].toString()), double.parse(member['parking_lng'].toString())),
            radius: 25,
            onTap: () {
            }
        );
        if (Global.homeSetState != null) {
          Global.homeSetState(() {
            circles[circleId] = circle;
          });
        }
      }
      if (Global.homeSetState != null) {
        Global.homeSetState(() {
          markers[markerId] = marker;
          markerUserIDs.add({
            "user_id": int.parse(member['id'].toString()),
            "marker_id": markerIdVal
          });
        });
      }
      if (int.parse(member['id'].toString()) == int.parse(groups[selectedGroupIndex]['user_id'].toString())) {
        String circleIdVal = Global.generateUUID();
        final CircleId circleId = CircleId(circleIdVal);
        final Circle circle = Circle(
          circleId: circleId,
          consumeTapEvents: true,
          strokeColor: Color(0x7fe67e22),
          fillColor: Color(0x4fe67e22),
          strokeWidth: 0,
          center: LatLng(double.parse(member['lat'].toString()), double.parse(member['lng'].toString())),
          radius: 50,
          onTap: () {
          },
        );
        if (Global.homeSetState != null) {
          Global.homeSetState(() {
            circles[circleId] = circle;
          });
        }
      }
    }
  }

  static Future<String> getGroups(string) async {
    print("getGroups request url:");
    print(Global.API_URL+"/user/get_groups");
    var response = await Global.httpPostSync(string,
        Uri.parse(Global.API_URL+"/user/get_groups"), body: <String, String>{
          "user_id": Global.USER_ID.toString()
        });
    print("ALL GROUPS:");
    print(response.body);
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(
        width: width,
        child: Stack(
            children: [
              Column(
                  children: [
                    Container(width: width,
                        color: Colors.white,
                        padding: EdgeInsets.only(top: 15, bottom: 0),
                        child: () {
                          List<Widget> groupChildren = [];
                          groupChildren.add(SizedBox(width: 20));
                          if (groups != null) {
                            for (var i=0; i<groups.length; i++) {
                              var group = groups[i];
                              groupChildren.add(SizedBox(width: 0));
                              groupChildren.add(Container(
                                  height: 30,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  decoration: BoxDecoration(
                                      color: selectedGroupIndex==i?Color(0xff2c5034):Colors.transparent,
                                      borderRadius: BorderRadius.circular(30)
                                  ),
                                  child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        if (i == groups.length-1) {
                                          Global.navigate(context, MainMenu(context, widget.string));
                                        } else {
                                          setState(() {
                                            selectedGroupIndex = i;
                                          });
                                          if (Global.homeSetState != null) {
                                            Global.homeSetState(() {
                                              markers.clear();
                                              circles.clear();
                                            });
                                          }
                                          if (i < groups.length-1) {
                                            refreshMarkers(widget.string);
                                          }
                                        }
                                      },
                                      child: Center(
                                          child: Text(group['title'].toString(), style: TextStyle(
                                              color: selectedGroupIndex==i?Colors.white:Color(0xff2c5034), fontSize: 11
                                          ))
                                      )
                                  )
                              ));
                            }
                          }
                          groupChildren.add(SizedBox(width: 20));
                          return Container(
                              width: width-20-20,
                              child: Row(
                                  children: [
                                    Container(
                                        width: width-40-40,
                                        child: FadingEdgeScrollView.fromSingleChildScrollView(
                                            child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                controller: ScrollController(),
                                                child: Row(
                                                    children: groupChildren
                                                )
                                            )
                                        )
                                    ),
                                    Container(
                                        width: 40,
                                        height: 40,
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              Global.navigate(context, MainMenu(context, widget.string));
                                            },
                                            child: Center(
                                                child: Image.asset("assets/images/chat.png", width: 25, height: 25)
                                            )
                                        )
                                    ),
                                    Container(
                                        width: 40,
                                        height: 40,
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              Global.navigate(context, MainMenu(context, widget.string));
                                            },
                                            child: Center(
                                                child: Image.asset("assets/images/contact.png", width: 25, height: 25)
                                            )
                                        )
                                    )
                                  ]
                              )
                          );
                        }()),
                    SizedBox(height: 10),
                    Container(
                        width: 100,
                        height: 3,
                        decoration: BoxDecoration(
                            color: Color(0xff2c5034),
                            borderRadius: BorderRadius.circular(2)
                        )
                    ),
                    SizedBox(height: 10),
                    Expanded(
                        child: Stack(
                            children: [
                              getHomeWidget(width, height),
                              Align(
                                  alignment: Alignment.topCenter,
                                  child: Column(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                      child: Card(
                                                          elevation: 5,
                                                          clipBehavior: Clip.antiAlias,
                                                          shadowColor: Color(0x4C888888),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(20)
                                                          ),
                                                          child: Container(
                                                              height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                                                              color: Colors.white)
                                                          )
                                                      )
                                                  ),
                                                  Card(
                                                      elevation: 5,
                                                      clipBehavior: Clip.antiAlias,
                                                      shadowColor: Color(0x4C888888),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(20)
                                                      ),
                                                      child: Container(
                                                          width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                                                          color: Colors.white),
                                                          child: Material(
                                                              child: new InkWell(
                                                                  onTap: () {
                                                                  },
                                                                  child: Center(
                                                                      child: Icon(Ionicons.navigate, color: Color(0xff3498db), size: 25)
                                                                  ))
                                                          )
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        (() {
                                          if (Global.USER_ID == 0) {
                                            return SizedBox.shrink();
                                          }
                                          if (broadcastMessageDismissed) {
                                            return SizedBox.shrink();
                                          } else {
                                            return Container(
                                                width: width,
                                                color: Color(0xff2c4d2e),
                                                child: Stack(
                                                    children: [
                                                      Padding(padding: EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
                                                          child: Center(child: Text(broadcastMessage, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
                                                      Align(alignment: Alignment.topRight, child: Container(width: 30, height: 30, child: GestureDetector(
                                                          behavior: HitTestBehavior.translucent,
                                                          onTap: () {
                                                            setState(() {
                                                              broadcastMessageDismissed = true;
                                                            });
                                                          },
                                                          child: Center(child: Icon(Ionicons.close, color: Colors.white, size: 20))
                                                      )))
                                                    ]
                                                )
                                            );
                                          }
                                        }()),
                                        (() {
                                          if (Global.USER_ID == 0 || (groups != null && groups.length <= 0)) {
                                            return SizedBox.shrink();
                                          }
                                          var member = Global.getGroupMember(groups[selectedGroupIndex], Global.USER_ID);
                                          if (member == null) {
                                            return SizedBox.shrink();
                                          }
                                          print("MEMBER:");
                                          print(member);
                                          print("CURRENT LAT: "+Global.CURRENT_LATITUDE.toString());
                                          print("CURRENT LNG: "+Global.CURRENT_LONGITUDE.toString());
                                          print("PARKING LAT: "+member['parking_lat'].toString());
                                          print("PARKING LNG: "+member['parking_lng'].toString());
                                          var northEast = Global.getNorthEastLatLng(LatLng(double.parse(member['parking_lat'].toString()), double.parse(member['parking_lng'].toString())));
                                          print("NORTH EAST: "+northEast.latitude.toString()+","+northEast.longitude.toString());
                                          var southWest = Global.getSouthWestLatLng(LatLng(double.parse(member['parking_lat'].toString()), double.parse(member['parking_lng'].toString())));
                                          print("SOUTH WEST: "+southWest.latitude.toString()+","+southWest.longitude.toString());
                                          if ((groups != null && groups.length > 0) && Global.getGroupMemberRole(groups[selectedGroupIndex], Global.USER_ID) == "driver"
                                              && Global.USER_INFO['driver_status'].toString().trim()=="berjalan"
                                              && Global.isInRadius(northEast, southWest, new LatLng(Global.CURRENT_LATITUDE, Global.CURRENT_LONGITUDE))
                                              && !nearBusRadiusMessageDismissed) {
                                            return Container(
                                                width: width,
                                                color: Color(0xff2c4d2e),
                                                child: Stack(
                                                    children: [
                                                      Padding(padding: EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
                                                          child: Center(child: Text(widget.string.text213, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
                                                      Align(alignment: Alignment.topRight, child: Container(width: 30, height: 30, child: GestureDetector(
                                                          behavior: HitTestBehavior.translucent,
                                                          onTap: () {
                                                            setState(() {
                                                              nearBusRadiusMessageDismissed = true;
                                                            });
                                                          },
                                                          child: Center(child: Icon(Ionicons.close, color: Colors.white, size: 20))
                                                      )))
                                                    ]
                                                )
                                            );
                                          }
                                          return SizedBox.shrink();
                                        }())
                                      ]
                                  )
                              )
                            ]
                        ))
                  ]
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (() {
                          if (Global.USER_ID == 0 || (groups != null && groups.length <= 0)) {
                            return SizedBox.shrink();
                          }
                          if (Global.getGroupMemberRole(groups[selectedGroupIndex], Global.USER_ID) == "driver") {
                            return Container(width: 170, height: 40, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  var driverStatus = Global.USER_INFO['driver_status'].toString().trim();
                                  if (driverStatus == "berjalan") {
                                    setState(() {
                                      Global.USER_INFO['driver_status'] = "parkir";
                                    });
                                    var newMarkerID = MarkerId(Global.generateUUID());
                                    var icon = await Global.getMarkerIcon(groups[selectedGroupIndex], Global.USER_ID);
                                    if (Global.homeSetState != null) {
                                      Global.homeSetState(() {
                                        markers[newMarkerID] = RippleMarker(
                                            markerId: newMarkerID,
                                            icon: icon,
                                            position: LatLng(Global.CURRENT_LATITUDE, Global.CURRENT_LONGITUDE),
                                            infoWindow: InfoWindow(title: widget.string.text212, snippet: widget.string.text217, onTap: () async {
                                              Global.show("InfoWindow clicked");
                                              //await launch("https://www.google.com/maps/dir/?api=1&origin="+Global.CURRENT_LATITUDE.toString()+","+Global.CURRENT_LONGITUDE.toString()+"&destination="+lat.toString()+","+lng.toString());
                                            }),
                                            ripple: true
                                        );
                                        String circleIdVal = Global.generateUUID();
                                        final CircleId circleId = CircleId(circleIdVal);
                                        final Circle circle = Circle(
                                          circleId: circleId,
                                          consumeTapEvents: true,
                                          strokeColor: Color(0x7fe67e22),
                                          fillColor: Color(0x4fe67e22),
                                          strokeWidth: 0,
                                          center: LatLng(Global.CURRENT_LATITUDE, Global.CURRENT_LONGITUDE),
                                          radius: 50,
                                          onTap: () {
                                          },
                                        );
                                        setState(() {
                                          circles[circleId] = circle;
                                        });
                                      });
                                    }
                                    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/park_driver"),
                                        body: <String, String>{
                                          "user_id": Global.USER_ID.toString(),
                                          "lat": Global.CURRENT_LATITUDE.toString(),
                                          "lng": Global.CURRENT_LONGITUDE.toString()
                                        }, onSuccess: (response) {
                                        });
                                  } else {
                                    if (Global.homeSetState != null) {
                                      Global.homeSetState(() {
                                        Global.USER_INFO['driver_status'] = "berjalan";
                                        for (var marker in markers.values.toSet()) {
                                          if (marker.markerId.value == "bus_marker") {
                                            markers.remove(marker.markerId);
                                            break;
                                          }
                                        }
                                        for (var circle in circles.values.toSet()) {
                                          if (circle.circleId.value == "bus_circle") {
                                            circles.remove(circle.circleId);
                                            break;
                                          }
                                        }
                                      });
                                    }
                                    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/unpark"),
                                        body: <String, String>{
                                          "user_id": Global.USER_ID.toString()
                                        }, onSuccess: (response) {
                                        });
                                  }
                                },
                                child: Center(child: (() {
                                  var driverStatus = Global.USER_INFO['driver_status'].toString().trim();
                                  return Text(driverStatus=="berjalan"?widget.string.text210:widget.string.text211, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
                                }()))
                            ));
                          } else {
                            return SizedBox.shrink();
                          }
                        }()),
                        (() {
                          if (Global.USER_ID == 0 || (groups != null && groups.length <= 0)) {
                            return SizedBox.shrink();
                          }
                          if (Global.getGroupMemberRole(groups[selectedGroupIndex], Global.USER_ID) == "driver") {
                            return SizedBox(height: 5);
                          } else {
                            return SizedBox.shrink();
                          }
                        }()),
                        Container(
                            width: width,
                            height: 170,
                            child: Stack(
                                children: [
                                  Container(
                                      width: width,
                                      margin: EdgeInsets.only(bottom: 50),
                                      child: Center(
                                          child: Padding(
                                              padding: EdgeInsets.only(left: 10, right: 10),
                                              child: Stack(
                                                  children: [
                                                    Padding(
                                                        padding: EdgeInsets.only(top: 10),
                                                        child: Card(
                                                            elevation: 5,
                                                            margin: EdgeInsets.zero,
                                                            clipBehavior: Clip.antiAlias,
                                                            shadowColor: Color(0xCC888888),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(10),
                                                                    topRight: Radius.circular(10),
                                                                    bottomLeft: Radius.zero,
                                                                    bottomRight: Radius.zero
                                                                )
                                                            ),
                                                            child: Container(
                                                                height: 120,
                                                                decoration: BoxDecoration(
                                                                    color: Color(0xff4c945c),
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft: Radius.circular(10),
                                                                        topRight: Radius.circular(10),
                                                                        bottomLeft: Radius.zero,
                                                                        bottomRight: Radius.zero
                                                                    )
                                                                ),
                                                                padding: EdgeInsets.only(top: 15),
                                                                child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      SizedBox(width: 5),
                                                                      Container(
                                                                          width: 60,
                                                                          child: GestureDetector(
                                                                              behavior: HitTestBehavior.translucent,
                                                                              onTap: () {
                                                                                Global.navigate(context, RundownAcara(context, widget.string));
                                                                              },
                                                                              child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Card(
                                                                                        elevation: 5,
                                                                                        clipBehavior: Clip.antiAlias,
                                                                                        shadowColor: Color(0xCC888888),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(23)
                                                                                        ),
                                                                                        color: Colors.transparent,
                                                                                        child: Container(
                                                                                            width: 46,
                                                                                            height: 46,
                                                                                            decoration: BoxDecoration(
                                                                                                color: Colors.white,
                                                                                                borderRadius: BorderRadius.circular(23)
                                                                                            ),
                                                                                            child: Center(
                                                                                                child: Image.asset("assets/images/calendar.png", width: 30, height: 30)
                                                                                            )
                                                                                        )
                                                                                    ),
                                                                                    SizedBox(height: 2),
                                                                                    Text(widget.string.text44, style: TextStyle(
                                                                                        color: Colors.white, fontSize: 10
                                                                                    ), textAlign: TextAlign.center)
                                                                                  ]
                                                                              )
                                                                          )
                                                                      ),
                                                                      SizedBox(width: 2),
                                                                      Container(
                                                                          width: 60,
                                                                          child: GestureDetector(
                                                                              behavior: HitTestBehavior.translucent,
                                                                              onTap: () {
                                                                                Global.navigate(context, PanduanUmroh(context, widget.string));
                                                                              },
                                                                              child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Card(
                                                                                        elevation: 5,
                                                                                        clipBehavior: Clip.antiAlias,
                                                                                        shadowColor: Color(0xCC888888),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(23)
                                                                                        ),
                                                                                        color: Colors.transparent,
                                                                                        child: Container(
                                                                                            width: 46,
                                                                                            height: 46,
                                                                                            decoration: BoxDecoration(
                                                                                                color: Colors.white,
                                                                                                borderRadius: BorderRadius.circular(23)
                                                                                            ),
                                                                                            child: Center(
                                                                                                child: Image.asset("assets/images/calendar.png", width: 30, height: 30)
                                                                                            )
                                                                                        )
                                                                                    ),
                                                                                    SizedBox(height: 2),
                                                                                    Text(widget.string.text45, style: TextStyle(
                                                                                        color: Colors.white, fontSize: 10
                                                                                    ), textAlign: TextAlign.center)
                                                                                  ]
                                                                              )
                                                                          )
                                                                      ),
                                                                      SizedBox(width: 2),
                                                                      Container(
                                                                          width: 60,
                                                                          child: GestureDetector(
                                                                              behavior: HitTestBehavior.translucent,
                                                                              onTap: () {
                                                                                Global.navigate(context, MainMenu(context, widget.string));
                                                                              },
                                                                              child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Card(
                                                                                        elevation: 5,
                                                                                        clipBehavior: Clip.antiAlias,
                                                                                        shadowColor: Color(0xCC888888),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(23)
                                                                                        ),
                                                                                        color: Colors.transparent,
                                                                                        child: Container(
                                                                                            width: 46,
                                                                                            height: 46,
                                                                                            decoration: BoxDecoration(
                                                                                                color: Colors.white,
                                                                                                borderRadius: BorderRadius.circular(23)
                                                                                            ),
                                                                                            child: Center(
                                                                                                child: Image.asset("assets/images/calendar.png", width: 30, height: 30)
                                                                                            )
                                                                                        )
                                                                                    ),
                                                                                    SizedBox(height: 2),
                                                                                    Text(widget.string.text46, style: TextStyle(
                                                                                        color: Colors.white, fontSize: 10
                                                                                    ), textAlign: TextAlign.center)
                                                                                  ]
                                                                              )
                                                                          )
                                                                      ),
                                                                      SizedBox(width: 2),
                                                                      Container(
                                                                          width: 60,
                                                                          child: GestureDetector(
                                                                              behavior: HitTestBehavior.translucent,
                                                                              onTap: () {
                                                                                Global.navigate(context, Broadcasts(context, widget.string, groups[selectedGroupIndex]));
                                                                              },
                                                                              child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Card(
                                                                                        elevation: 5,
                                                                                        clipBehavior: Clip.antiAlias,
                                                                                        shadowColor: Color(0xCC888888),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(23)
                                                                                        ),
                                                                                        color: Colors.transparent,
                                                                                        child: Container(
                                                                                            width: 46,
                                                                                            height: 46,
                                                                                            decoration: BoxDecoration(
                                                                                                color: Colors.white,
                                                                                                borderRadius: BorderRadius.circular(23)
                                                                                            ),
                                                                                            child: Center(
                                                                                                child: Image.asset("assets/images/calendar.png", width: 30, height: 30)
                                                                                            )
                                                                                        )
                                                                                    ),
                                                                                    SizedBox(height: 2),
                                                                                    Text(widget.string.text47, style: TextStyle(
                                                                                        color: Colors.white, fontSize: 10
                                                                                    ), textAlign: TextAlign.center)
                                                                                  ]
                                                                              )
                                                                          )
                                                                      ),
                                                                      SizedBox(width: 5),
                                                                      Padding(
                                                                          padding: EdgeInsets.only(top: 30, bottom: 8),
                                                                          child: Container(
                                                                              width: 1,
                                                                              decoration: BoxDecoration(
                                                                                  color: Color(0xff438550),
                                                                                  borderRadius: BorderRadius.circular(1)
                                                                              )
                                                                          )
                                                                      )
                                                                    ]
                                                                )
                                                            )
                                                        )
                                                    ),
                                                    Align(
                                                        alignment: Alignment.topRight,
                                                        child: Column(
                                                            children: [
                                                              Card(
                                                                  elevation: 5,
                                                                  margin: EdgeInsets.only(right: 10),
                                                                  clipBehavior: Clip.antiAlias,
                                                                  shadowColor: Color(0xCC888888),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(30)
                                                                  ),
                                                                  color: Colors.transparent,
                                                                  child: GestureDetector(
                                                                      behavior: HitTestBehavior.translucent,
                                                                      onTap: () {
                                                                        Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/notify_group"),
                                                                            body: <String, String>{
                                                                              "group_id": groups[selectedGroupIndex]['id'].toString(),
                                                                              "user_id": Global.USER_INFO['id'].toString()
                                                                            }, onSuccess: (response) {
                                                                              print("notify_group response:");
                                                                              print(response);
                                                                            });
                                                                      },
                                                                      child: Container(
                                                                          width: 60,
                                                                          height: 60,
                                                                          decoration: BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                  begin: Alignment.topLeft,
                                                                                  end: Alignment.bottomRight,
                                                                                  colors: <Color>[
                                                                                    Color(0xffe0383e),
                                                                                    Color(0xff6c2f2a)
                                                                                  ]
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(30)
                                                                          ),
                                                                          child: Center(
                                                                              child: Text(widget.string.panic, style: TextStyle(
                                                                                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold
                                                                              ), textAlign: TextAlign.center)
                                                                          )
                                                                      )
                                                                  )
                                                              ),
                                                              SizedBox(height: 8),
                                                              Container(
                                                                  width: 40,
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(20)
                                                                  ),
                                                                  child: GestureDetector(
                                                                      behavior: HitTestBehavior.translucent,
                                                                      onTap: () {
                                                                        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                                                                            target: LatLng(Global.CURRENT_LATITUDE, Global.CURRENT_LONGITUDE),
                                                                            zoom: 19.151926040649414)));
                                                                      },
                                                                      child: Card(
                                                                          elevation: 5,
                                                                          margin: EdgeInsets.zero,
                                                                          clipBehavior: Clip.antiAlias,
                                                                          shadowColor: Color(0xCC888888),
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(20)
                                                                          ),
                                                                          child: Center(
                                                                              child: Image.asset("assets/images/locate.png", width: 35, height: 35)
                                                                          )
                                                                      )
                                                                  )
                                                              )
                                                            ]
                                                        )
                                                    )
                                                  ]
                                              )
                                          )
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
                  )
              )
            ]
        )
    )));
  }
}
