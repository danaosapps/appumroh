// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class JadwalSholatController extends GetxController {
  var lokasi = ''.obs;
  var daerah = ''.obs;
  var tanggal = ''.obs;
  var imsak = ''.obs;
  var subuh = ''.obs;
  var terbit = ''.obs;
  var dzuhur = ''.obs;
  var ashar = ''.obs;
  var maghrib = ''.obs;
  var isya = ''.obs;

  Future<void> getJadwalSholat({
    required String idKota,
    required String tanggalJadwal,
  }) async {
    try {
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api.myquran.com/v1/sholat/jadwal/$idKota/$tanggalJadwal'));

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);

        if (data['data'] != null) {
          lokasi.value = data['data']['lokasi'];
          daerah.value = data['data']['daerah'];
          tanggal.value = data['data']['jadwal']['tanggal'];
          imsak.value = data['data']['jadwal']['imsak'];
          subuh.value = data['data']['jadwal']['subuh'];
          terbit.value = data['data']['jadwal']['terbit'];
          dzuhur.value = data['data']['jadwal']['dzuhur'];
          ashar.value = data['data']['jadwal']['ashar'];
          maghrib.value = data['data']['jadwal']['maghrib'];
          isya.value = data['data']['jadwal']['isya'];
        }
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      print(e);
    }
  }
}
