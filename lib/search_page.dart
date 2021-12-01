import 'dart:convert';

import 'package:appumroh/chapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(SearchPage(null, null));
}

class SearchPage extends StatefulWidget {
  final context, string;
  SearchPage(this.context, this.string);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> with WidgetsBindingObserver {
  var queryController = TextEditingController(text: "");
  var searchResults = [];
  double verseSize = 17.0;
  double spellingSize = 10.0;
  double meaningSize = 10.0;
  var juzSize = 10.0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    setState(() {
      Global.CURRENT_SCREEN = "search_page";
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(body: SafeArea(
        child: Column(
          children: [
            Container(width: width, height: 50, color: Global.MAIN_COLOR, child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 50, height: 50, child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Center(
                          child: Icon(Ionicons.arrow_back_outline, color: Colors.white, size: 20)
                      )
                  )),
                  Expanded(
                      child: Stack(
                          children: [
                            Container(
                                height: 40,
                                margin: EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2)
                                ),
                                child: TextField(
                                    onChanged: (value) {
                                      if (value.trim() == "") {
                                        return;
                                      }
                                      Global.httpPost(widget.string, Uri.parse(Global.API_URL+"/user/search_quran"),
                                          body: <String, String>{
                                            "keyword": value
                                          }, onSuccess: (response) {
                                            setState(() {
                                              searchResults = jsonDecode(response);
                                            });
                                          });
                                    },
                                    decoration: new InputDecoration(counterText: "", border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF9CA4AC), fontSize: 14), hintText: widget.string.text42, contentPadding: EdgeInsets.only(left: 15, right: 15, bottom: 15)), textAlignVertical: TextAlignVertical.center, controller: queryController, keyboardType: TextInputType.name, style: TextStyle(fontSize: 14))
                            ),
                            Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                    width: 35, height: 40, child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      queryController.text = "";
                                    },
                                    child: Center(
                                        child: Icon(Ionicons.close_outline, color: Color(0xff95a5a6), size: 20)
                                    )
                                )
                                )
                            )
                          ]
                      )
                  ),
                  SizedBox(width: 20)
                ]
            )),
            Flexible(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return Column(
                      children: [
                        Container(
                            width: width,
                            color: Global.getColorFromHex(Global.CURRENT_THEME['background_color'].toString()),
                            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Text(searchResults[index]['verse'].toString(), style: TextStyle(
                                          color: Global.getColorFromHex(Global.CURRENT_THEME['verse_color']), fontSize: verseSize
                                      ), textAlign: TextAlign.end)),
                                  SizedBox(height: 8),
                                  Text(searchResults[index]['spelling'].toString(), style: TextStyle(
                                      color: Global.getColorFromHex(Global.CURRENT_THEME['spelling_color']), fontSize: spellingSize
                                  ), textAlign: TextAlign.end),
                                  SizedBox(height: 8),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text((int.parse(searchResults[index]['verse_number'].toString())).toString()+". "+searchResults[index]['meaning'].toString(), style: TextStyle(
                                          color: Global.getColorFromHex(Global.CURRENT_THEME['meaning_color']), fontSize: meaningSize
                                      ), textAlign: TextAlign.start)
                                  ),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(widget.string.juz+" "+searchResults[index]['juz'].toString(), style: TextStyle(
                                          color: Global.getColorFromHex(Global.CURRENT_THEME['juz_color']), fontSize: juzSize, fontWeight: FontWeight.bold
                                      ))
                                  ),
                                  SizedBox(height: 2),
                                  Container(
                                    width: 80,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: Global.getColorFromHex(Global.CURRENT_THEME['juz_color']),
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        Global.navigate(context, Chapter(context, widget.string, searchResults[index]['chapter'], true, int.parse(searchResults[index]['verse_number'])));
                                      },
                                      child: Center(
                                        child: Text(widget.string.text43, style: TextStyle(
                                          color: Colors.white, fontSize: 11
                                        ))
                                      )
                                    )
                                  )
                                ]
                            )
                        ),
                        Container(width: width, height: 0.5, color: Color(0x7f000000))
                      ]
                  );
                }
              )
            )
          ]
        )));
  }
}
