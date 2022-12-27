
import 'dart:async';

import 'package:flip_card/flip_card.dart';
import 'package:flutter_theme/config.dart';

class PhoneController extends GetxController {
  bool mobileNumber = false;
  TextEditingController phone = TextEditingController();
  final FocusNode phoneFocus = FocusNode();
  bool isCorrect = false;
  bool visible = false,switchScreen = true;
  Timer timer= Timer(Duration(seconds: 1),(){});
  double val =0;
  bool displayFront = true;
  bool flipXAxis =true;
  final formKey = GlobalKey<FormState>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  bool showFrontSide =true;
  final otpCtrl = Get.isRegistered<OtpController>() ? Get.find<OtpController>(): Get.put(OtpController());

  // CHECK VALIDATION

  void checkValidation() async {

    if (formKey.currentState!.validate()) {
      dismissKeyboard();
      mobileNumber = false;
      otpCtrl.onVerifyCode(phone.text);
      cardKey.currentState!.toggleCard();

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
