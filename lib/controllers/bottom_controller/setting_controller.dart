import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/theme_controller/add_fingerprint_controller.dart';
import 'package:launch_review/launch_review.dart';
import 'package:localstorage/localstorage.dart';
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
      Get.toNamed(routeName.language);
    } else if (index == 1) {
      final FetchContactController contactCtrl =
      Provider.of<FetchContactController>(Get.context!, listen: false);

      syncContactAlert(contactCtrl.registerContactUser.length);
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
    } else if (index == 7) {
      await deleteAppDir();
      await deleteCacheDir();
      cacheDialog();
    } else if (index == 8) {
      Get.toNamed(routeName.webView,
          arguments: {"url":"https://themes.pixelstrap.net/chatify-flutter/privacy_policy.html","isPolicy":true}
          );
    }else if (index == 9) {
      Get.toNamed(routeName.webView,
          arguments: {"url":"https://themes.pixelstrap.net/chatify-flutter/privacy_policy.html","isPolicy":false}
          );
    } else {
      var user = appCtrl.storage.read(session.user);

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .update({
        "status": "Offline",
        "lastSeen": DateTime
            .now()
            .millisecondsSinceEpoch
            .toString()
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


  /// this will delete cache
  Future<void> deleteCacheDir() async {
    Directory tempDir = await getTemporaryDirectory();
    log("tempDir.existsSync(): ${tempDir.existsSync()}");
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }

    update();
    Get.forceAppUpdate();
  }

  /// this will delete app's storage
  Future<void> deleteAppDir() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    log("tempDir.existsSync()1: ${appDocDir.existsSync()}");
    if (appDocDir.existsSync()) {
      appDocDir.deleteSync(recursive: true);
    }
    update();
    Get.forceAppUpdate();
  }

  cacheDialog() {
    showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(AppRadius.r8))),
              backgroundColor: appCtrl.appTheme.white,
              titlePadding: const EdgeInsets.all(Insets.i20),
              title: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Icon(CupertinoIcons.multiply,
                      color: appCtrl.appTheme.txt)
                      .inkWell(onTap: () => Get.back())
                ])
              ]),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset(imageAssets.successTick,
                    height: Sizes.s115, width: Sizes.s115),
                const VSpace(Sizes.s20),
                Text(fonts.successfullyCacheClear.tr,
                    style: AppCss.poppinsBold16
                        .textColor(appCtrl.appTheme.txt)),
                const VSpace(Sizes.s10),
                Text(fonts.reOpenApp.tr,
                    textAlign: TextAlign.center,
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.grey)),
                const VSpace(Sizes.s15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Divider(
                        height: 1,
                        color: appCtrl.appTheme.borderGray,
                        thickness: 1),
                    const VSpace(Sizes.s15),
                    Text(fonts.reOpen.tr,
                        style: AppCss.poppinsblack14
                            .textColor(appCtrl.appTheme.primary))
                        .inkWell(onTap: () {
                      Get.back();
                      exit(0);
                    })
                  ],
                ).width(MediaQuery
                    .of(context)
                    .size
                    .width).inkWell(onTap: () {
                  Get.back();
                  exit(0);
                })
              ]).padding(horizontal: Sizes.s20, bottom: Insets.i20));
        });
  }

  syncContactAlert(len) {
    showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(AppRadius.r8))),
              backgroundColor: appCtrl.appTheme.white,
              titlePadding: const EdgeInsets.all(Insets.i20),
              title: Column(

                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(fonts.contactSync1.tr,
                              style: AppCss.poppinsBold18
                                  .textColor(appCtrl.appTheme.txt)),
                          Icon(CupertinoIcons.multiply,
                              color: appCtrl.appTheme.txt)
                              .inkWell(onTap: () => Get.back())
                        ])
                  ]),
              content: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const VSpace(Sizes.s20),
                    Text("You have $len contacts for sync",
                        style: AppCss.poppinsSemiBold16
                            .textColor(appCtrl.appTheme.txt)),
                    const VSpace(Sizes.s15),
                    Text(fonts.syncDesc.tr,
                        style: AppCss.poppinsLight12
                            .textColor(appCtrl.appTheme.txt).textHeight(1.3)),
                    const VSpace(Sizes.s15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(
                            height: 1,
                            color: appCtrl.appTheme.borderGray,
                            thickness: 1),
                        const VSpace(Sizes.s15),
                        CommonButton(title: fonts.syncNow.tr,
                          style: AppCss.poppinsMedium14.textColor(
                              appCtrl.appTheme.white),
                          onTap: () {
                            final FetchContactController contactCtrl =
                            Provider.of<FetchContactController>(Get.context!,
                                listen: false);
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
                                    .doc(
                                    FirebaseAuth.instance.currentUser != null
                                        ? FirebaseAuth.instance.currentUser!.uid
                                        : appCtrl.user["id"])
                                    .collection(collectionName.userContact)
                                    .add({
                                  'contacts':
                                  RegisterContactDetail.encode(
                                      contactCtrl.registerContactUser)
                                });
                              } else {
                                if (value.docs.length > 1) {
                                  value.docs
                                      .asMap()
                                      .entries
                                      .forEach((element) {
                                    element.value.reference.delete();
                                  });
                                  FirebaseFirestore.instance
                                      .collection(collectionName.users)
                                      .doc(
                                      FirebaseAuth.instance.currentUser != null
                                          ? FirebaseAuth.instance.currentUser!
                                          .uid
                                          : appCtrl.user["id"])
                                      .collection(collectionName.userContact)
                                      .add({
                                    'contacts':
                                    RegisterContactDetail.encode(
                                        contactCtrl.registerContactUser)
                                  });
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection(collectionName.users)
                                      .doc(appCtrl.user["id"])
                                      .collection(collectionName.userContact)
                                      .doc(value.docs[0].id)
                                      .update({
                                    'contacts':
                                    RegisterContactDetail.encode(
                                        contactCtrl.registerContactUser)
                                  });
                                }
                                FirebaseFirestore.instance
                                    .collection(collectionName.users)
                                    .doc(
                                    FirebaseAuth.instance.currentUser != null
                                        ? FirebaseAuth.instance.currentUser!.uid
                                        : appCtrl.user["id"])
                                    .update({'isWebLogin': false});
                              }
                            });
                            Get.back();
                            Get.snackbar(fonts.success.tr, fonts.contactSync.tr,
                                backgroundColor: appCtrl.appTheme.greenColor,
                                colorText: appCtrl.appTheme.white);
                          },)

                      ],
                    ).width(MediaQuery
                        .of(context)
                        .size
                        .width)
                  ]).padding(horizontal: Sizes.s20, bottom: Insets.i20));
        });
  }

  deleteUser() async {
    await showDialog(
      context: Get.context!,
      builder: (_) =>
          AlertDialog(
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
                    .paddingSymmetric(
                    horizontal: Insets.i15, vertical: Insets.i8)
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
                    .paddingSymmetric(
                    horizontal: Insets.i15, vertical: Insets.i8)
                    .decorated(
                    color: appCtrl.appTheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.r25)),
              ).inkWell(onTap: () async {
                isLoading = true;
                update();

                isLoading = true;
                update();

                await FirebaseFirestore.instance
                    .collection(collectionName.calls)
                    .doc(appCtrl.user["id"])
                    .delete();
                await FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(appCtrl.user["id"])
                    .collection(collectionName.status)
                    .get()
                    .then((value) {
                  for (QueryDocumentSnapshot<Map<String, dynamic>> ds
                  in value.docs) {
                    Status status = Status.fromJson(ds.data());
                    List<PhotoUrl> photoUrl = status.photoUrl ?? [];
                    for (var list in photoUrl) {
                      if (list.statusType == StatusType.image.name ||
                          list.statusType == StatusType.video.name) {
                        FirebaseStorage.instance
                            .refFromURL(list.image!)
                            .delete();
                      }
                    }
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
                  for (QueryDocumentSnapshot<Map<String, dynamic>> ds
                  in value.docs) {
                    if (ds.data()["type"] == MessageType.image.name ||
                        ds.data()["type"] == MessageType.audio.name ||
                        ds.data()["type"] == MessageType.video.name ||
                        ds.data()["type"] == MessageType.doc.name ||
                        ds.data()["type"] == MessageType.gif.name ||
                        ds.data()["type"] == MessageType.imageArray.name) {
                      String url = decryptMessage(ds.data()["content"]);
                      FirebaseStorage.instance
                          .refFromURL(url.contains("-BREAK-")
                          ? url.split("-BREAK-")[0]
                          : url)
                          .delete();
                    }
                    ds.reference.delete();
                  }
                });
                await FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(appCtrl.user["id"])
                    .collection(collectionName.groupMessage)
                    .get()
                    .then((value) {
                  for (QueryDocumentSnapshot<Map<String, dynamic>> ds
                  in value.docs) {
                    if (ds.data()["type"] == MessageType.image.name ||
                        ds.data()["type"] == MessageType.audio.name ||
                        ds.data()["type"] == MessageType.video.name ||
                        ds.data()["type"] == MessageType.doc.name ||
                        ds.data()["type"] == MessageType.gif.name ||
                        ds.data()["type"] == MessageType.imageArray.name) {
                      String url = decryptMessage(ds.data()["content"]);
                      FirebaseStorage.instance
                          .refFromURL(url.contains("-BREAK-")
                          ? url.split("-BREAK-")[0]
                          : url)
                          .delete();
                    }
                    ds.reference.delete();
                  }
                });

                await FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(appCtrl.user["id"])
                    .collection(collectionName.broadcastMessage)
                    .get()
                    .then((value) {
                  for (QueryDocumentSnapshot<Map<String, dynamic>> ds
                  in value.docs) {
                    if (ds.data()["type"] == MessageType.image.name ||
                        ds.data()["type"] == MessageType.audio.name ||
                        ds.data()["type"] == MessageType.video.name ||
                        ds.data()["type"] == MessageType.doc.name ||
                        ds.data()["type"] == MessageType.gif.name ||
                        ds.data()["type"] == MessageType.imageArray.name) {
                      String url = decryptMessage(ds.data()["content"]);
                      FirebaseStorage.instance
                          .refFromURL(url.contains("-BREAK-")
                          ? url.split("-BREAK-")[0]
                          : url)
                          .delete();
                    }
                    ds.reference.delete();
                  }
                });

                await FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(appCtrl.user["id"])
                    .delete();
                await appCtrl.storage.remove(session.isDarkMode);
                await appCtrl.storage.remove(session.isRTL);
                await appCtrl.storage.remove(session.languageCode);
                await appCtrl.storage.remove(session.languageCode);
                await appCtrl.storage.remove(session.user);
                await appCtrl.storage.remove(session.id);
                FirebaseAuth.instance.signOut();
                isLoading = false;
                update();
                appCtrl.pref!.remove('storageUserString');
                appCtrl.user = null;
                appCtrl.pref = null;
                final LocalStorage storage = LocalStorage('model');
                final LocalStorage cachedContacts = LocalStorage(
                    'cachedContacts');
                final LocalStorage messageModel = LocalStorage('messageModel');
                final LocalStorage statusModel = LocalStorage('statusModel');
                await storage.clear();
                await cachedContacts.clear();

                await messageModel.clear();

                await statusModel.clear();
                Get.offAllNamed(routeName.phoneWrap,
                    arguments: appCtrl.pref);
              })
            ],
          ),
    );
  }
}
