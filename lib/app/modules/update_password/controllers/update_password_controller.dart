import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class UpdatePasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController currC = TextEditingController();
  TextEditingController newC = TextEditingController();
  TextEditingController confirmC = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  void updatePassword() async {
    if (currC.text.isNotEmpty &&
        newC.text.isNotEmpty &&
        confirmC.text.isNotEmpty) {
      if (newC.text == confirmC.text) {
        isLoading.value = true;
        try {
          String emailUser = auth.currentUser!.email!;
          await auth.signInWithEmailAndPassword(
              email: emailUser, password: currC.text);
          await auth.currentUser!.updatePassword(newC.text);

          Get.back();
          Get.snackbar('Berhasil', 'Berhasil update password');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            Get.snackbar('Terjadi Kesalahan', 'Current Password salah');
          } else {
            Get.snackbar('Terjadi Kesalahan', '${e.code.toLowerCase()}');
          }
          Get.snackbar('Terjadi Kesalahan', 'Tidak dapat update password');
        } catch (e) {
          Get.snackbar('Terjadi Kesalahan', 'Tidak dapat update password');
        } finally {
          isLoading.value = false;
        }
      } else {
        Get.snackbar('Terjadi Kesalahan', 'Password Konfirmasi tidak cocok');
      }
    } else {
      Get.snackbar('Terjadi Kesalahan', 'Semua input harus diisi!!');
    }
  }
}
