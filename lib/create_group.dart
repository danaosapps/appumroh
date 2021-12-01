import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:uuid/uuid.dart';
import 'global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CreateGroup(null, null));
}

class CreateGroup extends StatefulWidget {
  final context, string;
  CreateGroup(this.context, this.string);

  @override
  CreateGroupState createState() => CreateGroupState();
}

class CreateGroupState extends State<CreateGroup> with WidgetsBindingObserver {
  var selectedGroupType = 0;
  var subjectController = TextEditingController(text: "");
  var contacts = [];
  var selectedContactIndex = 0;
  final ImagePicker imagePicker = ImagePicker();
  var selectedImage = null;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "create_group";
    });
    refreshContacts();
  }

  void selectImage() async {
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = image;
    });
  }

  Future<void> refreshContacts() async {
    var _contacts = jsonDecode(await getContacts());
    setState(() {
      contacts = _contacts;
    });
    print("ALL CONTACTS:");
    print(contacts);
  }

  Future<String> getContacts() async {
    var response = await Global.httpPostSync(widget.string,
        Uri.parse(Global.API_URL+"/user/get_contacts"), body: <String, String>{
          "user_id": Global.USER_ID.toString()
        });
    return response.body;
  }

  Future<void> onContactRefresh() async {
    getContacts();
  }

  void addGroup() async {
    var subject = subjectController.text.trim();
    if (selectedImage == null) {
      Global.alert(context, widget.string, widget.string.information, widget.string.text96);
      return;
    }
    if (subject == "") {
      Global.alert(context, widget.string, widget.string.information, widget.string.text93);
      return;
    }
    await Global.showProgressDialog(context, widget.string.text94);
    try {
      var request = new http.MultipartRequest("POST", Uri.parse(Global.API_URL + "/user/add_group"));
      request.fields['unique_id'] = Global.generateUUID();
      request.fields['user_id'] = Global.USER_ID.toString();
      request.fields['title'] = subject;
      request.fields['contact_id'] = contacts[selectedContactIndex]['id'].toString();
      request.fields['date'] = Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss");
      request.files.add(await http.MultipartFile('photo', File(selectedImage.path).readAsBytes().asStream(),
          File(selectedImage.path).lengthSync(), filename: Uuid().v1()));
      request.send().then((responseStream) async {
        var response = await responseStream.stream.bytesToString();
        print("add group response: "+response);
        await Global.hideProgressDialog(context);
        Global.show(widget.string.text95);
        Navigator.pop(context, true);
      });
    } catch (e) {
      print(e);
    }

    Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/add_group"), body: <String, String>{
      "user_id": Global.USER_ID.toString(),
      "title": subject,
      "contact_id": contacts[selectedContactIndex]['id'].toString(),
      "date": Jiffy(DateTime.now()).format("yyyy-MM-dd HH:mm:ss")
    }, onSuccess: (response) async {
      print("ADD GROUP RESPONSE:");
      print(response);
      await Global.hideProgressDialog(context);
      Global.show(widget.string.text95);
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(child: Column(
        children: [
          Card(
              elevation: 5,
              clipBehavior: Clip.antiAlias,
              shadowColor: Color(0x4C888888),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)
              ),
              child: Container(
                  height: 55,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(width: 55, height: 55, child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Center(
                                child: Icon(Ionicons.chevron_back, color: Color(0xff353e3b))
                            )
                        )),
                        Text(widget.string.text87, style: TextStyle(color: Color(0xff404d40), fontSize: 15, fontWeight: FontWeight.bold)),
                        Container(width: 55, height: 55, child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              addGroup();
                            },
                            child: Center(
                                child: Icon(Ionicons.add, color: Color(0xff353e3b))
                            )
                        ))
                      ]
                  )
              )
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Column(
                    children: [
                      SizedBox(height: 30),
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                              width: 260,
                              decoration: BoxDecoration(
                                  color: Color(0xffe3e3e3),
                                  borderRadius: BorderRadius.circular(30)
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 130,
                                        height: 35,
                                        padding: EdgeInsets.only(left: 14, right: 14),
                                        decoration: BoxDecoration(
                                            color: Color(selectedGroupType==0?0xff5b935d:0xffe3e3e3),
                                            borderRadius: BorderRadius.circular(30)
                                        ),
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              setState(() {
                                                selectedGroupType = 0;
                                              });
                                            },
                                            child: Center(
                                                child: Text(widget.string.text88, style: TextStyle(color: selectedGroupType==0?Colors.white:Color(0xff939997), fontSize: 15, fontWeight: FontWeight.bold))
                                            )
                                        )
                                    ),
                                    Container(
                                        width: 130,
                                        height: 35,
                                        padding: EdgeInsets.only(left: 14, right: 14),
                                        decoration: BoxDecoration(
                                            color: Color(selectedGroupType==1?0xff5b935d:0xffe3e3e3),
                                            borderRadius: BorderRadius.circular(30)
                                        ),
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              setState(() {
                                                selectedGroupType = 1;
                                              });
                                            },
                                            child: Center(
                                                child: Text(widget.string.text89, style: TextStyle(color: selectedGroupType==1?Colors.white:Color(0xff939997), fontSize: 15, fontWeight: FontWeight.bold))
                                            )
                                        )
                                    )
                                  ]
                              )
                          )
                      ),
                      SizedBox(height: 20),
                      (() {
                        if (selectedImage == null) {
                          return Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Color(0xffe3e3e1),
                                  borderRadius: BorderRadius.circular(25)
                              ),
                              child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    selectImage();
                                  },
                                  child: Center(
                                      child: Icon(Ionicons.camera, color: Color(0xff8a985a), size: 30)
                                  )
                              )
                          );
                        } else {
                          return Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    selectImage();
                                  },
                                  child: Image.file(File(selectedImage.path), width: 200, height: 200, fit: BoxFit.cover)
                              )
                          );
                        }
                      }()),
                      SizedBox(height: 20),
                      Container(
                          width: width-40-40,
                          height: 40,
                          child: TextField(decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text90, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlign: TextAlign.center, textAlignVertical: TextAlignVertical.center, controller: subjectController, keyboardType: TextInputType.text, style: TextStyle(fontSize: 14))
                      ),
                      Container(
                          width: width-40-40,
                          height: 1,
                          color: Color(0xffe9e9e9)
                      ),
                      ListView.builder(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          primary: false,
                          shrinkWrap: true,
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  setState(() {
                                    selectedContactIndex = index;
                                  });
                                },
                                child: Padding(
                                    padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(left: 10),
                                              child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    ClipRRect(
                                                        borderRadius: BorderRadius.circular(20),
                                                        child: Image.network(Global.USERDATA_URL+contacts[index]['photo'].toString(),
                                                            width: 40, height: 40,
                                                            fit: BoxFit.cover)
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(contacts[index]['name'].toString(), style: TextStyle(color: Color(0xff529654), fontSize: 13, fontWeight: FontWeight.bold))
                                                  ]
                                              )
                                          ),
                                          Container(width: 10, height: 10, margin: EdgeInsets.only(right: 10), decoration: BoxDecoration(
                                              color: selectedContactIndex==index?Color(0xff529957):Colors.transparent, borderRadius: BorderRadius.circular(5),
                                              border: Border.all(width: 1, color: selectedContactIndex==index?Colors.transparent:Color(0x4f888888))
                                          ))
                                        ]
                                    )
                                )
                            );
                          }
                      )
                    ]
                )
            )
          )
        ]
    )));
  }
}
