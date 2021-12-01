import 'dart:convert';
import 'dart:io';
import 'package:appumroh/take_picture.dart';
import 'package:appumroh/view_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(Biography(null, null));
}

class Biography extends StatefulWidget {
  final context, string;
  Biography(this.context, this.string);

  @override
  BiographyState createState() => BiographyState();
}

class BiographyState extends State<Biography> with WidgetsBindingObserver {
  var golDarah = 'A';
  var penyakitKhususController = TextEditingController(text: "");
  var obatController = TextEditingController(text: "");
  var alergiController = TextEditingController(text: "");
  final ImagePicker imagePicker = ImagePicker();
  XFile? selectedKTPImage = null;
  XFile? selectedPassportImage = null;
  XFile? selectedVaccinationCertificateImage = null;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "biography";
    });
    print("KTP IMAGE:");
    print(Global.USER_INFO['ktp_image']);
    setState(() {
      golDarah = Global.USER_INFO['gol_darah'].toString();
      penyakitKhususController.text = Global.USER_INFO['penyakit_khusus'].toString();
      obatController.text = Global.USER_INFO['obat_khusus'].toString();
      alergiController.text = Global.USER_INFO['alergi'].toString();
    });
  }

  void selectImage(type, width, height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Country List'),
            content: Container(
              width: width-10-10,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return ListTile(title: Text(widget.string.text117), onTap: () async {
                      Navigator.pop(context);
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.camera,
                      ].request();
                      var obj = await Global.navigateAndWait(context, TakePicture(context, widget.string));
                      var file = obj["file"];
                      setState(() {
                        if (type == "ktp") {
                          selectedKTPImage = file;
                        } else if (type == "passport") {
                          selectedPassportImage = file;
                        } else if (type == "vaccination_certificate") {
                          selectedVaccinationCertificateImage = file;
                        }
                      });
                    });
                  }
                  return ListTile(title: Text(widget.string.text118), onTap: () async {
                    Navigator.pop(context);
                    Map<Permission, PermissionStatus> statuses = await [
                      Permission.storage
                    ].request();
                    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
                    setState(() {
                      selectedKTPImage = image;
                    });
                  });
                },
              ),
            )
          );
        });
  }

  void save() async {
    var penyakitKhusus = penyakitKhususController.text.trim();
    var obatKhusus = obatController.text.trim();
    var alergiKhusus = alergiController.text.trim();
    await Global.showProgressDialog(context, widget.string.text121);
    try {
      var request = new http.MultipartRequest("POST", Uri.parse(Global.API_URL + "/user/update_biography"));
      request.fields['user_id'] = Global.USER_ID.toString();
      request.fields['ktp_image_changed'] = selectedKTPImage==null?"0":"1";
      request.fields['passport_image_changed'] = selectedPassportImage==null?"0":"1";
      request.fields['vaccination_certificate_image_changed'] = selectedVaccinationCertificateImage==null?"0":"1";
      request.fields['penyakit_khusus'] = penyakitKhusus;
      request.fields['obat_khusus'] = obatKhusus;
      request.fields['alergi'] = alergiKhusus;
      request.fields['gol_darah'] = golDarah;
      if (selectedKTPImage != null) {
        request.files.add(await http.MultipartFile('ktp_image',
            File(selectedKTPImage!.path).readAsBytes().asStream(),
            File(selectedKTPImage!.path).lengthSync(), filename: Uuid().v1()));
      }
      if (selectedPassportImage != null) {
        request.files.add(await http.MultipartFile('passport_image',
            File(selectedPassportImage!.path).readAsBytes().asStream(),
            File(selectedPassportImage!.path).lengthSync(), filename: Uuid().v1()));
      }
      if (selectedVaccinationCertificateImage != null) {
        request.files.add(await http.MultipartFile('vaccination_certificate_image',
            File(selectedVaccinationCertificateImage!.path).readAsBytes().asStream(),
            File(selectedVaccinationCertificateImage!.path).lengthSync(), filename: Uuid().v1()));
      }
      request.send().then((responseStream) async {
        var response = await responseStream.stream.bytesToString();
        setState(() {
          Global.USER_INFO = jsonDecode(response);
        });
        print("update_biography response: "+response);
        await Global.hideProgressDialog(context);
        Global.show(widget.string.text120);
        Navigator.pop(context, true);
      });
    } catch (e) {
    print(e);
    }
  }

  bool shouldShowCameraIconInCenter(type) {
    if (type == "ktp") {
      if (Global.USER_INFO['ktp_image'] == null
          || Global.USER_INFO['ktp_image'].toString().trim() == "null"
          || Global.USER_INFO['ktp_image'].toString().trim() == "") {
        return true;
      } else {
        return false;
      }
    } else if (type == "passport") {
      if (Global.USER_INFO['passport_image'] == null
          || Global.USER_INFO['passport_image'].toString().trim() == "null"
          || Global.USER_INFO['passport_image'].toString().trim() == "") {
        return true;
      } else {
        return false;
      }
    } else if (type == "vaccination_certificate") {
      if (Global.USER_INFO['vaccination_certificate_image'] == null
          || Global.USER_INFO['vaccination_certificate_image'].toString().trim() == "null"
          || Global.USER_INFO['vaccination_certificate_image'].toString().trim() == "") {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: width, height: 45, color: Global.SECONDARY_COLOR, child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(width: 45, height: 45, child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                        child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                    )
                )),
                Text(widget.string.text103, style: TextStyle(color: Colors.white, fontSize: 17)),
                Container(width: 45, height: 45)
              ]
          )),
          Expanded(
            child: SingleChildScrollView(
                child: Column(
                    children: [
                      SizedBox(height: 5),
                      Text(widget.string.text106, style: TextStyle(color: Colors.black, fontSize: 15)),
                      SizedBox(height: 5),
                      Container(width: width, height: 230, child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (Global.USER_INFO['ktp_image'] == null
                                || Global.USER_INFO['ktp_image'].toString().trim() == "null"
                                || Global.USER_INFO['ktp_image'].toString().trim() == "") {
                              selectImage("ktp", width, height);
                            } else {
                              Global.navigate(context, ViewImage(context, widget.string, Global.USERDATA_URL+Global.USER_INFO['ktp_image'].toString().trim()));
                            }
                          },
                          child: Stack(
                              children: [
                                Center(child: Padding(padding: EdgeInsets.only(left: 20, right: 20),
                                    child: (() {
                                      if (Global.USER_INFO['ktp_image'] == null
                                          || Global.USER_INFO['ktp_image'].toString().trim() == "null"
                                          || Global.USER_INFO['ktp_image'].toString().trim() == "") {
                                        return Image.asset("assets/images/identity_card.png", width: width-20-20, height: 230, fit: BoxFit.fill);
                                      } else {
                                        if (selectedKTPImage == null) {
                                          return Image.network(
                                              Global.USERDATA_URL +
                                                  Global.USER_INFO['ktp_image']
                                                      .toString()
                                                      .trim(),
                                              width: width - 20 - 20,
                                              height: 230,
                                              fit: BoxFit.fill);
                                        } else {
                                          return Image.file(
                                              new File(selectedKTPImage!.path),
                                              width: width - 20 - 20,
                                              height: 230,
                                              fit: BoxFit.fill);
                                        }
                                      }
                                    }()))),
                                (() {
                                  if (shouldShowCameraIconInCenter("ktp")) {
                                    return Center(child: Container(width: 70, height: 70, decoration: BoxDecoration(
                                        border: Border.all(width: 3, color: selectedKTPImage==null?Colors.black:Colors.white), borderRadius: BorderRadius.circular(35)),
                                        child: Center(child: Icon(Ionicons.camera, color: selectedKTPImage==null?Colors.black:Colors.white, size: 50))));
                                  } else {
                                    return Align(
                                        alignment: Alignment.bottomRight,
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              selectImage("ktp", width, height);
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.only(right: 30, bottom: 10),
                                                child: Container(width: 40, height: 40, decoration: BoxDecoration(
                                                    border: Border.all(width: 2, color: shouldShowCameraIconInCenter("ktp")?Colors.black:Colors.white), borderRadius: BorderRadius.circular(35)),
                                                    child: Center(child: Icon(Ionicons.camera, color: shouldShowCameraIconInCenter("ktp")?Colors.black:Colors.white, size: 20)))
                                            )
                                        )
                                    );
                                  }
                                }())
                              ]
                          )
                      )),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: width/2, child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  if (Global.USER_INFO['passport_image'] == null
                                      || Global.USER_INFO['passport_image'].toString().trim() == "null"
                                      || Global.USER_INFO['passport_image'].toString().trim() == "") {
                                    selectImage("passport", width, height);
                                  } else {
                                    Global.navigate(context, ViewImage(context, widget.string, Global.USERDATA_URL+Global.USER_INFO['passport_image'].toString().trim()));
                                  }
                                },
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(widget.string.text107, style: TextStyle(color: Colors.black, fontSize: 13)),
                                      SizedBox(height: 5),
                                      Container(width: width/2, height: 110, child: Stack(
                                          children: [
                                            Center(child: Padding(padding: EdgeInsets.only(left: 20, right: 10),
                                                child: (() {
                                                  if (Global.USER_INFO['passport_image'] == null
                                                      || Global.USER_INFO['passport_image'].toString().trim() == "null"
                                                      || Global.USER_INFO['passport_image'].toString().trim() == "") {
                                                    return Image.asset("assets/images/identity_card.png", width: width-20-20, height: 230, fit: BoxFit.fill);
                                                  } else {
                                                    if (selectedPassportImage == null) {
                                                      return Image.network(
                                                          Global.USERDATA_URL +
                                                              Global.USER_INFO['passport_image']
                                                                  .toString()
                                                                  .trim(),
                                                          width: width - 20 - 20,
                                                          height: 230,
                                                          fit: BoxFit.fill);
                                                    } else {
                                                      return Image.file(
                                                          new File(selectedPassportImage!.path),
                                                          width: width - 20 - 20,
                                                          height: 230,
                                                          fit: BoxFit.fill);
                                                    }
                                                  }
                                                }()))),
                                            (() {
                                              if (shouldShowCameraIconInCenter("passport")) {
                                                return Center(child: Container(width: 50, height: 50, decoration: BoxDecoration(
                                                    border: Border.all(width: 3, color: selectedPassportImage==null?Colors.black:Colors.white), borderRadius: BorderRadius.circular(35)),
                                                    child: Center(child: Icon(Ionicons.camera, color: selectedPassportImage==null?Colors.black:Colors.white, size: 30))));
                                              } else {
                                                return Align(
                                                    alignment: Alignment.bottomRight,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior.translucent,
                                                      onTap: () {
                                                        selectImage("passport", width, height);
                                                      },
                                                      child: Padding(
                                                          padding: EdgeInsets.only(right: 30, bottom: 10),
                                                          child: Container(width: 40, height: 40, decoration: BoxDecoration(
                                                              border: Border.all(width: 2, color: shouldShowCameraIconInCenter("passport")?Colors.black:Colors.white), borderRadius: BorderRadius.circular(35)),
                                                              child: Center(child: Icon(Ionicons.camera, color: shouldShowCameraIconInCenter("passport")?Colors.black:Colors.white, size: 20)))
                                                      )
                                                    )
                                                );
                                              }
                                            }())
                                          ]
                                      ))
                                    ]
                                )
                            )),
                            Container(width: width/2, child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  if (Global.USER_INFO['vaccination_certificate_image'] == null
                                      || Global.USER_INFO['vaccination_certificate_image'].toString().trim() == "null"
                                      || Global.USER_INFO['vaccination_certificate_image'].toString().trim() == "") {
                                    selectImage("vaccination_certificate_image", width, height);
                                  } else {
                                    Global.navigate(context, ViewImage(context, widget.string, Global.USERDATA_URL+Global.USER_INFO['vaccination_certificate_image'].toString().trim()));
                                  }
                                },
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 8),
                                      Text(widget.string.text108, style: TextStyle(color: Colors.black, fontSize: 13)),
                                      SizedBox(height: 5),
                                      Container(width: width/2, height: 110, child: Stack(
                                          children: [
                                            Center(child: Padding(padding: EdgeInsets.only(left: 10, right: 20),
                                                child: (() {
                                                  if (Global.USER_INFO['vaccination_certificate_image'] == null
                                                      || Global.USER_INFO['vaccination_certificate_image'].toString().trim() == "null"
                                                      || Global.USER_INFO['vaccination_certificate_image'].toString().trim() == "") {
                                                    return Image.asset("assets/images/identity_card.png", width: width-20-20, height: 230, fit: BoxFit.fill);
                                                  } else {
                                                    if (selectedVaccinationCertificateImage == null) {
                                                      return Image.network(
                                                          Global.USERDATA_URL +
                                                              Global.USER_INFO['vaccination_certificate_image']
                                                                  .toString()
                                                                  .trim(),
                                                          width: width - 20 - 20,
                                                          height: 230,
                                                          fit: BoxFit.fill);
                                                    } else {
                                                      return Image.file(
                                                          new File(selectedVaccinationCertificateImage!.path),
                                                          width: width - 20 - 20,
                                                          height: 230,
                                                          fit: BoxFit.fill);
                                                    }
                                                  }
                                                }()))),
                                            (() {
                                              if (shouldShowCameraIconInCenter("vaccination_certificate")) {
                                                return Center(child: Container(width: 50, height: 50, decoration: BoxDecoration(
                                                    border: Border.all(width: 3, color: selectedVaccinationCertificateImage==null?Colors.black:Colors.white), borderRadius: BorderRadius.circular(35)),
                                                    child: Center(child: Icon(Ionicons.camera, color: selectedVaccinationCertificateImage==null?Colors.black:Colors.white, size: 30))));
                                              } else {
                                                return Align(
                                                    alignment: Alignment.bottomRight,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior.translucent,
                                                      onTap: () {
                                                        selectImage("vaccination_certificate", width, height);
                                                      },
                                                      child: Padding(
                                                          padding: EdgeInsets.only(right: 30, bottom: 10),
                                                          child: Container(width: 40, height: 40, decoration: BoxDecoration(
                                                              border: Border.all(width: 2, color: shouldShowCameraIconInCenter("vaccination_certificate")?Colors.black:Colors.white), borderRadius: BorderRadius.circular(35)),
                                                              child: Center(child: Icon(Ionicons.camera, color: shouldShowCameraIconInCenter("vaccination_certificate")?Colors.black:Colors.white, size: 20)))
                                                      )
                                                    )
                                                );
                                              }
                                            }())
                                          ]
                                      ))
                                    ]
                                )
                            ))
                          ]
                      ),
                      SizedBox(height: 5),
                      Text(widget.string.text109, style: TextStyle(color: Colors.black, fontSize: 16)),
                      SizedBox(height: 5),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.string.text110, style: TextStyle(color: Colors.black, fontSize: 13)),
                            DropdownButton<String>(
                              value: golDarah,
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Global.MAIN_COLOR,
                              ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  golDarah = newValue!;
                                });
                              },
                              items: <String>['A', 'B', 'AB', 'O']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 5),
                            Text(widget.string.text111, style: TextStyle(color: Colors.black, fontSize: 13)),
                            SizedBox(height: 5),
                            Container(width: width-10-10, height: 200, decoration: BoxDecoration(color: Color(0xffeeeeee),
                                borderRadius: BorderRadius.circular(20)),
                                child: TextField(decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text114, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: penyakitKhususController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))),
                            SizedBox(height: 5),
                            Text(widget.string.text112, style: TextStyle(color: Colors.black, fontSize: 13)),
                            SizedBox(height: 5),
                            Container(width: width-10-10, height: 200, decoration: BoxDecoration(color: Color(0xffeeeeee),
                                borderRadius: BorderRadius.circular(20)),
                                child: TextField(decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text115, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: obatController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))),
                            SizedBox(height: 5),
                            Text(widget.string.text113, style: TextStyle(color: Colors.black, fontSize: 13)),
                            SizedBox(height: 5),
                            Container(width: width-10-10, height: 200, decoration: BoxDecoration(color: Color(0xffeeeeee),
                                borderRadius: BorderRadius.circular(20)),
                                child: TextField(decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text116, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: alergiController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))),
                            SizedBox(height: 10),
                            Container(width: width-10-10, height: 45, decoration: BoxDecoration(color: Global.SECONDARY_COLOR,
                                borderRadius: BorderRadius.circular(8)),
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      save();
                                    },
                                    child: Center(child: Text(widget.string.save, style: TextStyle(color: Colors.white, fontSize: 15)))
                                )),
                            SizedBox(height: 10)
                          ]
                      )
                    ]
                )
            )
          )
        ]
    )));
  }
}
