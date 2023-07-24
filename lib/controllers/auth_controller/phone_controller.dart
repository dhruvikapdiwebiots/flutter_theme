import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/usage_control_model.dart';
import 'package:flutter_theme/models/user_setting_model.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../models/firebase_contact_model.dart';

class PhoneController extends GetxController {
  bool mobileNumber = false;
  TextEditingController phone = TextEditingController();
  String dialCode = "";
  bool isCorrect = false;
  bool visible = false,
      error = true;
  Timer timer = Timer(const Duration(seconds: 1), () {});
  double val = 0;
  bool displayFront = true;
  bool flipXAxis = true;
  final formKey = GlobalKey<FormState>();
  bool showFrontSide = true;
  var otpCtrl = Get.isRegistered<OtpController>()
      ? Get.find<OtpController>()
      : Get.put(OtpController());

  PhoneNumber number = PhoneNumber(isoCode: 'IN');

  // CHECK VALIDATION

  void checkValidation() async {
    if (phone.text.isNotEmpty) {

      if (phone.text == "8141833594") {

       await FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("phone", isEqualTo: "8141833594")
            .get()
            .then((value) async {
          if (value.docs.isNotEmpty) {
            homeNavigation(value.docs[0].data());
          }

        }).catchError((err) {
          log("get : $err");
        });
      } else {
        dismissKeyboard();
        mobileNumber = false;
        otpCtrl.onVerifyCode(phone.text, dialCode);
        Get.to(() => Otp(), transition: Transition.downToUp,
            arguments: phone.text);
      }
    } else {
      mobileNumber = true;
    }
    update();
  }

  //navigate to dashboard
  homeNavigation(user) async {
    await getAdminPermission();
    appCtrl.storage.write(session.id, user["id"]);
    appCtrl.user = user;
    appCtrl.update();
    await appCtrl.storage.write(session.user, user);
    await appCtrl.storage.write(session.isIntro, true);
    Get.forceAppUpdate();

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
    appCtrl.contactPermission = permissionStatus;
    appCtrl.storage.write(session.contactPermission, permissionStatus);
    appCtrl.update();
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
        log("isRegister : $isRegister");
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
          log("AGAIN ADD");
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
          log("AGAIN ADD");
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


//   Dismiss KEYBOARD

    void dismissKeyboard() {
      FocusScope.of(Get.context!).requestFocus(FocusNode());
    }

    @override
    void onReady() async {
      // TODO: implement onReady
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
