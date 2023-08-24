import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/config.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:flutter_theme/models/data_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/usage_control_model.dart';
import '../../models/user_setting_model.dart';

class SplashController extends GetxController {
  final storage = GetStorage();
  final Connectivity connectivity = Connectivity();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);
  SharedPreferences? pref;

  @override
  void onReady() {
    // TODO: implement onReady
    //Firebase.initializeApp();
    startTime();
    final key = encrypt.Key.fromUtf8('my 32 length key................');
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted =
        encrypter.encrypt("Jenish created this group", iv: iv).base64;
    log("ENCRYP : $encrypted}");
    super.onReady();
  }

  // START TIME
  startTime() async {
    late ConnectivityResult result;

    result = await connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return Get.to(NoInternet(connectionStatus: result),
          transition: Transition.downToUp);
    } else {
      var duration =
          const Duration(seconds: 3); // time delay to display splash screen
      return Timer(duration, navigationPage);
    }
  }

  //navigate to login page
  loginNavigation() async {
    /*await checkPermission();
    await Future.delayed(Durations.s1);*/
    var user = storage.read(session.user) ?? "";

    if (user == "" || user == null) {
      Get.offAllNamed(routeName.phone, arguments: pref);
    } else {
      log("PRED : $pref");

      Get.offAllNamed(routeName.dashboard, arguments: pref);
    }

    appCtrl.update();
    Get.forceAppUpdate();
    log("SPLASH : ${appCtrl.contactList}");
  }

  //check whether user login or not
  void navigationPage() async {
    await getAdminPermission();

    //language
    appCtrl.languageVal = storage.read(session.languageCode) ?? "en";
    if (appCtrl.languageVal == "en") {
      var locale = const Locale("en", 'US');
      Get.updateLocale(locale);
      appCtrl.currVal = 0;
    } else if (appCtrl.languageVal == "ar") {
      var locale = const Locale("ar", 'AE');
      Get.updateLocale(locale);
      appCtrl.currVal = 1;
    } else if (appCtrl.languageVal == "hi") {
      var locale = const Locale("hi", 'IN');
      Get.updateLocale(locale);

      appCtrl.currVal = 2;
    } else {
      var locale = const Locale("ko", 'KR');
      Get.updateLocale(locale);
      appCtrl.currVal = 3;
    }

    appCtrl.storage.write(session.languageCode, appCtrl.languageVal);

    //theme check
    bool loadThemeFromStorage = storage.read(session.isDarkMode) ?? false;
    if (loadThemeFromStorage) {
      appCtrl.isTheme = true;
    } else {
      appCtrl.isTheme = false;
    }

    update();
    await storage.write(session.isDarkMode, appCtrl.isTheme);
    ThemeService().switchTheme(appCtrl.isTheme);

    appCtrl.update();
    Get.forceAppUpdate();

    var user = storage.read(session.user);
    bool isIntro = storage.read(session.isIntro) ?? false;
    bool isBiometric = storage.read(session.isBiometric) ?? false;
    log("isIntro : $isIntro");
    log("isBiometric : $isBiometric");
    log("isBiometric : $user");

    if (user == "" && user == null) {
      // Checking if user is already login or not
      Get.toNamed(routeName.phone, arguments: pref);
    } else {
      appCtrl.user = user;
      appCtrl.update();
      //
      PermissionStatus permission = await Permission.contacts.status;
      log("permissionpermission :: $user");
      final RecentChatController recentChatController =
          Provider.of<RecentChatController>(Get.context!, listen: false);
      if (user != null) {
        recentChatController.getModel(user);
      }
      if (permission.isGranted) {
        final FetchContactController availableContacts =
            Provider.of<FetchContactController>(Get.context!, listen: false);
        availableContacts.fetchContacts(
            Get.context!, appCtrl.user["phone"], pref!, false);

        await Future.delayed(Durations.s1);
      }

      if (isIntro == true && isIntro.toString() == "true") {
        if (isBiometric == true) {
          Get.toNamed(routeName.fingerLock, arguments: pref);
        } else {
          loginNavigation(); // navigate to homepage if user id is not null
        }
      } else {
        Get.toNamed(routeName.intro, arguments: pref);
      }
    }
  }

  DataModel? getModel(user) {
    appCtrl.cachedModel ??= DataModel(user["phone"]);

    appCtrl.update();
    return appCtrl.cachedModel;
  }

  getAdminPermission() async {
    final usageControls = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.usageControls)
        .get();
    log("admin 3: ${usageControls.data()}");
    appCtrl.usageControlsVal =
        UsageControlModel.fromJson(usageControls.data()!);

    appCtrl.update();
    appCtrl.storage.write(session.usageControls, usageControls.data());
    update();
    final userAppSettings = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.userAppSettings)
        .get();
    log("admin 4: ${userAppSettings.data()}");
    appCtrl.userAppSettingsVal =
        UserAppSettingModel.fromJson(userAppSettings.data()!);
    final agoraToken = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.agoraToken)
        .get();
    await appCtrl.storage.write(session.agoraToken, agoraToken.data());
    log("admin 5: ${agoraToken.data()}");
    log("admin 6: ${appCtrl.usageControlsVal!.statusDeleteTime!.replaceAll(" hrs", "")}");
    update();
    appCtrl.update();
    Get.forceAppUpdate();
  }
}
