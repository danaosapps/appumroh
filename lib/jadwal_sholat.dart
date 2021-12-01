// ignore_for_file: prefer_const_constructors, must_be_immutable, use_key_in_widget_constructors, avoid_print, unnecessary_string_interpolations

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:appumroh/controllers/kota_controller.dart';
import '../../../models/kota_model.dart';
import '../../../controllers/jadwal_sholat_controller.dart';

class JadwalSholat extends StatelessWidget {
  // const JadwalSholat({Key? key}) : super(key: key);

  String idKota = '1301';
  String idKotaTerpilih = '1301';

  var today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    String tgl = DateFormat('yyyy/MM/dd').format(today);

    final jadwalSholatController = Get.put(JadwalSholatController());

    jadwalSholatController.getJadwalSholat(idKota: idKota, tanggalJadwal: tgl);

    final kotaController = Get.put(KotaController());

    kotaController.getKota();

    print('test');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: width,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(),
                color: Color(0xFF2D4F2F),
              ),
              child: GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // *Lokasi dan Daerah
                    Obx(
                      () => Text(
                        jadwalSholatController.lokasi.value,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Obx(
                      () => Text(
                        jadwalSholatController.daerah.value,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
                onTap: () {
                  Get.dialog(AlertDialog(
                    title: Text('Kota'),
                    content: SizedBox(
                      height: 75,
                      child: DropdownSearch<Kota>(
                        showSearchBox: true,
                        items: kotaController.listAllKota,
                        dropdownSearchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          hintText: 'Pilih Kota Anda...',
                          hintStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        popupItemBuilder: (context, item, isSelected) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Text(
                              '${item.lokasi}',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                        itemAsString: (item) => item!.lokasi,
                        onChanged: (value) {
                          // *Id Lokasi
                          idKotaTerpilih = value!.id;
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text('Proses'),
                        onPressed: () {
                          idKota = idKotaTerpilih;

                          jadwalSholatController.getJadwalSholat(
                              idKota: idKota, tanggalJadwal: tgl);

                          Get.back();
                        },
                      ),
                    ],
                  ));
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(),
                color: Color(0xFF549558),
              ),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // *Tombol Tanggal Sebelum
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        today = today.subtract(
                          Duration(days: 1),
                        );

                        tgl = DateFormat('yyyy/MM/dd').format(today);

                        jadwalSholatController.getJadwalSholat(
                            idKota: idKota, tanggalJadwal: tgl);
                      },
                    ),
                    Column(
                      children: [
                        Obx(
                          () => Text(
                            jadwalSholatController.tanggal.value,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          'Kalender Hijriyah',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    // *Tombol Tanggal Sesudah
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        today = today.add(
                          Duration(days: 1),
                        );

                        tgl = DateFormat('yyyy/MM/dd').format(today);

                        jadwalSholatController.getJadwalSholat(
                            idKota: idKota, tanggalJadwal: tgl);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    // *Imsak
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Imsak',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 100),
                        Obx(
                          () => Text(
                            jadwalSholatController.imsak.value,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_off,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    // *Subuh
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Subuh',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 100),
                        Obx(
                          () => Text(
                            jadwalSholatController.subuh.value,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    // *Terbit
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Matahari Terbit',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 100),
                        Obx(
                          () => Text(
                            jadwalSholatController.terbit.value,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(
                            Icons.do_not_disturb,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    // *Dzuhur
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Dzuhur',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 100),
                        Obx(
                          () => Text(
                            jadwalSholatController.dzuhur.value,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    // *Ashar
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Ashar',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 100),
                        Obx(
                          () => Text(
                            jadwalSholatController.ashar.value,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    // *Maghrib
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Maghrib',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 100),
                        Obx(
                          () => Text(
                            jadwalSholatController.maghrib.value,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    // *Isya
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            'Isya',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        SizedBox(width: 100),
                        Obx(
                          () => Text(
                            jadwalSholatController.isya.value,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // *Rubah dengan BottomBar
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                  width: width,
                  height: 50,
                  child: Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Text(
                        'Bottom Bar',
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
