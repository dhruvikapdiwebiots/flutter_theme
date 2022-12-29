import 'dart:async';
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
    var user = appCtrl.storage.read("user") ?? "";

    if(user == "") {
      Get.offAllNamed(routeName.phone);
    }else{
      Get.offAllNamed(routeName.dashboard);
    }

  }

  //check whether user login or not
  void navigationPage() async {
    var user = appCtrl.storage.read("user")??"";

    bool isIntro = appCtrl.storage.read("isIntro") ?? false;

    if (user == "") {
      // Checking if user is already login or not
     Get.toNamed(routeName.phone);
    } else {
      if(isIntro ==true) {
        loginNavigation(); // navigate to homepage if user id is not null
      }else{
        Get.toNamed(routeName.intro);
      }

    }
  }

}