import 'package:appumroh/outgoing_video_call.dart';
import 'package:appumroh/outgoing_voice_call.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(SelectLocation(null, null));
}

class SelectLocation extends StatefulWidget {
  final context, string;
  SelectLocation(this.context, this.string);

  @override
  SelectLocationState createState() => SelectLocationState();
}

class SelectLocationState extends State<SelectLocation> with WidgetsBindingObserver {
  var mapController;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  var latestMarkerID = null;
  var latestMarker = null;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
  }

  void goBack(context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 65),
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(Global.CURRENT_LATITUDE, Global.CURRENT_LONGITUDE),
              zoom: 14.4746
            ),
            markers: markers.values.toSet(),
            onTap: (LatLng position) async {
              setState(() {
                var newMarkerID = MarkerId(Global.generateUUID());
                if (latestMarkerID != null) {
                  markers.remove(latestMarkerID);
                }
                Marker marker = Marker(
                    markerId: newMarkerID,
                    icon: BitmapDescriptor.defaultMarker,
                    position: position
                );
                latestMarker = marker;
                latestMarkerID = newMarkerID;
                markers[newMarkerID] = marker;
              });
            },
            onMapCreated: (gController) {
              setState(() {
                mapController = gController;
              });
            }
          )
        ),
        Align(
            alignment: Alignment.topCenter,
            child: Card(
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                shadowColor: Color(0x4C888888),
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0)
                ),
                child: Container(
                    width: width,
                    child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(width: 45, height: 45, child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  goBack(context);
                                },
                                child: Center(child: Icon(Ionicons.arrow_back_outline,
                                    color: Global.SECONDARY_COLOR, size: 20))
                              )),
                              Text(widget.string.text267, style: TextStyle(color: Colors.black, fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                              Container(width: 45, height: 45, child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Navigator.pop(context, latestMarker);
                                  },
                                  child: Center(child: Icon(Ionicons.checkmark,
                                      color: Global.MAIN_COLOR, size: 23))
                              ))
                            ]
                        )
                    )
                )
            )
        )
      ]
    )));
  }
}
