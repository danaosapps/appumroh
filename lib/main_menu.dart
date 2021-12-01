import 'dart:async';
import 'dart:convert';
import 'package:appumroh/broadcasts.dart';
import 'package:appumroh/create_broadcast.dart';
import 'package:appumroh/forgot_password.dart';
import 'package:appumroh/home.dart';
import 'package:appumroh/homemenus/rundown_acara.dart';
import 'package:appumroh/ibadah.dart';
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
  runApp(MainMenu(null, null));
}

class MainMenu extends StatefulWidget {
  final context, string;
  MainMenu(this.context, this.string);

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> with WidgetsBindingObserver {
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
    //Global.navigate(context, Test(context, widget.string));
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
        return Expanded(
            child: Container(
                width: width,
                margin: EdgeInsets.only(bottom: 50),
                padding: EdgeInsets.only(left: 30, right: 30),
                color: Color(0xff2c3e50),
                child: Center(
                    child: Text(widget.string.text14, style: TextStyle(
                        color: Colors.white
                    ), textAlign: TextAlign.center)
                )
            )
        );
      } else {
        return Expanded(
            child: Container(
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
    var menuWidth = width/3-10-10;
    return Scaffold(backgroundColor: Colors.white, body: SafeArea(child: Container(
        width: width,
        color: Colors.white,
        child: Stack(
            children: [
              SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 50),
                        Padding(padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text(widget.string.text255+(Global.USER_ID==0?"":" "+Global.USER_INFO['name'].toString()),
                                style: TextStyle(color: Color(0xff4b4b4b), fontSize: 20, fontWeight: FontWeight.bold))),
                        SizedBox(height: 5),
                        Padding(padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text(widget.string.text256,
                                style: TextStyle(color: Color(0xff4b4b4b), fontSize: 16))),
                        SizedBox(height: 30),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                            Global.navigate(context, MainTab(context, widget.string, 0));
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Group.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.group, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              )),
                              SizedBox(width: 10),
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                            Global.navigate(context, MainTab(context, widget.string, 1));
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Chat.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.chat, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              )),
                              SizedBox(width: 10),
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                            Global.navigate(context, Ibadah(context, widget.string));
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Ibadah.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.text12, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              ))
                            ]
                        ),
                        SizedBox(width: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                            Global.navigate(context, PanduanUmroh(context, widget.string));
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Umroh & Haji.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.text88, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              )),
                              SizedBox(width: 10),
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Wisata.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.text257, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              )),
                              SizedBox(width: 10),
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Keluarga.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.text89, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              ))
                            ]
                        ),
                        SizedBox(width: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                            Global.navigate(context, MainTab(context, widget.string, 2));
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Kontak.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.contact, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              )),
                              SizedBox(width: 10),
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                            Global.replaceScreen(context, Home(context, widget.string));
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Live Tacking.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.text258, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              )),
                              SizedBox(width: 10),
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Tabunganku.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.text259, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              ))
                            ]
                        ),
                        SizedBox(width: 10),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(width: menuWidth, height: menuWidth, child: Card(
                                  elevation: 5,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Color(0x4C888888),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Material(
                                      child: new InkWell(
                                          onTap: () {
                                          },
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 5),
                                                Image.asset("assets/images/home/Icon Info Travel.png", width: 40, height: 40),
                                                SizedBox(height: 5),
                                                Text(widget.string.text260, style: TextStyle(color: Color(0xff015198), fontSize: 12)),
                                                SizedBox(height: 10)
                                              ]
                                          )
                                      )
                                  )
                              )),
                              SizedBox(width: 10),
                              Container(width: menuWidth, height: menuWidth),
                              SizedBox(width: 10),
                              Container(width: menuWidth, height: menuWidth)
                            ]
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
                      child: BottomBar(context, widget.string, 1, "main_menu")
                  )
              )
            ]
        )
    )));
  }
}
