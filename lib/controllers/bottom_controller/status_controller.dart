import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_theme/config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:light_compressor/light_compressor.dart' as light;

class StatusController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  List<Contact> contactList = [];
  List<Status> status = [];
  String? groupId, currentUserId, imageUrl;
  Image? contactPhoto;
  dynamic user;
  XFile? imageFile;
  List<Status> statusList = [];
  File? image;
  bool isLoading = false,isData =false;
  List selectedContact = [];
  Stream<QuerySnapshot>? stream;
  List<Status> statusListData = [];
  List<Status> statusData = [];
  BannerAd? bannerAd;
  bool bannerAdIsLoaded = false;
  Widget currentAd = const SizedBox(
    width: 0.0,
    height: 0.0,
  );
  DateTime date = DateTime.now();
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());

  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  @override
  void onReady() async {
    // TODO: implement onReady
    final data = appCtrl.storage.read(session.user) ?? "";
    if (data != "") {
      currentUserId = data["id"];
      user = data;
    }
    update();

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
    super.onReady();
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

// Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
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


  //add status
  addStatus(File file, StatusType statusType) async {
    isLoading = true;
    update();
    imageUrl = await pickerCtrl.uploadImage(file);
    if(imageUrl != "") {
      update();
      debugPrint("imageUrl : $imageUrl");
      await StatusFirebaseApi().addStatus(imageUrl, statusType.name);
    }else{
      showToast("Error while Uploading Image");
    }
    isLoading = false;
    update();
  }

  //status list

  List statusListWidget(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    List statusList = [];
    for (int a = 0; a < snapshot.data!.docs.length; a++) {
      statusList.add(snapshot.data!.docs[a].data());
    }
    return statusList;
  }


  GallerySetting gallerySetting = const GallerySetting(
    enableCamera: true,
    maximumCount: 1,
    requestType: RequestType.all,
    cameraSetting:
      CameraSetting(videoDuration: Duration(seconds: 15)),

  );

  pickAssets()async{
    log("COUNT : ${appCtrl.usageControlsVal!.maxFilesMultiShare}");
    GalleryController controller = GalleryController();
    final entities = await controller.pick(
      Get.context!,
      setting: gallerySetting,
    );
    isLoading = true;
    update();
    if (entities.isNotEmpty) {
      File? videoFile = await entities[0].file;
      File? video;
      if (entities[0].title!.contains("mp4")) {
        final light.LightCompressor lightCompressor =
        light.LightCompressor();
        final dynamic response = await lightCompressor.compressVideo(
          path: videoFile!.path,
          videoQuality: light.VideoQuality.very_low,
          isMinBitrateCheckEnabled: false,
          video: light.Video(videoName: entities[0].title!),
          android: light.AndroidConfig(
              isSharedStorage: true, saveAt: light.SaveAt.Movies),
          ios: light.IOSConfig(saveInGallery: false),
        );

        video = File(videoFile.path);
        if (response is light.OnSuccess) {
          log("videoFile!.path 1: ${getVideoSize(file: File(response.destinationPath))}}");
          video = File(response.destinationPath);
        }
      } else {
        File compressedFile = await FlutterNativeImage.compressImage(
            videoFile!.path,
            quality: 30,
            targetWidth: 600,
            targetHeight: 300,
            percentage: 20);

        log("image : ${compressedFile.lengthSync()}");

        video = File(compressedFile.path);
        if (video.lengthSync() / 1000000 > 60) {
          video = null;
          snackBar(
              "Image Should be less than ${video!.lengthSync() / 1000000 > 60}");
        }
      }

      await addStatus(
          video,
          entities[0].title!.contains("mp4")
              ? StatusType.video
              : StatusType.image);
    }
    isLoading = false;
    update();
    Get.forceAppUpdate();
  }

}
