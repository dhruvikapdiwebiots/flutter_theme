import 'dart:async';
import 'dart:developer';
import 'package:flutter_theme/config.dart';

class SplashController extends GetxController {
  final firebaseCtrl = Get.isRegistered<FirebaseCommonController>()
      ? Get.find<FirebaseCommonController>()
      : Get.put(FirebaseCommonController());
  final storage = GetStorage();
  final contactCtrl = Get.isRegistered<ContactListController>()
      ? Get.find<ContactListController>()
      : Get.put(ContactListController());


  @override
  void onReady() {
    // TODO: implement onReady
    //Firebase.initializeApp();
    startTime();
contactCtrl.fetchPage("");
contactCtrl.update();
    super.onReady();
  }

  // START TIME
  startTime() async {
    var duration =
        const Duration(seconds: 3); // time delay to display splash screen
    return Timer(duration, navigationPage);
  }

  //navigate to login page
  loginNavigation() async {
    var user = storage.read("user");

    if (user == "" || user == null) {
      Get.offAllNamed(routeName.phone);
    } else {
      Get.offAllNamed(routeName.dashboard);
    }
  }

  //check whether user login or not
  void navigationPage() async {
    print("dd : ${storage.read("languageCode")}");
    appCtrl.languageVal = storage.read(session.languageCode);
    if(appCtrl.languageVal == "en"){
      var locale = const Locale("en", 'US');
      Get.updateLocale(locale);
      appCtrl.currVal = 0;
    }else if(appCtrl.languageVal == "ar"){
      var locale = const Locale("ar", 'AE');
      Get.updateLocale(locale);
      appCtrl.currVal = 1;
    }else if(appCtrl.languageVal == "hi"){
      var locale = const Locale("hi", 'IN');
      Get.updateLocale(locale);

      appCtrl. currVal = 2;
    }else{
      var locale = const Locale("ko", 'KR');
      Get.updateLocale(locale);
      appCtrl. currVal =3;
    }
    appCtrl.update();
    Get.forceAppUpdate();

    var user = storage.read("user") ;
    log("user : $user");
    bool isIntro = storage.read("isIntro") ?? false;
    log("isIntro : $isIntro");
    if (user == "" || user == null) {
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
