
import 'dart:async';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneController extends GetxController {
  bool mobileNumber = false;
  TextEditingController phone = TextEditingController();
String dialCode ="";
  bool isCorrect = false;
  bool visible = false,error = true;
  Timer timer= Timer(const Duration(seconds: 1),(){});
  double val =0;
  bool displayFront = true;
  bool flipXAxis =true;
  final formKey = GlobalKey<FormState>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  bool showFrontSide =true;
  var otpCtrl = Get.isRegistered<OtpController>() ? Get.find<OtpController>() :Get.put(OtpController());

  PhoneNumber number = PhoneNumber(isoCode: 'IN');

  // CHECK VALIDATION

  void checkValidation() async {

    if (phone.text.isNotEmpty) {
      dismissKeyboard();
      mobileNumber = false;
      otpCtrl.onVerifyCode(phone.text,dialCode);
      Get.to(() => Otp(),transition: Transition.downToUp,arguments: phone.text);

    }else{
      mobileNumber = true;
    }
    update();
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
    dismissKeyboard();
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(Get.context!).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    update();

    super.onReady();
  }
}
