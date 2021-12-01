// [
//     {
//         "id": "0101",
//         "lokasi": "KAB. ACEH BARAT"
//     },
//     {
//         "id": "0102",
//         "lokasi": "KAB. ACEH BARAT DAYA"
//     },
// ]    

// To parse this JSON data, do
//
//     final kota = kotaFromJson(jsonString);

import 'dart:convert';

Kota kotaFromJson(String str) => Kota.fromJson(json.decode(str));

String kotaToJson(Kota data) => json.encode(data.toJson());

class Kota {
  Kota({
    required this.id,
    required this.lokasi,
  });

  String id;
  String lokasi;

  factory Kota.fromJson(Map<String, dynamic> json) => Kota(
        id: json["id"],
        lokasi: json["lokasi"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "lokasi": lokasi,
      };

  static List<Kota> fromJsonList(List list) {
    if (list.isEmpty) return List<Kota>.empty();
    return list.map((item) => Kota.fromJson(item)).toList();
  }


}
