import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ionicons/ionicons.dart';
import 'global.dart';

void main() {
  runApp(ThemePreview(null, null, null, null, null, null, null, null, null, null));
}

class ThemePreview extends StatefulWidget {
  final context, string, themeID, backgroundColor, backgroundImageURL, verseColor, spellingColor, meaningColor, juzColor, locked;
  ThemePreview(this.context, this.string, this.themeID, this.backgroundColor, this.backgroundImageURL, this.verseColor, this.spellingColor, this.meaningColor, this.juzColor, this.locked);

  @override
  ThemePreviewState createState() => ThemePreviewState();
}

class ThemePreviewState extends State<ThemePreview> with WidgetsBindingObserver {
  var ayatPresets = [
    {
      "verse": "بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ",
      "spelling": "bismillahir-rahmanir-rahim",
      "meaning": "Dengan nama Allah Yang Maha Pengasih, Maha Penyayang."
    },
    {
      "verse": "اَلْحَمْدُ لِلّٰهِ رَبِّ الْعٰلَمِيْنَِۙ",
      "spelling": "al-hamdu lillahi rabbil-'alamin",
      "meaning": "Segala puji bagi Allah, Tuhan seluruh alam,"
    },
    {
      "verse": "الرَّحْمٰنِ الرَّحِيْمِۙ",
      "spelling": "ar-rahmanir-rahim",
      "meaning": "Yang Maha Pengasih, Maha Penyayang,"
    },
    {
      "verse": "مٰلِكِ يَوْمِ الدِّيْنِِۗ",
      "spelling": "maliki yaumid-din",
      "meaning": "Pemilik hari pembalasan."
    },
    {
      "verse": "اِيَّاكَ نَعْبُدُ وَاِيَّاكَ نَسْتَعِيْنُِۗ",
      "spelling": "iyyaka na'budu wa iyyaka nasta'in",
      "meaning": "Hanya kepada Engkaulah kami menyembah dan hanya kepada Engkaulah kami mohon pertolongan."
    },
    {
      "verse": "اِهْدِنَا الصِّرَاطَ الْمُسْتَقِيْمَ ۙ",
      "spelling": "ihdinas-siratal-mustaqim",
      "meaning": "Tunjukilah kami jalan yang lurus,"
    },
    {
      "verse": "صِرَاطَ الَّذِيْنَ اَنْعَمْتَ عَلَيْهِمْ ەۙ غَيْرِ الْمَغْضُوْبِ عَلَيْهِمْ وَلَا الضَّاۤلِّيْنَ ",
      "spelling": "siratallazina an'amta 'alaihim gairil-magdubi 'alaihim wa lad-dallin",
      "meaning": "(yaitu) jalan orang-orang yang telah Engkau beri nikmat kepadanya; bukan (jalan) mereka yang dimurkai, dan bukan (pula jalan) mereka yang sesat."
    },
  ];

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
        decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Stack(
            children: [
              (() {
                if (widget.backgroundImageURL == null) {
                  return SizedBox.shrink();
                } else {
                  return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(widget.backgroundImageURL, width: 100, height: 100,
                          fit: BoxFit.cover)
                  );
                }
              }()),
              ListView.builder(
                  itemCount: ayatPresets.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.only(left: 4, right: 4),
                        child: Column(
                            children: [
                              Container(
                                  width: width,
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Text(ayatPresets[index]['verse'].toString(), style: TextStyle(
                                                color: widget.verseColor, fontSize: 7
                                            ), textAlign: TextAlign.end)),
                                        SizedBox(height: 8),
                                        Text(ayatPresets[index]['spelling'].toString(), style: TextStyle(
                                            color: widget.spellingColor, fontSize: 7
                                        ), textAlign: TextAlign.end),
                                        SizedBox(height: 8),
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text((index+1).toString()+". "+ayatPresets[index]['meaning'].toString(), style: TextStyle(
                                                color: widget.meaningColor, fontSize: 7
                                            ), textAlign: TextAlign.start)
                                        ),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(widget.string.juz+" "+ayatPresets[index]['juz'].toString(), style: TextStyle(
                                                color: widget.juzColor, fontSize: 7, fontWeight: FontWeight.bold
                                            ))
                                        )
                                      ]
                                  )
                              ),
                              Container(width: width, height: 0.5, color: Color(0x7f000000))
                            ]
                        ));
                  }
              ),
              (() {
                if (widget.locked) {
                  return Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                          padding: EdgeInsets.only(top: 8, right: 8),
                          child: Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                  color: Global.SECONDARY_COLOR,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Center(
                                  child: Icon(Ionicons.lock_closed, color: Colors.white, size: 15)
                              )
                          )
                      )
                  );
                } else {
                  return SizedBox.shrink();
                }
              }())
            ]
        )
    );
  }
}
