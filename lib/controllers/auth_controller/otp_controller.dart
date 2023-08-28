import 'dart:async';
import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:flutter_theme/models/usage_control_model.dart';
import 'package:flutter_theme/models/user_setting_model.dart';
import 'package:flutter_theme/utilities/helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final focusNode = FocusNode();
  Duration myDuration = const Duration(seconds: 60);
  TextEditingController otp = TextEditingController();
  double val = 0;
  bool isCodeSent = false, isCountDown = true;
  String? verificationCode, mobileNumber, dialCodeVal;
  bool isValid = false;
  SharedPreferences? pref;
  Timer? countdownTimer;

  @override
  void onReady() {
    // TODO: implement onReady

    super.onReady();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    final seconds = myDuration.inSeconds - reduceSecondsBy;
    if (seconds < 0) {
      isCountDown = false;
      countdownTimer!.cancel();

    } else {
      myDuration = Duration(seconds: seconds);
    }
    update();
  }

// Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //navigate to dashboard
  homeNavigation(user) async {

    final RecentChatController recentChatController =
    Provider.of<RecentChatController>(Get.context!,
        listen: false);
    log("INIT PAGE");

    recentChatController.getModel(appCtrl.user);

    final FetchContactController registerAvailableContact =
    Provider.of<FetchContactController>(Get.context!,
        listen: false);
    log("INIT PAGE");


    registerAvailableContact.fetchContacts(
        Get.context!, appCtrl.user["phone"], pref!, false);
    helper.showLoading();
    update();
    appCtrl.pref = pref;
    appCtrl.update();


    await appCtrl.storage.write(session.isIntro, true);
    Get.forceAppUpdate();

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .update({'status': "Online", "pushToken": token, "isActive": true});
      await Future.delayed(Durations.s6);
      helper.hideLoading();
      update();

      Get.toNamed(routeName.dashboard,arguments:  pref);

    });
  }


  //show toast
  void showToast(message, Color color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: color,
        textColor: appCtrl.appTheme.whiteColor,
        fontSize: 16.0);
  }

  //on verify code
  void onVerifyCode(phone, dialCode) {
    mobileNumber = phone;
    dialCodeVal = dialCode;
    isCodeSent = true;
    helper.showLoading();
    update();

    verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {}

    verificationFailed(FirebaseAuthException authException) {
      showToast(authException.message, appCtrl.appTheme.redColor);
      isCodeSent = false;
      update();
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      verificationCode = verificationId;

      startTimer();
      update();
    }

    codeAutoRetrievalTimeout(String verificationId) {
      verificationCode = verificationId;
      update();
      log("codeAutoRetrievalTimeout : $verificationCode");
    }

    //   Change country code

    firebaseAuth.verifyPhoneNumber(
        phoneNumber: "$dialCode$mobileNumber",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    helper.hideLoading();
    update();
  }

  //on form submit
  void onFormSubmitted() async {
    dismissKeyboard();
    helper.showLoading();
    update();

    debugPrint("verificationCode : $verificationCode");
    PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verificationCode!, smsCode: otp.text);

    firebaseAuth
        .signInWithCredential(authCredential)
        .then((UserCredential value) async {

      if (value.user != null) {
        User user = value.user!;
        try {
          FirebaseFirestore.instance
              .collection(collectionName.users)
              .where("phone", isEqualTo: mobileNumber)
              .limit(1)
              .get()
              .then((value) async {
            if (value.docs.isNotEmpty) {

              if (value.docs[0].data()["name"] == "") {
                Get.toNamed(routeName.editProfile, arguments: {
                  "resultData": value.docs[0].data(),
                  "isPhoneLogin": true,
                  "pref":pref
                });
              } else {
                await appCtrl.storage.write(session.user, value.docs[0].data());

                appCtrl.storage.write(session.id, value.docs[0].data()["id"]);
                appCtrl.user = value.docs[0].data();
                appCtrl.update();

                homeNavigation(value.docs[0].data());
              }
            } else {
              log("check1 : ${value.docs.isEmpty}");
              await userRegister(user);
              dynamic resultData = await getUserData(user);
              if (resultData["name"] == "") {
                Get.toNamed(routeName.editProfile, arguments: {
                  "resultData": resultData,
                  "isPhoneLogin": true,
                  "pref":pref
                });
                await appCtrl.storage.write(session.user, value.docs[0].data());
              } else {
                await appCtrl.storage.write(session.user, resultData);
                await appCtrl.storage.write(session.user, resultData);

                appCtrl.storage.write(session.id, resultData["id"]);
                appCtrl.user = resultData;
                appCtrl.update();
                homeNavigation(resultData);
              }
            }
            update();
          });
        } on FirebaseAuthException catch (e) {
          helper.hideLoading();
          update();
          log("get firebase : $e");
        }
      } else {
        helper.hideLoading();
        update();
        showToast(fonts.otpError.tr, appCtrl.appTheme.redColor);
      }
    }).catchError((error) {
      helper.hideLoading();
      update();
      log("err : ${error.toString()}");
      showToast(error.toString(), appCtrl.appTheme.redColor);
    });
  }

  //get data
  Future<Object?> getUserData(User user) async {
    final result = await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(user.uid)
        .get();
    dynamic resultData;
    if (result.exists) {
      Map<String, dynamic>? data = result.data();
      resultData = data;
      return resultData;
    }
    return resultData;
  }

  //user register
  userRegister(User user) async {
    log(" : $user");
    try {
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      firebaseMessaging.getToken().then((token) async {
        await FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(user.uid)
            .set({
          'chattingWith': null,
          'id': user.uid,
          'image': user.photoURL ?? "",
          'name': user.displayName ?? "",
          'pushToken': token,
          'status': "Offline",
          "typeStatus": "Offline",
          "phone": mobileNumber,
          "email": user.email,
          "deviceName": appCtrl.deviceName,
          "isActive": false,
          "device": appCtrl.device,
          "statusDesc": "Hello, I am using Chatter"
        }).catchError((err) {
          log("fir : $err");
        });
      });
    } on FirebaseAuthException catch (e) {
      log("firebase : $e");
    }
  }

  getAdminPermission() async {
      final usageControls = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.usageControls)
        .get();

    appCtrl.usageControlsVal = UsageControlModel.fromJson(usageControls.data()!);


    appCtrl.storage.write(session.usageControls, usageControls.data());
    update();
    final userAppSettings = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.userAppSettings)
        .get();
      appCtrl.userAppSettingsVal = UserAppSettingModel.fromJson(userAppSettings.data()!);
    final agoraToken = await FirebaseFirestore.instance
        .collection(collectionName.config)
        .doc(collectionName.agoraToken)
        .get();
 await   appCtrl.storage.write(session.agoraToken, agoraToken.data());
    update();
    appCtrl.update();
  }
}
