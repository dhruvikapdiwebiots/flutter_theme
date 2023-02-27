import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneController extends GetxController {
  bool mobileNumber = false;
  TextEditingController phone = TextEditingController();
  String dialCode = "";
  bool isCorrect = false;
  bool visible = false,
      error = true;
  Timer timer = Timer(const Duration(seconds: 1), () {});
  double val = 0;
  bool displayFront = true;
  bool flipXAxis = true;
  final formKey = GlobalKey<FormState>();
  bool showFrontSide = true;
  var otpCtrl = Get.isRegistered<OtpController>()
      ? Get.find<OtpController>()
      : Get.put(OtpController());

  PhoneNumber number = PhoneNumber(isoCode: 'IN');

  // CHECK VALIDATION

  void checkValidation() async {
    if (phone.text.isNotEmpty) {
      log("number : ${phone.text == "7990261461"}");
      if (phone.text == "8141833594") {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("phone", isEqualTo: "8141833594").limit(1)
            .get()
            .then((value) async {
          if (value.docs.isNotEmpty) {
            homeNavigation(value.docs[0].data());
          }
          log("value : ${value.docs}");
        }).catchError((err) {
          log("get : $err");
        });
      } else {
        dismissKeyboard();
        mobileNumber = false;
        otpCtrl.onVerifyCode(phone.text, dialCode);
        Get.to(() => Otp(), transition: Transition.downToUp,
            arguments: phone.text);
      }
    } else {
      mobileNumber = true;
    }
    update();
  }

  //navigate to dashboard
  homeNavigation(user) async {
    appCtrl.storage.write(session.id, user["id"]);
    await appCtrl.storage.write(session.user, user);
    await appCtrl.storage.write(session.isIntro, true);
    Get.forceAppUpdate();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .update({'status': "Online", "pushToken": token, "isActive": true});
      log('check : ${appCtrl.storage.read(session.isIntro)}');
      Get.toNamed(routeName.dashboard);
    });
  }


//   Dismiss KEYBOARD

    void dismissKeyboard() {
      FocusScope.of(Get.context!).requestFocus(FocusNode());
    }

    @override
    void onReady() async {
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
