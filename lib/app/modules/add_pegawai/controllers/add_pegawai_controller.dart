import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:presence/app/routes/app_pages.dart';

class AddPegawaiController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;
  TextEditingController nipC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController jobC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  TextEditingController pass2C = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> prosesAddPegawai() async {
    if (passAdminC.text.isNotEmpty) {
      isLoadingAddPegawai.value = true;
      try {
        String emailAdmin = 'SuperUser7';
        UserCredential userCredentialAdmin =
            await auth.signInWithEmailAndPassword(
                email: emailAdmin, password: emailAdmin);
        //Register with Email and Password
        UserCredential pegawaiCredential =
            await auth.createUserWithEmailAndPassword(
                email: emailC.text, password: pass2C.text);
        //Add User TO DataBase
        if (pegawaiCredential.user != null) {
          String uid = pegawaiCredential.user!.uid;
          await firestore.collection('pegawai').doc(uid).set({
            'nip': nipC.text,
            'name': nameC.text,
            'job': jobC.text,
            'email': emailC.text,
            'role': 'pegawai',
            'password': passC.text,
            'password konfirmasi': pass2C.text,
            'uid': uid,
            'createdAt': DateTime.now().toIso8601String()
          });
          //SEND EMAIL VERIFICATION
          await pegawaiCredential.user!.sendEmailVerification();
          await auth.signOut();
          UserCredential userCredentialAdmin =
              await auth.signInWithEmailAndPassword(
            email: emailAdmin,
            password: passAdminC.text,
          );

          Get.back();
          Get.back();
          isLoading.value = false;
          Get.snackbar('Berhasil', 'Berhasil menambahkan pegawai');
        }

        print(pegawaiCredential);
      } on FirebaseAuthException catch (e) {
        isLoadingAddPegawai.value = false;
        print(e);
        if (e.code == 'weak-password') {
          Get.snackbar(
              'Terjadi Kesalahan', 'Password yang digunakan terlalu singkat');
          print('The password provided is to weak');
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar('Terjadi kesalahan', 'Pegawai sudah ada!!!');
          print('The account already exists for that email');
        } else if (e.code == 'wrong-password') {
          Get.snackbar('Terjadi Kesalahan', 'Password Salah');
        } else {
          Get.snackbar('Terjadi Kesalahan', '${e.code}');
        }
      } catch (e) {
        isLoadingAddPegawai.value = false;
        Get.snackbar('Terjadi kesalahan', 'Tidak dapat menambahkan pegawai');
        if (nameC.text.isEmpty) {
          Get.snackbar('Terjadi Kesalahan', 'Nama Tidak boleh kosong');
        } else if (nameC.text.length < 3) {
          Get.snackbar('Terjadi Kesalahan', 'Nama Minimal 3 Huruf');
        } else if (nameC.text.length > 50) {
          Get.snackbar('Terjadi Kesalahan', 'Nama Maksimal 50 Huruf');
        } else if (emailC.text.isEmail == false) {
          Get.snackbar('Terjadi Kesalahan', 'Email Tidak Valid');
        } else if (emailC.text.isEmpty) {
          Get.snackbar('Terjadi Kesalahan', 'Email Tidak Boleh Kosong');
        } else if (passC.text.length < 8) {
          Get.snackbar(
              'Terjadi Kesalahan', 'Masukkan Password Minimal 8 Karakter');
        } else if (passC.text.contains(RegExp(r'[A-Z]')) == false) {
          Get.snackbar('Terjadi Kesalahan',
              'Password Minimal Mengandung Satu Huruf Besar');
        } else if (passC.text.contains(RegExp(r'[a-z]')) == false) {
          Get.snackbar('Terjadi Kesalahan',
              'Password Minimal Mengandung Satu Huru Kecil');
        } else if (passC.text.contains(RegExp(r'[0-9]')) == false) {
          Get.snackbar(
              'Terjadi Kesalahan', 'Password Minimal Mengandung Angka');
        } else if (passC.text.isEmpty) {
          Get.snackbar('Terjadi Kesalahan', 'Password Tidak Boleh Kosong');
        } else if (pass2C.text != passC.text) {
          Get.snackbar('Terjadi Kesalahan', 'Password Konfirmasi Salah');
        } else if (pass2C.text.isEmpty) {
          Get.snackbar(
              'Terjadi Kesalahan', 'Password Konfirmasi Tidak Boleh Kosong');
        } else {
          isLoading.value = false;
          Get.snackbar('Terjadi Kesalahan',
              'Password wajib diisi untuk keperluan validasi');
        }
      }
    }
  }

  Future<void> addStaff() async {
    if (nipC.text.isNotEmpty &&
        nameC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        passC.text.isNotEmpty &&
        nameC.text.length > 3 &&
        nameC.text.length < 50 &&
        jobC.text.isNotEmpty &&
        emailC.text.isEmail &&
        passC.text.isNotEmpty &&
        passC.text.length > 8 &&
        passC.text.contains(RegExp(r'[A-Z]')) &&
        passC.text.contains(RegExp(r'[a-z]')) &&
        passC.text.contains(RegExp(r'[0-9]')) &&
        pass2C.text.isNotEmpty &&
        pass2C.text == passC.text) {
      isLoading.value = true;
      Get.defaultDialog(
          title: 'Validasi Admin',
          content: Column(
            children: [
              Text('Masukkan Password untuk validasi admin'),
              TextField(
                controller: passAdminC,
                autocorrect: false,
                obscureText: false,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: [
            OutlinedButton(
                onPressed: () {
                  isLoading.value = false;
                  Get.back();
                },
                child: Text(
                  'CANCEL',
                )),
            Obx(
              () => ElevatedButton(
                  onPressed: () async {
                    if (isLoadingAddPegawai.isFalse) {
                      await prosesAddPegawai();
                    }
                    isLoading.value = false;
                  },
                  child: Text(isLoadingAddPegawai.isFalse
                      ? 'ADD PEGAWAI'
                      : 'LOADING...')),
            )
          ]);

      //eksekusi

    } else {
      print('Terjadi kesalahan' 'NIP, Nama dan Email harus diisi!!!');
      Get.snackbar(
          'Terjadi kesalahan', 'NIP, Nama, Job dan Email harus diisi!!!');
    }
  }
}
