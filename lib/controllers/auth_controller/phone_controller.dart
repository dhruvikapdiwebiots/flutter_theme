
import 'package:flutter_theme/config.dart';

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
