import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/add_pegawai_controller.dart';

class AddPegawaiView extends GetView<AddPegawaiController> {
  const AddPegawaiView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD STAFF'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: controller.nipC,
            decoration:
                InputDecoration(labelText: 'NIP', border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.nameC,
            decoration: InputDecoration(
                labelText: 'Name', border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.jobC,
            decoration:
                InputDecoration(labelText: 'Job', border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.emailC,
            decoration: InputDecoration(
                labelText: 'Email', border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.passC,
            decoration: InputDecoration(
                labelText: 'Password', border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: controller.pass2C,
            decoration: InputDecoration(
                labelText: 'Password Konfirmasi', border: OutlineInputBorder()),
          ),
          SizedBox(
            height: 40,
          ),
          SizedBox(
            height: 40,
          ),
          Obx(
            () => ElevatedButton(
                onPressed: () async {
                  if (controller.isLoading.isFalse) {
                    await controller.addStaff();
                  }
                },
                child: Text(
                    controller.isLoading.isFalse ? 'ADD STAFF' : 'LOADING...')),
          )
        ],
      ),
    );
  }
}
