// {
//     "status": true,
//     "data": {
//         "id": "1301",
//         "lokasi": "KOTA JAKARTA",
//         "daerah": "DKI JAKARTA",
//         "koordinat": {
//             "lat": -6.1700888888888885,
//             "lon": 106.83105,
//             "lintang": "6° 10' 12.32\" S",
//             "bujur": "106° 49' 51.78\" E"
//         },
//         "jadwal": {
//             "tanggal": "Rabu, 17/11/2021",
//             "imsak": "03:56",
//             "subuh": "04:06",
//             "terbit": "05:22",
//             "dhuha": "05:51",
//             "dzuhur": "11:41",
//             "ashar": "15:03",
//             "maghrib": "17:53",
//             "isya": "19:06",
//             "date": "2021-11-17"
//         }
//     }
// }

// To parse this JSON data, do
//
//     final jadwalSholat = jadwalSholatFromJson(jsonString);

import 'dart:convert';

JadwalSholat jadwalSholatFromJson(String str) =>
    JadwalSholat.fromJson(json.decode(str));

String jadwalSholatToJson(JadwalSholat data) => json.encode(data.toJson());

class JadwalSholat {
  JadwalSholat({
    required this.tanggal,
    required this.imsak,
    required this.subuh,
    required this.terbit,
    required this.dhuha,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
    required this.date,
  });

  String tanggal;
  String imsak;
  String subuh;
  String terbit;
  String dhuha;
  String dzuhur;
  String ashar;
  String maghrib;
  String isya;
  String date;

  factory JadwalSholat.fromJson(Map<String, dynamic> json) => JadwalSholat(
        tanggal: json["tanggal"],
        imsak: json["imsak"],
        subuh: json["subuh"],
        terbit: json["terbit"],
        dhuha: json["dhuha"],
        dzuhur: json["dzuhur"],
        ashar: json["ashar"],
        maghrib: json["maghrib"],
        isya: json["isya"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "tanggal": tanggal,
        "imsak": imsak,
        "subuh": subuh,
        "terbit": terbit,
        "dhuha": dhuha,
        "dzuhur": dzuhur,
        "ashar": ashar,
        "maghrib": maghrib,
        "isya": isya,
        "date": date,
      };
}
