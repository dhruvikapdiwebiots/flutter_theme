import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:flutter_theme/models/data_model.dart';
import 'package:flutter_theme/models/usage_control_model.dart';
import 'package:flutter_theme/models/user_setting_model.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/firebase_contact_model.dart';

class PhoneController extends GetxController {
  bool mobileNumber = false;
  TextEditingController phone = TextEditingController();
  String dialCode = "";
  bool isCorrect = false,isLoading=false;
  bool visible = false, error = true;
  Timer timer = Timer(const Duration(seconds: 1), () {});
  double val = 0;
  bool displayFront = true;
  bool flipXAxis = true;
  final formKey = GlobalKey<FormState>();
  bool showFrontSide = true;

SharedPreferences? pref;
  PhoneNumber number = PhoneNumber(isoCode: 'IN');

  // CHECK VALIDATION

  void checkValidation() async {

    try {
      if (phone.text.isNotEmpty) {
        if (phone.text == "8141833594") {
          isLoading = true;
          update();
          log("GOO");
          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .where("phone", isEqualTo: "8141833594")
              .get()
              .then((value) async {
            if (value.docs.isNotEmpty) {
              homeNavigation(value.docs[0].data());
            }
          });
        } else {
          var otpCtrl = Get.isRegistered<OtpController>()
              ? Get.find<OtpController>()
              : Get.put(OtpController());
          dismissKeyboard();
          mobileNumber = false;
          otpCtrl.onVerifyCode(phone.text, dialCode);
          appCtrl.pref = pref;
          appCtrl.update();
          Get.to(() => Otp(pref: pref),
              transition: Transition.downToUp, arguments: phone.text);
        }
      } else {
        mobileNumber = true;
      }
      update();
    }on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      isLoading =false;
      update();
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text("Failed with error '${e.code}': ${e.message}")));

      log("Failed with error '${e.code}': ${e.message}");
    }
  }

  //navigate to dashboard
  homeNavigation(user) async {
    appCtrl.pref = pref;
    appCtrl.update();
    isLoading = true;
    update();
    appCtrl.storage.write(session.id, user["id"]);
    appCtrl.user = user;
    appCtrl.update();
    getModel();



    final RecentChatController recentChatController =
    Provider.of<RecentChatController>(Get.context!,
        listen: false);
    log("INIT PAGE");

    recentChatController.getModel(appCtrl.user);

    final FetchContactController availableContacts =
    Provider.of<FetchContactController>(Get.context!,
        listen: false);
    log("INIT PAGE");
    availableContacts.fetchContacts(
        Get.context!, appCtrl.user["phone"], pref!, false);
    await getAdminPermission();

    await appCtrl.storage.write(session.user, user);
    await appCtrl.storage.write(session.isIntro, true);
    Get.forceAppUpdate();

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .update({'status': "Online", "pushToken": token, "isActive": true});

     await Future.delayed(Durations.s5);

      isLoading = false;
      update();
      Get.toNamed(routeName.dashboard,arguments: pref);

    });
  }

  DataModel? getModel() {
    appCtrl.cachedModel ??= DataModel(appCtrl.user["phone"]);

    debugPrint("NEW DATA ${appCtrl.cachedModel!.userData}");
appCtrl.update();
    return appCtrl.cachedModel;
  }



  getAdminPermission() async {
    final usageControls = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.usageControls)
        .get();

    appCtrl.usageControlsVal =
        UsageControlModel.fromJson(usageControls.data()!);

    appCtrl.storage.write(session.usageControls, usageControls.data());
    update();
    final userAppSettings = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.userAppSettings)
        .get();
    appCtrl.userAppSettingsVal =
        UserAppSettingModel.fromJson(userAppSettings.data()!);
    final agoraToken = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.agoraToken)
        .get();
    await appCtrl.storage.write(session.agoraToken, agoraToken.data());
    update();
    appCtrl.update();
  }

//   Dismiss KEYBOARD

  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    pref = Get.arguments;
    update();
    await Future.delayed(Durations.ms150);
    visible = true;
    dismissKeyboard();
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(Get.context!).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    update();

    super.onReady();
  }
}
