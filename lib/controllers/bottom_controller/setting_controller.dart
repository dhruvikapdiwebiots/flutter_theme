import 'package:flutter_theme/config.dart';

class SettingController extends GetxController{
  List settingList = [];


  @override
  void onReady() {
    // TODO: implement onReady
    settingList = appArray.settingList;
    update();
    super.onReady();
  }
}