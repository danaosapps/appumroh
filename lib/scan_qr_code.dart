import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'global.dart';

void main() {
  runApp(ScanQRCode(null, null));
}

class ScanQRCode extends StatefulWidget {
  final context, string;
  ScanQRCode(this.context, this.string);

  @override
  ScanQRCodeState createState() => ScanQRCodeState();
}

class ScanQRCodeState extends State<ScanQRCode> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  var qrWidth = 300.0;
  var qrHeight = 300.0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "scan_qr_code";
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController _controller) {
    setState(() {
      controller = _controller;
    });
    controller!.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      print("RESULT:");
      print(result);
      if (result != null) {
        controller!.pauseCamera();
        print("CODE: "+result!.code!);
        print("FORMAT: "+result!.format.formatName);
        print("RAW BYTES:");
        print(result!.rawBytes);
        await Global.showProgressDialog(context, widget.string.text192);
        Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/join_group"),
            body: <String, String>{
              "unique_id": result!.code!,
              "user_id": Global.USER_ID.toString()
            }, onSuccess: (response) async {
              print("Response:");
              print(response);
              Navigator.pop(context);
              var obj = jsonDecode(response);
              var responseCode = int.parse(obj['response_code'].toString());
              print("Response code:");
              print(responseCode);
              if (responseCode == 1) {
                var groups = obj['groups'];
                print("Groups:");
                print(groups);
                if (groups.length > 0) {
                  var group = groups[0];
                  print("Group:");
                  print(group);
                  print("GROUP FCM KEY:");
                  print(group['user']['fcm_key'].toString());
                  Global.sendFCMMessage(group['user']['fcm_key'].toString(),
                      Global.USER_INFO['name'].toString()+" "+widget.string.text194, widget.string.text195,
                      {
                        "group": group
                      });
                }
                controller!.stopCamera();
                controller!.dispose();
                Global.alertConfirm(context, widget.string, widget.string.information, widget.string.text193, () {
                  Navigator.pop(context, true);
                });
              } else if (responseCode == -1) {
                Global.alertConfirm(context, widget.string, widget.string.information, widget.string.text196, () {
                  controller!.resumeCamera();
                });
              } else if (responseCode == -2) {
                Global.alertConfirm(context, widget.string, widget.string.information, widget.string.text197, () {
                  controller!.resumeCamera();
                });
              }
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Container(
      width: width, height: height,
      child: Stack(
        children: [
          QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated
          ),
          Align(alignment: Alignment.center, child: Container(width: width, height: 1, color: Color(0x7f2ecc71))),
          Align(
              alignment: Alignment.topCenter,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: (width-qrWidth)/2, height: (height-qrHeight)/2, color: Color(0x7f000000)),
                    Container(width: qrWidth, height: (height-qrHeight)/2, color: Color(0x7f000000)),
                    Container(width: (width-qrWidth)/2, height: (height-qrHeight)/2, color: Color(0x7f000000))
                  ]
              )
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: (width-qrWidth)/2, height: (height-qrHeight)/2+20, color: Color(0x7f000000))
                  ]
              )
          ),
          Align(
              alignment: Alignment.centerRight,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: (width-qrWidth)/2, height: (height-qrHeight)/2+20, color: Color(0x7f000000))
                  ]
              )
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: (width-qrWidth)/2, height: (height-qrHeight)/2, color: Color(0x7f000000)),
                    Container(width: qrWidth, height: (height-qrHeight)/2, color: Color(0x7f000000)),
                    Container(width: (width-qrWidth)/2, height: (height-qrHeight)/2, color: Color(0x7f000000))
                  ]
              )
          )
        ]
      )
    )));
  }
}
