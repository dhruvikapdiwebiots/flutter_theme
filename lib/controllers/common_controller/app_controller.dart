
import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/models/data_model.dart';
import 'package:flutter_theme/models/firebase_contact_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/models/user_setting_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config.dart';
import '../../models/usage_control_model.dart';

class AppController extends GetxController {
  AppTheme _appTheme = AppTheme.fromType(ThemeType.light);
  final storage = GetStorage();
  List<Contact> contactList = [];
  List<Contact> userContactList = [];
  List<FirebaseContactModel> firebaseContact =[];
  List<FirebaseContactModel> registerContact =[];
  List<FirebaseContactModel> unRegisterContact =[];
  AppTheme get appTheme => _appTheme;
  int selectedIndex = 0;
SharedPreferences? pref;


  Map<String?, String?> cachedContacts = {};
  Map<String?, String?>? allContacts =  <String, String>{};
  List<JoinedUserModel> availableContact = [];


  bool isTheme = false,isTyping =false,contactPermission = false;
  bool isBiometric = false;
  bool isRTL = false,isLoading =false,isSearch =false;
  String languageVal = "in";
  List drawerList = [];
  dynamic user;
  bool isCallStream =false;
  int currVal = 1;
  String deviceName = "";
  String device = "";
  UserAppSettingModel? userAppSettingsVal;
  AdRequest request = const AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  UsageControlModel? usageControlsVal;
  var deviceData = <String, dynamic>{};

  ContactModel? cachedModel;

//list of bottommost page
  List<Widget> widgetOptions = <Widget>[];

  //update theme
  updateTheme(theme) {
    _appTheme = theme;
    Get.forceAppUpdate();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    getData();

    initPlatformState();
    update();
    getAdminPermission();

    super.onReady();
  }


  ContactModel? getModel() {

    cachedModel ??= ContactModel(appCtrl.user["phone"]);

    debugPrint("NEW DATA ${cachedModel!.userData}");

    return cachedModel;
  }


  //get data from storage
  getData() async {

    //theme check
    bool loadThemeFromStorage = storage.read(session.isDarkMode) ?? false;
    if (loadThemeFromStorage) {
      isTheme = true;
    } else {
      isTheme = false;
    }

    update();
    await storage.write(session.isDarkMode, isTheme);
    ThemeService().switchTheme(isTheme);

    update();
    Get.forceAppUpdate();
  }

  getAdminPermission() async {
  /*  final usageControls = await FirebaseFirestore.instance
        .collection(collectionName.admin)
        .doc(collectionName.usageControls)
        .get();
    log("admin 3: ${usageControls.data()}");
    usageControlsVal = UsageControlModel.fromJson(usageControls.data()!);


    appCtrl.storage.write(session.usageControls, usageControls.data());
    update();
    final userAppSettings = await FirebaseFirestore.instance
        .collection(collectionName.admin)
        .doc(collectionName.userAppSettings)
        .get();
    log("admin 4: ${userAppSettings.data()}");
    userAppSettingsVal = UserAppSettingModel.fromJson(userAppSettings.data()!);
    final agoraToken = await FirebaseFirestore.instance
        .collection(collectionName.admin)
        .doc(collectionName.agoraToken)
        .get();
 await   appCtrl.storage.write(session.agoraToken, agoraToken.data());
    log("admin 5: ${agoraToken.data()}");
    log("admin 6: ${appCtrl.usageControlsVal!.statusDeleteTime!.replaceAll(" hrs", "")}");
    update();*/
  }

  Future<void> initPlatformState() async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName = androidInfo.model;
        device = "android";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName = iosInfo.utsname.machine.toString();
        device = "ios";
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    update();
  }
}

language() async {
  Get.generalDialog(
    pageBuilder: (context, anim1, anim2) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          height: Sizes.s280,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.r8)),
          margin: const EdgeInsets.symmetric(horizontal: Insets.i50),
          child: LanguageScreen(),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(anim1),
        child: child
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}


class JoinedUserModel {
  final String phone;
  final String? name,id;

  JoinedUserModel({
    required this.phone,
    this.name,
    this.id,
  });

  factory JoinedUserModel.fromJson(Map<String, dynamic> jsonData) {
    return JoinedUserModel(
      phone: jsonData['phone'],
      name: jsonData['name'],
      id: jsonData['id'],
    );
  }

  static Map<String, dynamic> toMap(JoinedUserModel contact) => {
    'phone': contact.phone,
    'name': contact.name,
    'id': contact.id,
  };

}
