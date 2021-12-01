import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'global.dart';

void main() {
  runApp(ViewImage(null, null, null));
}

class ViewImage extends StatefulWidget {
  final context, string, imgURL;
  ViewImage(this.context, this.string, this.imgURL);

  @override
  ViewImageState createState() => ViewImageState();
}

class ViewImageState extends State<ViewImage> with WidgetsBindingObserver {
  var imgURL = null;

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
    super.dispose();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "view_image";
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    setState(() {
      imgURL = widget.imgURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(color: Colors.black, width: width, height: height,
        child: (() {
          if (imgURL == null) {
            return SizedBox.shrink();
          } else {
            return Image.network(imgURL, width: width, height: height, fit: BoxFit.fill);
          }
        }()))));
  }
}
