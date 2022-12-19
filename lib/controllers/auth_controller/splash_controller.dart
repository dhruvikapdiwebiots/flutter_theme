import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';

class SplashController extends GetxController{
  final firebaseCtrl = Get.isRegistered<FirebaseCommonController>() ? Get.find<FirebaseCommonController>() : Get.put(FirebaseCommonController());
  @override
  void onReady() {
    // TODO: implement onReady
    //Firebase.initializeApp();
    startTime();

    super.onReady();
  }

  // START TIME
  startTime() async {
    var duration =
    const Duration(seconds: 3); // timedelay to display splash screen
    return Timer(duration, navigationPage);
  }

  //navigate to login page
  loginNavigation() async {
    Get.offAllNamed(routeName.login);

  }

  //check whether user login or not
  void navigationPage() async {
    var user = appCtrl.storage.read("user");

    bool isIntro = appCtrl.storage.read("isIntro") ?? false;
    if (user == null) {
      // Checking if user is already login or not
     Get.toNamed(routeName.intro);
    } else {
      if(isIntro) {
        loginNavigation(); // navigate to homepage if user id is not null
      }else{
        Get.toNamed(routeName.intro);
      }
      firebaseCtrl.statusDeleteAfter24Hours();
    }
  }

}