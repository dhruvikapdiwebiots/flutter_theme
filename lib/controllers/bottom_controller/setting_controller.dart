import 'dart:developer';
import 'dart:io';

import 'package:flutter_theme/config.dart';

class SettingController extends GetxController {
  List settingList = [];
  dynamic user;


  @override
  void onReady() {
    // TODO: implement onReady
    settingList = appArray.settingList;
    user = appCtrl.storage.read("user");
    update();
    super.onReady();
  }

  editProfile() {
    user = appCtrl.storage.read("user");
    print(user);
    Get.toNamed(routeName.editProfile, arguments: user);
  }

}
