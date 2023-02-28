import 'package:flutter_theme/config.dart';

class CallListController extends GetxController {
  List settingList = [];
  dynamic user;

  DateTime now = DateTime.now();

  @override
  void onReady() {
    // TODO: implement onReady
    settingList = appArray.settingList;
    user = appCtrl.storage.read(session.user) ?? "";
    update();
    super.onReady();
  }

  editProfile() {
    user = appCtrl.storage.read(session.user);

    Get.toNamed(routeName.editProfile,
        arguments: {"resultData": user, "isPhoneLogin": false});
  }
}
