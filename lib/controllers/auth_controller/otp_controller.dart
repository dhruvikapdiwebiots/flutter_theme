import 'dart:async';
import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/firebase_contact_model.dart';
import 'package:flutter_theme/models/usage_control_model.dart';
import 'package:flutter_theme/models/user_setting_model.dart';
import 'package:flutter_theme/utilities/helper.dart';

class OtpController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final focusNode = FocusNode();
  Duration myDuration = Duration(seconds: 60);
  TextEditingController otp = TextEditingController();
  double val = 0;
  bool isCodeSent = false, isCountDown = true;
  String? verificationCode, mobileNumber, dialCodeVal;
  bool isValid = false;
  Timer? countdownTimer;

  @override
  void onReady() {
    // TODO: implement onReady
    mobileNumber = Get.arguments;

    update();
    super.onReady();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
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

    appCtrl.storage.write(session.id, user["id"]);
    await appCtrl.storage.write(session.user, user);
    appCtrl.user = user;
    appCtrl.update();
    await appCtrl.storage.write(session.isIntro, true);
    Get.forceAppUpdate();
helper.hideLoading();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .update({'status': "Online", "pushToken": token, "isActive": true});

      Get.toNamed(routeName.dashboard);
      await checkPermission();
    });
  }

  checkPermission() async {
    final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
        ? Get.find<PermissionHandlerController>()
        : Get.put(PermissionHandlerController());
    bool permissionStatus =
    await permissionHandelCtrl.permissionGranted();
    debugPrint("permissionStatus 1: $permissionStatus");
    if (permissionStatus == true) {
      appCtrl.contactList = await getAllContacts();

      appCtrl.storage.write(session.contactList, appCtrl.contactList);
      appCtrl.update();
      debugPrint("PERR : ${appCtrl.contactList.length}");
      await checkContactList();

      if (appCtrl.contactList.isNotEmpty) {
        await addContactInFirebase();
        final contactCtrl = Get.isRegistered<ContactListController>()
            ? Get.find<ContactListController>()
            : Get.put(ContactListController());
        contactCtrl.getAllData();
        contactCtrl.getAllUnRegisterUser();
        contactCtrl.onReady();

        contactCtrl.update();
        Get.forceAppUpdate();
      }
    }
  }

  checkContactList() async {
    appCtrl.userContactList = [];
    appCtrl.firebaseContact = [];
    appCtrl.update();

    debugPrint("appCtrl.user : ${appCtrl.user}");
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .get()
        .then((value) async {
      if (appCtrl.contactList.isNotEmpty) {
        value.docs.asMap().entries.forEach((users) {
          if (users.value["phone"] != appCtrl.user["phone"]) {
            appCtrl.contactList.asMap().entries.forEach((element) {
              if (element.value.phones.isNotEmpty) {
                if (users.value.data()["phone"] ==
                    phoneNumberExtension(
                        element.value.phones[0].number.toString())) {
                  appCtrl.userContactList.add(element.value);
                }
              }
            });
          }
          appCtrl.update();
        });
      }
    });
    debugPrint("appCtrl.userContactList : ${appCtrl.userContactList}");
    update();
  }

  addContactInFirebase() async {
    if (appCtrl.contactList.isNotEmpty) {
      List<Map<String, dynamic>> contactsData = [];
      List<Map<String, dynamic>> unRegisterContactData = [];

      appCtrl.contactList.asMap().entries.forEach((contact) async {
        bool isRegister = false;
        String id = "";
        await FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("phone",
            isEqualTo: phoneNumberExtension(
                contact.value.phones[0].number.toString()))
            .get()
            .then((value) {
          if (value.docs.isEmpty) {
            isRegister = false;
          } else {
            isRegister = true;
            id = value.docs[0].id;
          }
        });
        update();
        if (isRegister) {
          var objData = {
            'name': contact.value.displayName,
            'phone': contact.value.phones.isNotEmpty
                ? phoneNumberExtension(
                contact.value.phones[0].number.toString())
                : null,
            "isRegister": true,
            "image": contact.value.photo,
            "id": id
            // Include other necessary contact.value details
          };
          if (!contactsData.contains(objData)) {
            contactsData.add(objData);
          }
        } else {
          var objData = {
            'name': contact.value.displayName,
            'phone': contact.value.phones.isNotEmpty
                ? phoneNumberExtension(
                contact.value.phones[0].number.toString())
                : null,
            "isRegister": false,
            "image": contact.value.photo,
            "id": "0"
            // Include other necessary contact.value details
          };
          if (!unRegisterContactData.contains(objData)) {
            unRegisterContactData.add(objData);
          }
        }
      });

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.registerUser)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {

          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(appCtrl.user["id"])
              .collection(collectionName.registerUser)
              .add({"contact": contactsData});
        } else {
          log("ALREADY COLLECTION");
        }
      });

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.unRegisterUser)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {

          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(appCtrl.user["id"])
              .collection(collectionName.unRegisterUser)
              .add({"contact": unRegisterContactData});
        } else {
          log("ALREADY COLLECTION");
        }
      }).then((value) => checkContactList());

    }

    if (appCtrl.firebaseContact.isEmpty) {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.registerUser)
          .get()
          .then((value) {
        List allUserList = value.docs[0].data()["contact"];
        allUserList.asMap().entries.forEach((element) {
          if (!appCtrl.firebaseContact.contains(element.value)) {
            appCtrl.firebaseContact
                .add(FirebaseContactModel.fromJson(element.value));
          }
        });
      });
      appCtrl.update();
    }
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

    log("verificationCode : $verificationCode");
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
                  "isPhoneLogin": true
                });
              } else {
                await appCtrl.storage.write(session.user, value.docs[0].data());
                homeNavigation(value.docs[0].data());
              }
            } else {
              log("check1 : ${value.docs.isEmpty}");
              await userRegister(user);
              dynamic resultData = await getUserData(user);
              if (resultData["name"] == "") {
                Get.toNamed(routeName.editProfile, arguments: {
                  "resultData": resultData,
                  "isPhoneLogin": true
                });
                await appCtrl.storage.write(session.user, value.docs[0].data());
              } else {
                await appCtrl.storage.write(session.user, resultData);
                homeNavigation(resultData);
              }
            }
            helper.hideLoading();
            update();
          }).catchError((err) {
            log("get : $err");
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
          "isActive": true,
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
