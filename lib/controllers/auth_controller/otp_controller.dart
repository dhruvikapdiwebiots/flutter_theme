import 'dart:developer';

import 'package:flutter_theme/config.dart';

class OtpController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final focusNode = FocusNode();

  TextEditingController otp = TextEditingController();
  double val = 0;
  bool isCodeSent = false, isLoading = false;
  String? verificationCode, mobileNumber,dialCodeVal;
  bool isValid = false;

  @override
  void onReady() {
    // TODO: implement onReady
    mobileNumber = Get.arguments;
    update();
    //onVerifyCode(mobileNumber);
    super.onReady();
  }

// Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //navigate to dashboard
  homeNavigation(user) async {
    appCtrl.storage.write(session.id, user["id"]);
    await appCtrl.storage.write(session.user, user);
    await appCtrl.storage.write(session.isIntro, true);
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user["id"])
          .update({'status': "Online", "pushToken": token,"isActive":true});
      log('check : ${appCtrl.storage.read(session.isIntro)}');
      Get.toNamed(routeName.dashboard);
      Get.put(CreateGroupController());
    });
  }

  //show toast
  void showToast(message, Color color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  //on verify code
  void onVerifyCode(phone,dialCode) {
    mobileNumber = phone;
    dialCodeVal = dialCode;
    log("phone : $phone");
    log("phone : $dialCode");
    isCodeSent = true;
    isLoading = true;
    update();

    verificationCompleted(PhoneAuthCredential phoneAuthCredential)async {

    }

    verificationFailed(FirebaseAuthException authException) {
      showToast(authException.message, appCtrl.appTheme.redColor);
      isCodeSent = false;
      update();
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      verificationCode = verificationId;
      log("codeSent : $verificationCode");
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
    isLoading = false;
    update();
  }

  //on form submit
  void onFormSubmitted() async {
    dismissKeyboard();
    isLoading = true;
    update();

    log("verificationCode : $verificationCode");
    PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verificationCode!, smsCode: otp.text);

    firebaseAuth
        .signInWithCredential(authCredential)
        .then((UserCredential value) async {
  log("value : $value");
      if (value.user != null) {
        User user = value.user!;
        FirebaseFirestore.instance
            .collection("users")
            .where("phone", isEqualTo: mobileNumber)
            .get()
            .then((value) async {
          if (value.docs.isNotEmpty) {
            if (value.docs[0].data()["name"] == "") {
              Get.toNamed(routeName.editProfile, arguments: {
                "resultData": value.docs[0].data(),
                "isPhoneLogin": true
              });
            } else {
              await appCtrl.storage.write(session.user, value.docs[0].data());
              homeNavigation(value.docs[0].data());
            }
          } else {
            await userRegister(user);
            dynamic resultData = await getUserData(user);
            if (resultData["name"] == "") {
              Get.toNamed(routeName.editProfile,
                  arguments: {"resultData": resultData, "isPhoneLogin": true});
              await appCtrl.storage.write(session.user, value.docs[0].data());
            } else {
              await appCtrl.storage.write(session.user, resultData);
              homeNavigation(resultData);
            }
          }
          isLoading = false;
          update();
        });
      } else {
        isLoading = false;
        update();
        showToast(fonts.otpError.tr, appCtrl.appTheme.redColor);
      }
    }).catchError((error) {
      isLoading = false;
      update();
      log("err : ${error.toString()}");
      showToast(error.toString(), appCtrl.appTheme.redColor);
    });
  }

  //get data
  Future<Object?> getUserData(User user) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
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
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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
        "device": appCtrl.device,
        "statusDesc": "Hello, I am using Chatter"
      });
    });
  }
}
