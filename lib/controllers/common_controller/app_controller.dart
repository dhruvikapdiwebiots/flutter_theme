

import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

import '../../config.dart';

class AppController extends GetxController {
  AppTheme _appTheme = AppTheme.fromType(ThemeType.light);
  final storage = GetStorage();
  AppTheme get appTheme => _appTheme;
  int selectedIndex = 0;
  bool isTheme = false;
  bool isRTL = false;
  String languageVal = "in";
  List drawerList = [];
  int currVal = 1;
  String deviceName= "";
  String device= "";
  dynamic userAppSettingsVal;
  dynamic usageControlsVal;


//list of bottommost page
  List<Widget> widgetOptions = <Widget>[

  ];

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

  //get data from storage
  getData()async{
    //theme check
    bool loadThemeFromStorage = storage.read('isDarkMode') ?? false;
    if (loadThemeFromStorage) {
      isTheme = true;
    } else {
      isTheme = false;
    }

    update();
    await storage.write("isDarkMode", isTheme);
    ThemeService().switchTheme(isTheme);
    update();
    Get.forceAppUpdate();
  }

  getAdminPermission()async{
    final usageControls =await FirebaseFirestore.instance.collection(collectionName.admin).doc(collectionName.usageControls).get();
    log("admin : ${usageControls.data()}");
    usageControlsVal = usageControls.data();
    appCtrl.storage.write(session.usageControls, usageControls.data());
    update();
    final userAppSettings =await FirebaseFirestore.instance.collection(collectionName.admin).doc(collectionName.userAppSettings).get();
    log("admin : ${userAppSettings.data()}");
    userAppSettingsVal = userAppSettings.data();
    appCtrl.storage.write(session.userAppSettings, userAppSettings.data());
    update();
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {


        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName =androidInfo.model;
        device ="android";
        print('Running on ${androidInfo.model}');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName =iosInfo.utsname.machine.toString();
        device ="ios";
        print('Running on ${iosInfo.utsname.machine}');  // e.g.
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    update();
  }

}
