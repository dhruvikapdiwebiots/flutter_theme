import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
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
   DocumentSnapshot<Map<String, dynamic>>? rm,uc;

  @override
  void onReady() async{
    // TODO: implement onReady
    //Firebase.initializeApp();
    startTime();



    super.onReady();
  }

  // START TIME
  startTime() async {
    late ConnectivityResult result;

    result = await connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return Get.to(NoInternet(connectionStatus: result,rm: rm,uc: uc,),
          transition: Transition.downToUp);
    } else {

      var duration =
          const Duration(seconds: 3); // time delay to display splash screen
      return Timer(duration, navigationPage);
    }
  }

  //navigate to login page
  loginNavigation() async {

    var user = storage.read(session.user) ?? "";
    appCtrl.pref = pref;
    appCtrl.update();
    if (user == "" || user == null) {
      Get.offAllNamed(routeName.phone, arguments: pref);
    } else {

      Get.offAllNamed(routeName.dashboard, arguments: pref);
    }

    appCtrl.update();
    Get.forceAppUpdate();

  }

  //check whether user login or not
  void navigationPage() async {
    await getAdminPermission();

   /* //language
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
      if(user != null ){
        getModel(appCtrl.user);
      }
      //
      PermissionStatus permission = await Permission.contacts.status;
log("permission :${permission}");
      final RecentChatController recentChatController =
          Provider.of<RecentChatController>(Get.context!, listen: false);
      if (user != null) {
        recentChatController.getModel(user);
      }
      if (permission.isGranted) {
        if(user != null ) {
          final FetchContactController registerAvailableContact =
          Provider.of<FetchContactController>(Get.context!, listen: false);
          registerAvailableContact.fetchContacts(
              Get.context!, appCtrl.user["phone"], pref ?? appCtrl.pref!, true);

          await Future.delayed(DurationClass.s1);
        }
      }else{
        final FetchContactController registerAvailableContact =
        Provider.of<FetchContactController>(Get.context!, listen: false);
        registerAvailableContact.setIsLoading(false);
        await Future.delayed(DurationClass.s1);
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

  ContactModel? getModel(user) {
    appCtrl.cachedModel ??= ContactModel(user["phone"]);
log("appCtrl.cachedModel : ${appCtrl.cachedModel}");
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

    update();
    appCtrl.update();
    Get.forceAppUpdate();*/
    var user = appCtrl.storage.read(session.user);
    appCtrl.user = user;
    appCtrl.pref = pref;
    bool permission = appCtrl.storage.read(session.contactPermission) ?? false;
    if (permission) {
      if (user != null) {
        final FetchContactController registerAvailableContact =
        Provider.of<FetchContactController>(Get.context!, listen: false);
        registerAvailableContact.fetchContacts(
            Get.context!, appCtrl.user["phone"], pref ?? appCtrl.pref!, true);
      }
    }
    bool isOnBoard = appCtrl.storage.read(session.isIntro) ?? false;
    // bool isInvite = appCtrl.storage.read('skip') ?? false;
    appCtrl.update();
    update();
    final RecentChatController recentChatController =
    Provider.of<RecentChatController>(Get.context!, listen: false);

    if (user != null) {
      recentChatController.getModel(user);
    }

    appCtrl.update();
    Get.forceAppUpdate();
    dynamic lan;
    await FirebaseFirestore.instance
        .collection(collectionName.languages)
        .doc(collectionName.defaultLanguage)
        .get().then((value) {
      if(value.exists){
        log("LANGGG :${value.data()!["language"]}");
        lan = value.data()!["language"];
      }
    });
    update();
    bool isBiometric = appCtrl.storage.read(session.isBiometric) ?? false;
    appCtrl.isBiometric = isBiometric;
/*
    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      debugPrint("CHECK NOT PERMISSION");
    } else {
      Permission.notification.request();
      update();
    }
*/
log("lanlan :$lan");
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (isOnBoard) {
        if (user == "" || user == null) {
          Get.offAllNamed(routeName.phone, arguments: pref);
        } else {
          if (user['email'] == null || user['name'] == "") {
            Get.offAllNamed(routeName.phone, arguments: pref);
          } else {
            if (isBiometric == true) {
              Get.toNamed(routeName.fingerLock, arguments: pref);
            } else {
              Get.offAllNamed(routeName.dashboard, arguments: pref);
            }
          }
        }
      } else {
        Get.offAllNamed(routeName.intro, arguments: pref);
      }
      update();
    });

    String lanCode = lan["code"].toString().split("_")[0];
    String countryCode = lan["code"].toString().split("_")[1];

    Locale? locale =  Locale(lanCode, countryCode);

    //language
    var language = await appCtrl.storage.read(session.locale) ?? lanCode;
    debugPrint("LANGUAGE1 $language");
    appCtrl.languageVal = language;
    Get.updateLocale(locale);
    appCtrl.locale = locale;
    update();
    bool isRtlSave = appCtrl.storage.read(session.isRTL) ?? false;
    bool isThemeSave = appCtrl.storage.read(session.isDarkMode) ?? false;
    appCtrl.isRTL = isRtlSave;
    ThemeService().switchTheme(isThemeSave);
    appCtrl.isTheme = isThemeSave;

    firebaseCtrl.statusDeleteAfter24Hours();
    firebaseCtrl.deleteForAllUsers();
  }

  getAdminPermission() async {
    final usageControls = rm;

    appCtrl.usageControlsVal =
        UsageControlModel.fromJson(usageControls!.data()!);

    appCtrl.update();
    appCtrl.storage.write(session.usageControls, usageControls.data());

    final userAppSettings =uc;
    log("admin 4: ${userAppSettings!.data()}");
    appCtrl.userAppSettingsVal =
        UserAppSettingModel.fromJson(userAppSettings.data()!);
    final agoraToken = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.agoraToken)
        .get();
    await appCtrl.storage.write(session.agoraToken, agoraToken.data());

    update();
    appCtrl.update();
    Get.forceAppUpdate();
  }
}
