import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/theme_controller/add_fingerprint_controller.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingController extends GetxController {
  List settingList = [];
  dynamic user;
  bool isLoading = false;

  SharedPreferences? pref;

  @override
  void onReady() {
    // TODO: implement onReady
    settingList = appArray.settingList;
    user = appCtrl.storage.read(session.user) ?? "";
    pref = Get.arguments;
    log("Get.arguments : ${Get.arguments}");
    update();
    getUserData();
    super.onReady();
  }

  //get user info from firebase
  getUserData() async {
    if (appCtrl.user != null) {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(FirebaseAuth.instance.currentUser != null
              ? FirebaseAuth.instance.currentUser!.uid
              : appCtrl.user["id"])
          .get()
          .then((value) {
        if (value.exists) {
          user = value.data();
          appCtrl.storage.write(session.user, user);
        }
        update();
        appCtrl.update();
      });
    }
  }

  //edit profile page navigation
  editProfile() {
    user = appCtrl.storage.read(session.user);
    log("UUUU : $user");
    Get.toNamed(routeName.editProfile,
        arguments: {"resultData": user, "isPhoneLogin": false});
  }

  //on setting tap
  onSettingTap(index) async {
    if (index == 0) {
      language();
    } else if (index == 1) {
      final FetchContactController contactCtrl =
          Provider.of<FetchContactController>(Get.context!, listen: false);
      FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(FirebaseAuth.instance.currentUser != null
              ? FirebaseAuth.instance.currentUser!.uid
              : appCtrl.user["id"])
          .collection(collectionName.userContact)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {
          FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(FirebaseAuth.instance.currentUser != null
                  ? FirebaseAuth.instance.currentUser!.uid
                  : appCtrl.user["id"])
              .collection(collectionName.userContact)
              .add({
            'contacts':
                RegisterContactDetail.encode(contactCtrl.registerContactUser)
          });
        } else {

          if(value.docs.length > 1){
            value.docs.asMap().entries.forEach((element) {
              element.value.reference.delete();
            });
            FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(FirebaseAuth.instance.currentUser != null
                ? FirebaseAuth.instance.currentUser!.uid
                : appCtrl.user["id"])
                .collection(collectionName.userContact)
                .add({
              'contacts':
              RegisterContactDetail.encode(contactCtrl.registerContactUser)
            });
          }else {

            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(appCtrl.user["id"])
                .collection(collectionName.userContact)
                .doc(value.docs[0].id)
                .update({
              'contacts':
              RegisterContactDetail.encode(contactCtrl.registerContactUser)
            });
          }
          FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(FirebaseAuth.instance.currentUser != null
                  ? FirebaseAuth.instance.currentUser!.uid
                  : appCtrl.user["id"])
              .update({'isWebLogin': false});
        }
      });
    } else if (index == 2) {
      appCtrl.isRTL = !appCtrl.isRTL;
      appCtrl.update();
      await appCtrl.storage.write(session.isRTL, appCtrl.isRTL);
      Get.forceAppUpdate();
    } else if (index == 3) {
      appCtrl.isTheme = !appCtrl.isTheme;

      appCtrl.update();
      ThemeService().switchTheme(appCtrl.isTheme);
      await appCtrl.storage.write(session.isDarkMode, appCtrl.isTheme);
    } else if (index == 4) {
      deleteUser();
    } else if (index == 5) {
      log("appCtrl.isBiometric  : ${appCtrl.isBiometric}");
      if (appCtrl.isBiometric == false) {
        final fingerPrintCtrl = Get.isRegistered<AddFingerprintController>()
            ? Get.find<AddFingerprintController>()
            : Get.put(AddFingerprintController());
        fingerPrintCtrl.checkBiometric(isSplash: false);
        fingerPrintCtrl.getAvailableBiometric();
      } else {
        appCtrl.isBiometric = false;
        appCtrl.storage.write(session.isBiometric, false);
        appCtrl.update();
      }
      Get.forceAppUpdate();
    } else if (index == 6) {
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
      pref!.clear();
      appCtrl.pref!.clear();
      await appCtrl.storage.remove(session.user);
      await appCtrl.storage.remove(session.id);
      await appCtrl.storage.remove(session.isDarkMode);
      await appCtrl.storage.remove(session.isRTL);
      await appCtrl.storage.remove(session.languageCode);
      await appCtrl.storage.remove(session.languageCode);
      await appCtrl.storage.erase();
      Get.offAllNamed(
        routeName.phoneWrap,
      );
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
            isLoading = true;
            update();

            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(user["id"])
                .delete();
            await FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(user["id"])
                .delete();
            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(appCtrl.user["id"])
                .collection(collectionName.status)
                .get()
                .then((value) {
              for (DocumentSnapshot ds in value.docs) {
                ds.reference.delete();
              }
            });
            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(appCtrl.user["id"])
                .collection(collectionName.chats)
                .get()
                .then((value) {
              for (DocumentSnapshot ds in value.docs) {
                ds.reference.delete();
              }
            });
            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(appCtrl.user["id"])
                .collection(collectionName.messages)
                .get()
                .then((value) {
              for (DocumentSnapshot ds in value.docs) {
                ds.reference.delete();
              }
            });
            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(appCtrl.user["id"])
                .collection(collectionName.groupMessage)
                .get()
                .then((value) {
              for (DocumentSnapshot ds in value.docs) {
                ds.reference.delete();
              }
            });

            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(appCtrl.user["id"])
                .collection(collectionName.broadcastMessage)
                .get()
                .then((value) {
              for (DocumentSnapshot ds in value.docs) {
                ds.reference.delete();
              }
            });

            await appCtrl.storage.remove(session.isDarkMode);
            await appCtrl.storage.remove(session.isRTL);
            await appCtrl.storage.remove(session.languageCode);
            await appCtrl.storage.remove(session.languageCode);
            await appCtrl.storage.remove(session.user);
            await appCtrl.storage.remove(session.id);
            FirebaseAuth.instance.signOut();
            isLoading = false;
            update();
            Get.offAllNamed(routeName.phone, arguments: appCtrl.pref);
          })
        ],
      ),
    );
  }
}
