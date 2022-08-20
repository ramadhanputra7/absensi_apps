import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence/app/routes/app_pages.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    switch (i) {
      case 1:
        print('ABSENSI');
        Map<String, dynamic> dataResponse = await determinePosition();
        if (dataResponse['error'] != true) {
          Position position = dataResponse['position'];
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          String address =
              '${placemarks[0].street},${placemarks[0].subLocality},${placemarks[0].locality},${placemarks[0].administrativeArea},${placemarks[0].country}'
              '';
          print(placemarks[0]);
          await updatePosition(position, address);

          //CEK DISTANCE BETWEEN 2 POSITION
          //-0.3051597!4d100.3695204
          double distance = Geolocator.distanceBetween(
              -0.3051597, 100.3695204, position.latitude, position.longitude);

          //PRESENSI ABSEN MASUK
          await presensi(position, address, distance);
          // Get.snackbar('Berhasil', 'Kamu sudah absen');
        } else {
          Get.snackbar('Terjadi Kesalahan', dataResponse['message']);
        }

        break;
      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> presensi(
      Position position, String address, double distance) async {
    String uid = await auth.currentUser!.uid;
    CollectionReference<Map<String, dynamic>> colPresence = await firestore
        .collection(
          'pegawai',
        )
        .doc(uid)
        .collection(
          'presence',
        );
    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();
    DateTime now = DateTime.now();
    String todayDocID = DateFormat.yMd().format(now).replaceAll('/', '-');

    String status;

    //ABSEN DI DALAM AREA
    if (distance <= 20) {
      status = 'Di dalam area';
    } else {
      //ABSEN DILUAR AREA
      status = 'Di luar area';
    }

    //BELUM PERNAH ABSEN DAN SET ABSEN MASUK PERTAMA KALINYA
    if (snapPresence.docs.length == 0) {
      await Get.defaultDialog(
          title: 'Validasi Presensi',
          middleText: 'Apakah kamu yakin akan mengisi absen masuk sekarang??',
          actions: [
            OutlinedButton(onPressed: () => Get.back(), child: Text('CANCEL')),
            OutlinedButton(
                onPressed: () async {
                  await colPresence.doc(todayDocID).set({
                    'date': now.toIso8601String(),
                    'masuk': {
                      'date': now.toIso8601String(),
                      'lat': position.latitude,
                      'long': position.longitude,
                      'address': address,
                      'status': status,
                      'distance': distance,
                    },
                  });
                  Get.back();
                  Get.snackbar('Berhasil', 'Kamu sudah absen masuk');
                },
                child: Text('YES')),
          ]);
    } else {
      //SUDAH PERNAH ABSEN -> CEK HARI INI UDAH ABSEN MASUK/KELUAR BELUM
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await colPresence.doc(todayDocID).get();
      if (todayDoc.exists == true) {
        //TINGGAL ABSEN KELUAR ATAU SUDAH ABSEN MASUK DAN KELUAR
        Map<String, dynamic>? dataPresenceToday = todayDoc.data();
        if (dataPresenceToday?['keluar'] != null) {
          //SUDAH ABSEN MASUK DAN KELUAR
          Get.snackbar('Sukses', 'Kamu sudah absen masuk dan keluar');
        } else {
          //ABSEN KELUAR
          await Get.defaultDialog(
              title: 'Validasi Presensi',
              middleText:
                  'Apakah kamu yakin akan mengisi absen keluar sekarang??',
              actions: [
                OutlinedButton(
                    onPressed: () => Get.back(), child: Text('CANCEL')),
                OutlinedButton(
                    onPressed: () async {
                      await colPresence.doc(todayDocID).update({
                        'date': now.toIso8601String(),
                        'keluar': {
                          'date': now.toIso8601String(),
                          'lat': position.latitude,
                          'long': position.longitude,
                          'address': address,
                          'status': status,
                          'distance': distance,
                        },
                      });
                      Get.back();
                      Get.snackbar('Berhasil', 'Kamu sudah absen keluar');
                    },
                    child: Text('YES')),
              ]);
        }
      } else {
        //ABSEN MASUK
        await Get.defaultDialog(
            title: 'Validasi Presensi',
            middleText: 'Apakah kamu yakin akan mengisi absen masuk sekarang??',
            actions: [
              OutlinedButton(
                  onPressed: () => Get.back(), child: Text('CANCEL')),
              OutlinedButton(
                  onPressed: () async {
                    await colPresence.doc(todayDocID).set({
                      'date': now.toIso8601String(),
                      'masuk': {
                        'date': now.toIso8601String(),
                        'lat': position.latitude,
                        'long': position.longitude,
                        'address': address,
                        'status': status,
                        'distance': distance,
                      },
                    });
                    Get.back();
                    Get.snackbar('Berhasil', 'Kamu sudah absen masuk');
                  },
                  child: Text('YES')),
            ]);
      }
    }
  }

  Future<void> updatePosition(Position position, String address) async {
    String uid = await auth.currentUser!.uid;
    await firestore.collection('pegawai').doc(uid).update({
      'position': {
        'lat': position.latitude,
        'long': position.longitude,
      },
      'address': address
    });
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Terjadi Kesalahan', 'Silahkan hidupkan GPS anda');
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Terjadi Kesalahan', 'Silahkan hidupkan GPS anda');
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return {
          'message': 'Tidak dapat mengakses Layaan GPS',
          'error': true,
        };
        //return {'message': 'Silahkan hidupkan layanan GPS', 'error': true};
        //return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      Get.snackbar('Terjadi Kesalahan', 'Silahkan hidupkan GPS anda');
      return {'message': 'Silahkan hidupkan layanan GPS', 'error': false};

      //return Future.error(
      // 'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    Position position = await Geolocator.getCurrentPosition();

    return {
      'position': position,
      'message': 'Berhasil mendapatkan posisi device',
      'error': false
    };
  }
}
