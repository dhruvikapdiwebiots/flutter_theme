import 'dart:async';
import 'dart:developer';
import 'package:flutter_theme/config.dart';

class SplashController extends GetxController {
  final firebaseCtrl = Get.isRegistered<FirebaseCommonController>()
      ? Get.find<FirebaseCommonController>()
      : Get.put(FirebaseCommonController());
  final storage = GetStorage();

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
    var user = storage.read("user");

    if (user == "") {
      Get.offAllNamed(routeName.phone);
    } else {
      Get.offAllNamed(routeName.dashboard);
    }
  }

  //check whether user login or not
  void navigationPage() async {
    var user = storage.read("user");
    log("user : $user");
    bool isIntro = storage.read("isIntro") ?? false;
    log("isIntro : $isIntro");
    if (user == "") {
      // Checking if user is already login or not
      Get.toNamed(routeName.phone);
    } else {
      if (isIntro == true && isIntro.toString() == "true") {
        loginNavigation(); // navigate to homepage if user id is not null
      } else {
        Get.toNamed(routeName.intro);
      }
    }
  }
}
