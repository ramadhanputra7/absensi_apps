import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class NewPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  TextEditingController newPass2C = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  void newPassword() async {
    if (newPassC.text.isNotEmpty &&
        newPass2C.text.isNotEmpty &&
        newPassC.text == newPass2C.text &&
        newPass2C.text != 'password') {
      try {
        String email = auth.currentUser!.email!;
        await auth.currentUser!.updatePassword(newPass2C.text);
        auth.signOut();
        auth.signInWithEmailAndPassword(
          email: email,
          password: newPass2C.text,
        );
        String uid = auth.currentUser!.uid;
        await firestore.collection('pegawai').doc(uid).update(
            {'password': newPassC.text, 'password konfirmasi': newPass2C.text});
        Get.offAllNamed(Routes.HOME);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar('Terjadi Kesalahan', 'Password Terlalu Lemah');
        }
      } catch (e) {
        Get.snackbar('Terjadi kesalahan',
            'Tidak dapat membuat password baru. Hubungi admin');
      }
    } else if (newPass2C.text != newPassC.text) {
      Get.snackbar('Terjadi Kesalahan',
          'Password Konfirmasi harus sama dengan Password');
    } else if (newPassC.text == 'password') {
      Get.snackbar('Terjadi Kesalahan',
          'Password baru harus diubah dan tidak boleh kata "password" ');
    } else {
      Get.snackbar('Terjadi Kesalahan', 'Password baru wajib diisi');
    }
  }
}
