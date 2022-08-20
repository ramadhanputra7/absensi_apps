import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      //eksekusi
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
            email: emailC.text, password: passC.text);
        //VERIFICATION EMAIL
        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified == true) {
            isLoading.value = false;
            if (passC.text == 'password') {
              Get.offAllNamed(Routes.NEW_PASSWORD);
            }
            Get.offAllNamed(Routes.HOME);
          } else {
            Get.defaultDialog(
                title: 'Belum Verifikasi Email',
                middleText:
                    'Kamu Belum Verifikasi Akun Ini. Lakukan Verifikasi di Email Kamu',
                actions: [
                  OutlinedButton(
                    onPressed: () {
                      isLoading.value = false;
                      Get.back();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          await userCredential.user!.sendEmailVerification();
                          Get.back();
                          Get.snackbar('Berhasil',
                              'Kami telah mengirim ulang email verifikasi');
                          isLoading.value = false;
                        } catch (e) {
                          isLoading.value = false;
                          Get.snackbar('Terjadi Kesalahan',
                              'Tidak dapat mengirim email verifikasi. Hubungi admin');
                        }
                      },
                      child: Text('Kirim Ulang'))
                ]);
          }
        }
        isLoading.value = false;
        print(userCredential);
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'user-not-found') {
          Get.snackbar('Terjadi Kesalahan', 'Pengguna Tidak Ditemukan');
          print('No user found for that email');
        } else if (e.code == 'wrong-password') {
          Get.snackbar('Terjadi Kesalahan', 'Password Salah');
          print('Wrong password provided for that user');
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar('Terjadi Kesalahan', 'Tidak dapat login');
      }
    } else {
      Get.snackbar('Terjadi Kesalahan', 'Email dan Password wajib diisi');
    }
  }
}
