import 'dart:developer';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/firebase_contact_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math' as math;

class CallListController extends GetxController {
  List settingList = [];
  dynamic user;
  BannerAd? bannerAd;
  bool bannerAdIsLoaded = false;
  List<FirebaseContactModel> contactList = [];
  Widget currentAd = const SizedBox(
    width: 0.0,
    height: 0.0,
  );
  DateTime now = DateTime.now();
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  @override
  void onReady() {
    // TODO: implement onReady
    settingList = appArray.settingList;
    user = appCtrl.storage.read(session.user) ?? "";
    update();

    if (bannerAd == null) {
      bannerAd = BannerAd(
          size: AdSize.banner,
          adUnitId: Platform.isAndroid
              ? appCtrl.userAppSettingsVal!.bannerAndroidId!
              : appCtrl.userAppSettingsVal!.bannerIOSId!,
          listener: BannerAdListener(
            onAdLoaded: (Ad ad) {
              log('$BannerAd loaded.');
              bannerAdIsLoaded = true;
              update();
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              log('$BannerAd failedToLoad: $error');
              ad.dispose();
            },
            onAdOpened: (Ad ad) => log('$BannerAd onAdOpened.'),
            onAdClosed: (Ad ad) => log('$BannerAd onAdClosed.'),
          ),
          request: const AdRequest())
        ..load();
      log("Home Banner : $bannerAd");
    } else {
      bannerAd!.dispose();
      buildBanner();
    }

    _getId().then((id) {
      String? deviceId = id;

      FacebookAudienceNetwork.init(
        testingId: deviceId,
        iOSAdvertiserTrackingEnabled: true,
      );
    });
    _showBannerAd();
    update();
    // callList();
    super.onReady();
  }

  editProfile() {
    user = appCtrl.storage.read(session.user);

    Get.toNamed(routeName.editProfile,
        arguments: {"resultData": user, "isPhoneLogin": false});
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // Unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // Unique ID on Android
    }
  }

  _showBannerAd() {
    log("SHOW BANNER");
    currentAd = FacebookBannerAd(
      // placementId: "YOUR_PLACEMENT_ID",
      placementId: appCtrl.userAppSettingsVal!.facebookAddAndroidId!,
      bannerSize: BannerSize.STANDARD,
      listener: (result, value) {
        log("Banner Ad: $result -->  $value");
      },
    );
    update();
    log("_currentAd : $currentAd");
  }

  buildBanner() async {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isAndroid
            ? appCtrl.userAppSettingsVal!.bannerAndroidId!
            : appCtrl.userAppSettingsVal!.bannerIOSId!,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            log('$BannerAd loaded.');
            bannerAdIsLoaded = true;
            update();
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            log('$BannerAd failedToLoad: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => log('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => log('$BannerAd onAdClosed.'),
        ),
        request: const AdRequest())
      ..load();
    log("Home Banner AGAIn: $bannerAd");
  }

  callList() async {
    int count = 0;
    FirebaseFirestore.instance
        .collection(collectionName.users)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.asMap().entries.forEach((e) {
          FirebaseFirestore.instance
              .collection(collectionName.calls)
              .doc(e.value.id)
              .collection(collectionName.collectionCallHistory)
              .get()
              .then((value) {
            count = count + value.docs.length;
            update();
            log("COUNT : $count");
          });
        });
      }
    });
  }

  //audio and video call tap
  audioVideoCallTap(isVideoCall, pData) async {
    log("pData : $pData");
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(pData["id"] == appCtrl.user["id"]
            ? pData["receiverId"]
            : pData["id"])
        .get()
        .then((value) {
      if (value.exists) {
        pData["receiverName"] = value.data()!["name"];
        pData["receiverName"] = value.data()!["name"];
        pData["receiverToken"] = value.data()!["pushToken"];
      }
      update();
    });

    await audioAndVideoCallApi(toData: pData, isVideoCall: isVideoCall);
  }

  callFromList(isVideoCall, pData) async {
    await audioAndVideoCallApi(toData: pData, isVideoCall: isVideoCall);
  }

  audioAndVideoCallApi({toData, isVideoCall}) async {
    try {
      dynamic agoraToken = appCtrl.storage.read(session.agoraToken);
      log("toData : $toData");
      var userData = appCtrl.storage.read(session.user);
      String channelId = math.Random().nextInt(1000).toString();
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      Call call = Call(
          timestamp: timestamp,
          callerId: userData["id"],
          callerName: userData["name"],
          callerPic: userData["image"],
          receiverId: toData["id"],
          receiverName: toData["name"],
          receiverPic: toData["image"],
          callerToken: userData["pushToken"],
          receiverToken: toData["pushToken"],
          channelId: channelId,
          isVideoCall: isVideoCall,
          receiver: null);
      ClientRoleType role = ClientRoleType.clientRoleBroadcaster;
      await FirebaseFirestore.instance
          .collection(collectionName.calls)
          .doc(call.callerId)
          .collection(collectionName.calling)
          .add({
        "timestamp": timestamp,
        "callerId": userData["id"],
        "callerName": userData["name"],
        "callerPic": userData["image"],
        "receiverId": toData["id"],
        "receiverName": toData["name"],
        "receiverPic": toData["image"],
        "callerToken": userData["pushToken"],
        "receiverToken": toData["pushToken"],
        "hasDialled": true,
        "channelId": channelId,
        "isVideoCall": isVideoCall,
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection(collectionName.calls)
            .doc(call.receiverId)
            .collection(collectionName.calling)
            .add({
          "timestamp": timestamp,
          "callerId": userData["id"],
          "callerName": userData["name"],
          "callerPic": userData["image"],
          "receiverId": toData["id"],
          "receiverName": toData["name"],
          "receiverPic": toData["image"],
          "callerToken": userData["pushToken"],
          "receiverToken": toData["pushToken"],
          "hasDialled": false,
          "channelId": channelId,
          "isVideoCall": isVideoCall
        }).then((value) async {
          call.hasDialled = true;
          if (isVideoCall == false) {
            firebaseCtrl.sendNotification(
                title: "Incoming Audio Call...",
                msg: "${call.callerName} audio call",
                token: call.receiverToken,
                pName: call.callerName,
                image: userData["image"],
                dataTitle: call.callerName);
            var data = {
              "channelName": call.channelId,
              "call": call,
              "role": role
            };
            Get.toNamed(routeName.audioCall, arguments: data);
          } else {
            firebaseCtrl.sendNotification(
                title: "Incoming Video Call...",
                msg: "${call.callerName} video call",
                token: call.receiverToken,
                pName: call.callerName,
                image: userData["image"],
                dataTitle: call.callerName);

            var data = {
              "channelName": call.channelId,
              "call": call,
              "role": role
            };

            Get.toNamed(routeName.videoCall, arguments: data);
          }
        });
      });
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      log("Failed with error '${e.code}': ${e.message}");
    }
  }

  getAllRegister() async {
    List allUserList = [];

    log("allUserList : ${appCtrl.firebaseContact.length}");
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .collection(collectionName.registerUser)
        .get().then((value) {
          if(value.docs.isNotEmpty){
            allUserList = value.docs[0].data()["contact"];
            allUserList.asMap().entries.forEach((element) {
             if(!contactList.contains(FirebaseContactModel.fromJson(element.value))){
               contactList.add(FirebaseContactModel.fromJson(element.value));
             }
            });
            update();
          }
          update();
    });
    log("contactList : ${contactList.length}");
  }
}
