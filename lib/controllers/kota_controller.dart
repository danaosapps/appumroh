// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:appumroh/models/kota_model.dart';

class KotaController extends GetxController {
  List<Kota> _listAllKota = [];
  List<Kota> get listAllKota => _listAllKota.obs;

  Future<void> getKota() async {
    try {
      var request = http.Request(
          'GET', Uri.parse('https://api.myquran.com/v1/sholat/kota/semua'));

      http.StreamedResponse response = await request.send();

      _listAllKota = [];

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData) as List<dynamic>;

        _listAllKota = Kota.fromJsonList(data);
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
  }
}
