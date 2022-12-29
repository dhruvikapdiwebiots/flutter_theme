import 'dart:async';
import 'package:flutter_theme/config.dart';

class ForgotPasswordController extends GetxController {
  var firebaseAuth = FirebaseAuth.instance;
  bool textValidate = false;
  TextEditingController controller = TextEditingController();
  final FocusNode textFocus = FocusNode();

  // CHECK VALIDATION
  void checkValidation() async {
    if (controller.text.isEmpty) {
      textValidate = true;
    } else {
      dismissKeyboard();
      textValidate = false;
      await sendPasswordResetEmail(controller.text.toString());
      Fluttertoast.showToast(
          msg: "Reset password has been sent you in email ID");
      Get.toNamed(routeName.login);
    }
  }

  // PASSWORD RESET PROCESS
  Future sendPasswordResetEmail(String email) async {
    return firebaseAuth.sendPasswordResetEmail(email: email);
  }

// FOR Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }
}
