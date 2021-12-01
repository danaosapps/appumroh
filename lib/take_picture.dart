import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TakePicture(null, null));
}

class TakePicture extends StatefulWidget {
  final context, string;
  TakePicture(this.context, this.string);

  @override
  TakePictureState createState() => TakePictureState();
}

class TakePictureState extends State<TakePicture> with WidgetsBindingObserver {
  CameraController? cameraController = null;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown
    ]);
    cameraController!.dispose();
    super.dispose();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "take_picture";
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    var _cameras = await availableCameras();
    setState(() {
      cameras = _cameras;
    });
    print("ALL CAMERAS:");
    print(cameras);
    if (cameras.length > 0) {
      CameraController _cameraController = CameraController(cameras[0], ResolutionPreset.max, enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg);
      setState(() {
        cameraController = _cameraController;
      });
      cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  void _handleScaleStart() {
  }

  void _handleScaleUpdate() {
  }

  void onViewFinderTap(details, constraints) {
  }

  Future<XFile?> takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return null;
    }
    if (cameraController!.value.isTakingPicture) {
      return null;
    }
    try {
      XFile file = await cameraController!.takePicture();
      return file;
    } on CameraException catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(width: width, height: height, child: Stack(
      children: [
        Container(width: width, height: height, color: Colors.black, child: () {
          if (!(cameraController!.value.isInitialized)) {
            return SizedBox.shrink();
          } else {
            return Center(child: CameraPreview(cameraController!));
          }
        }()),
        Padding(
            padding: EdgeInsets.only(right: 40, left: 40, top: 20, bottom: 20),
            child: Image.asset("assets/images/identity_card_transparent.png", width: width-40-40, height: height-20-20)
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(width: 70, height: 70, decoration: BoxDecoration(borderRadius: BorderRadius.circular(35),
            border: Border.all(width: 3, color: Colors.white)), margin: EdgeInsets.only(right: 10),
              child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              var selectedPicture = await takePicture();
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    backgroundColor: Colors.transparent,
                      content: Center(
                        child: Container(
                            height: 150,
                            decoration: BoxDecoration(color: Global.MAIN_COLOR, borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(widget.string.text119, style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center),
                                  SizedBox(height: 20),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(height: 45, padding: EdgeInsets.only(left: 30, right: 30),
                                            decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(30)),
                                            child: GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Center(child: Text(widget.string.repeat, style: TextStyle(color: Colors.white, fontSize: 15)))
                                            )),
                                        SizedBox(width: 20),
                                        Container(height: 45, padding: EdgeInsets.only(left: 30, right: 30),
                                            decoration: BoxDecoration(color: Global.SECONDARY_COLOR, borderRadius: BorderRadius.circular(30)),
                                            child: GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(context, {
                                                    "file": selectedPicture
                                                  });
                                                },
                                                child: Center(child: Text(widget.string.upload, style: TextStyle(color: Colors.white, fontSize: 15)))
                                            ))
                                      ]
                                  )
                                ]
                            )
                        )
                      )
                  );
                },
              );
            },
            child: Center(child: Icon(Ionicons.camera, color: Colors.white, size: 40))
          ))
        )
      ]
    ))));
  }
}
