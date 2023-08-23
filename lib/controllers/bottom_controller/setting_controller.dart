import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/theme_controller/add_fingerprint_controller.dart';
import 'package:launch_review/launch_review.dart';

class SettingController extends GetxController {
  List settingList = [];
  dynamic user;


  @override
  void onReady() {
    // TODO: implement onReady
    settingList = appArray.settingList;
    user = appCtrl.storage.read(session.user) ?? "";
    update();
    getUserData();
    super.onReady();
  }

  getUserData()async{
    await FirebaseFirestore.instance.collection(collectionName.users).doc( FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.uid : appCtrl.user["id"] ).get().then((value) {
      if(value.exists){
        user = value.data();
        appCtrl.storage.write(session.user, user);
      }
      update();
      appCtrl.update();
    });

  }

  editProfile() {
    user = appCtrl.storage.read(session.user);

    Get.toNamed(routeName.editProfile,
        arguments: {"resultData": user, "isPhoneLogin": false});
  }

  //on setting tap
  onSettingTap(index) async {
    if (index == 0) {
      language();
    } else if (index == 1) {
      appCtrl.isRTL = !appCtrl.isRTL;
      appCtrl.update();
      await appCtrl.storage.write(session.isRTL, appCtrl.isRTL);
      Get.forceAppUpdate();
    } else if (index == 2) {
      appCtrl.isTheme = !appCtrl.isTheme;

      appCtrl.update();
      ThemeService().switchTheme(appCtrl.isTheme);
      await appCtrl.storage.write(session.isDarkMode, appCtrl.isTheme);
    } else if (index == 3) {
      deleteUser();
    } else if (index == 4) {
      log("appCtrl.isBiometric  : ${appCtrl.isBiometric }");
      if(appCtrl.isBiometric == false) {
        final fingerPrintCtrl = Get.isRegistered<AddFingerprintController>()
            ? Get.find<AddFingerprintController>()
            : Get.put(AddFingerprintController());
        fingerPrintCtrl.checkBiometric(isSplash: false);
        fingerPrintCtrl.getAvailableBiometric();
      }else{
        appCtrl.isBiometric = false;
        appCtrl.storage.write(session.isBiometric,false);
        appCtrl.update();

      }
      Get.forceAppUpdate();
    }else if (index == 5) {
      LaunchReview.launch(
          androidAppId: appCtrl.userAppSettingsVal!.rateApp,
          iOSAppId: " ${appCtrl.userAppSettingsVal!.rateAppIos}");
    } else {
      var user = appCtrl.storage.read(session.user);

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .update({
        "status": "Offline",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      });
      FirebaseAuth.instance.signOut();
      await appCtrl.storage.remove(session.user);
      await appCtrl.storage.remove(session.id);
      await appCtrl.storage.remove(session.isDarkMode);
      await appCtrl.storage.remove(session.isRTL);
      await appCtrl.storage.remove(session.languageCode);
      await appCtrl.storage.remove(session.languageCode);
      await appCtrl.storage.erase();
      Get.offAllNamed(routeName.phone,arguments: appCtrl.pref);
    }
  }

  deleteUser() async {
    await showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        actionsPadding: const EdgeInsets.symmetric(
            vertical: Insets.i15, horizontal: Insets.i15),
        backgroundColor: appCtrl.appTheme.whiteColor,
        title: Text(fonts.deleteAccount.tr),
        content: Text(
          fonts.deleteConfirmation.tr,
          style: AppCss.poppinsMedium14
              .textColor(appCtrl.appTheme.blackColor)
              .textHeight(1.3),
        ),
        actions: [
          SizedBox(
            width: Sizes.s80,
            child: Text(
              fonts.cancel.tr,
              textAlign: TextAlign.center,
              style:
                  AppCss.poppinsMedium14.textColor(appCtrl.appTheme.whiteColor),
            )
                .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i8)
                .decorated(
                    color: appCtrl.appTheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.r25)),
          ).inkWell(onTap: () => Get.back()),
          SizedBox(
            width: Sizes.s80,
            child: Text(
              fonts.ok.tr,
              textAlign: TextAlign.center,
              style:
                  AppCss.poppinsMedium14.textColor(appCtrl.appTheme.whiteColor),
            )
                .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i8)
                .decorated(
                    color: appCtrl.appTheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.r25)),
          ).inkWell(onTap: () async {
            var user = appCtrl.storage.read(session.user);
            Get.offAllNamed(routeName.phone,arguments: appCtrl.pref);
            Get.offAllNamed(routeName.phone,arguments: appCtrl.pref);
            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(user["id"])
                .delete();
            await FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(user["id"])
                .delete();
            await FirebaseFirestore.instance
                .collection(collectionName.status)
                .doc(user["id"])
                .delete();
            FirebaseAuth.instance.signOut();
            await appCtrl.storage.remove(session.user);
            await appCtrl.storage.remove(session.id);
            await appCtrl.storage.remove(session.isDarkMode);
            await appCtrl.storage.remove(session.isRTL);
            await appCtrl.storage.remove(session.languageCode);
            await appCtrl.storage.remove(session.languageCode);
          })
        ],
      ),
    );
  }
}
