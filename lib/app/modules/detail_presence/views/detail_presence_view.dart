import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_presence_controller.dart';

class DetailPresenceView extends GetView<DetailPresenceController> {
  final Map<String, dynamic> data = Get.arguments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DetailPresenceView'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '${DateFormat.yMMMMEEEEd().format(DateTime.parse(data['date']))}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Masuk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Jam : ${DateFormat.Hms().format(
                  DateTime.parse(data['masuk']['date']),
                )}'),
                Text(
                  data['masuk'] == null
                      ? 'Posisi : -'
                      : 'Posisi : ${data['masuk']!['lat']}, ${data['masuk']!['long']}',
                ),
                Text(data['masuk'] == null
                    ? 'Status : -'
                    : ' ${data['masuk']['status']}'),
                Text(
                  'Distance : ${data['masuk']!['distance'].toString().split('.').first} meter',
                ),
                Text(
                  'Address : ${data['masuk']!['address']}',
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Keluar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  data['keluar'] == null
                      ? 'Jam : - '
                      : 'Jam : ${DateFormat.Hms().format(DateTime.parse(data['keluar']['date']))}',
                ),
                Text(
                  data['keluar'] == null
                      ? 'Posisi : -'
                      : 'Posisi : ${data['keluar']!['lat']}, ${data['keluar']!['long']}',
                ),
                Text(data['keluar']?['status'] == null
                    ? 'Status : -'
                    : ' ${data['keluar']?['status']}'),
                Text(
                  data['keluar']?['distance'] == null
                      ? 'Distance : -'
                      //MEMBULATKAN BILANGAN KOMA
                      : 'Distance : ${data['keluar']!['distance'].toString().split('.').first}'
                          'meter',
                ),
                Text(
                  data['keluar']?['address'] == null
                      ? 'Address : -'
                      : 'Address : ${data['keluar']!['address']}',
                ),
              ],
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200]),
          )
        ],
      ),
    );
  }
}
