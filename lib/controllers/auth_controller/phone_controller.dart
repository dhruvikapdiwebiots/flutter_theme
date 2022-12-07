import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_theme/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PhoneController extends GetxController {
  bool mobileNumber = false;
  TextEditingController phone = TextEditingController();
  final FocusNode phoneFocus = FocusNode();

  // CHECK VALIDATION

  void checkValidation() async {
    if (phone.text.isEmpty) {
      mobileNumber = true;
    } else {
      dismissKeyboard();
      mobileNumber = false;
      Get.toNamed(routeName.otp, arguments: phone.text);
    }
  }

//   Dismiss KEYBOARD

  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }
}
