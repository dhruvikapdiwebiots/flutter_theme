

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

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {


        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName =androidInfo.model;
        print('Running on ${androidInfo.model}');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName =iosInfo.utsname.machine.toString();
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
