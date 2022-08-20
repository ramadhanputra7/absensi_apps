import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:presence/app/controllers/page_index_controller.dart';
import 'package:presence/app/routes/app_pages.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: controller.streamUser(),
        builder: (context, snap) {
          //JIKA DATA NYA MASIH LOADING
          if (snap.connectionState == ConnectionState.waiting) {
            //TAMPILKAN CIRCULAR PROGRESS
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snap.hasData) {
            //JIKA DATANYA SUDAH DAPAT
            Map<String, dynamic> user = snap.data!.data()!;
            String defaultImage =
                "https://ui-avatars.com/api/?name=${user['name']}";
            //TAMPILKAN DATA USER
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                //GAMBAR PROFILE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image.network(
                          user['profile'] != null
                              ? user['profile'] != ''
                                  ? user['profile']
                                  : defaultImage
                              : defaultImage,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                //NAMA USER
                Text(
                  '${user['name'].toString().toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 20,
                ),
                //EMAIL USER
                Text(
                  '${user['email']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                //UPDATE PROFILE
                ListTile(
                  onTap: () =>
                      Get.toNamed(Routes.UPDATE_PROFILE, arguments: user),
                  leading: Icon(Icons.person),
                  title: Text('Update Profile'),
                ),
                //UPDATE PASSWORD
                ListTile(
                  onTap: () => Get.toNamed(Routes.UPDATE_PASSWORD),
                  leading: Icon(Icons.vpn_key),
                  title: Text('Update Password'),
                ),
                //JIKA ROLENYA ADMIN
                if (user['role'] == 'admin')
                  //TAMPILKAN MENU ADD PEGAWAI
                  ListTile(
                    onTap: () => Get.toNamed(Routes.ADD_PEGAWAI),
                    leading: Icon(Icons.person_add),
                    title: Text('Add Pegawai'),
                  ),
                //LOGOUT
                ListTile(
                  onTap: () => controller.logout(),
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ],
            );
          } else {
            //TAMPILKAN INI JIKA GAGAL MENGAMBIL DATA USER
            return Center(
              child: Text('Tidak dapat memuat data user'),
            );
          }
        },
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.fingerprint, title: 'Add'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value,
        onTap: (int i) => pageC.changePage(i),
      ),
    );
  }
}
