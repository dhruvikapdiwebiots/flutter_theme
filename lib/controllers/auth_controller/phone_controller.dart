
import 'dart:async';

import 'package:flutter_theme/config.dart';

class PhoneController extends GetxController {
  bool mobileNumber = false;
  TextEditingController phone = TextEditingController();
  final FocusNode phoneFocus = FocusNode();
  bool isCorrect = false;
  bool visible = false,switchScreen = true;
  Timer timer= Timer(Duration(seconds: 1),(){});
  double val =0;

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

  @override
  void onReady()async {
    // TODO: implement onReady
    await Future.delayed(Durations.ms150);
    visible = true;
    update();
    super.onReady();
  }
}
