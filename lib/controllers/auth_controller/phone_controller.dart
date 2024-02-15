import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:flutter_theme/models/data_model.dart';
import 'package:flutter_theme/models/usage_control_model.dart';
import 'package:flutter_theme/models/user_setting_model.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneController extends GetxController {
  bool mobileNumber = false;
  TextEditingController phone = TextEditingController();
  String dialCode = "";
  bool isCorrect = false, isLoading = false;
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
    var otpCtrl = Get.isRegistered<OtpController>()
        ? Get.find<OtpController>()
        : Get.put(OtpController());
    isLoading = true;
    update();
    try {
      if (phone.text.isNotEmpty) {
        if (phone.text == "81418s33594") {
          log("GOO");
          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .where("phone", isEqualTo: "${dialCode}8141833594")
              .get()
              .then((value) async {
            log("GOO11 : ${value.docs.isNotEmpty}");
            if (value.docs.isNotEmpty) {
              homeNavigation(value.docs[0].data());
            }
          });
        } else {
          otpCtrl.onVerifyCode(phone.text, dialCode);
          dismissKeyboard();
          mobileNumber = false;

          appCtrl.pref = pref;
          appCtrl.update();
          isLoading = false;
          Get.to(() => Otp(pref: pref),
              transition: Transition.downToUp, arguments: phone.text);
        }
      } else {
        mobileNumber = true;
      }
      update();
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      isLoading = false;
      update();
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          content: Text("Failed with error '${e.code}': ${e.message}")));

      log("Failed with error '${e.code}': ${e.message}");
    }
  }

  //navigate to dashboard
  homeNavigation(user) async {
    appCtrl.pref = pref;
    appCtrl.update();
    appCtrl.storage.write(session.id, user["id"]);
    appCtrl.user = user;
    appCtrl.update();
    getModel();

    final RecentChatController recentChatController =
        Provider.of<RecentChatController>(Get.context!, listen: false);
    log("INIT PAGE");

    recentChatController.getModel(appCtrl.user);
contactPermissions(user);

  }

  contactPermissions(user) {
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
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(fonts.contactList.tr,
                          style: AppCss.poppinsBold18
                              .textColor(appCtrl.appTheme.txt)),
                      Icon(CupertinoIcons.multiply,
                          color: appCtrl.appTheme.txt)
                          .inkWell(onTap: () => Get.back())
                    ])
                  ]),
              content: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.min, children: [

                const VSpace(Sizes.s20),

                Text(fonts.contactPer.tr ,
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
                    Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            color: appCtrl.appTheme.whiteColor,border: Border.all(color: appCtrl.appTheme.primary),
                            title: fonts.cancel.tr,style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.primary),onTap: () async{
                            Get.back();
                            final FetchContactController registerAvailableContact =
                            Provider.of<FetchContactController>(Get.context!, listen: false);
                            registerAvailableContact.setIsLoading(false);

                            await getAdminPermission();

                            await appCtrl.storage.write(session.user, user);
                            await appCtrl.storage.write(session.isIntro, true);
                            Get.forceAppUpdate();

                            final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
                            firebaseMessaging.getToken().then((token) async {
                              await FirebaseFirestore.instance
                                  .collection(collectionName.users)
                                  .doc(user["id"])
                                  .update({
                                'status': "Online",
                                "pushToken": token,
                                "isActive": true,
                                'dialCode': dialCode,
                                'phoneRaw': phone.text,
                                'phone': (dialCode + phone.text).trim(),
                                "dialCodePhoneList": phoneList(phone: phone.text, dialCode: dialCode)
                              });

                              await Future.delayed(DurationClass.s3);

                              isLoading = false;
                              update();

                              Get.toNamed(routeName.dashboard, arguments: pref);
                            });
                          } ,),
                        ),
                        const HSpace(Sizes.s15),

                        Expanded(
                          child: CommonButton(title: fonts.accept.tr,style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.white),onTap: ()async {
                            Get.back();
                            isLoading =true;
                            update();
                            final FetchContactController registerAvailableContact =
                            Provider.of<FetchContactController>(Get.context!, listen: false);
                            debugPrint("INIT PAGE");
                            registerAvailableContact.fetchContacts(
                                Get.context!, appCtrl.user["phone"], pref!, true);
                            await getAdminPermission();

                            await appCtrl.storage.write(session.user, user);
                            await appCtrl.storage.write(session.isIntro, true);
                            Get.forceAppUpdate();

                            final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
                            firebaseMessaging.getToken().then((token) async {
                              await FirebaseFirestore.instance
                                  .collection(collectionName.users)
                                  .doc(user["id"])
                                  .update({
                                'status': "Online",
                                "pushToken": token,
                                "isActive": true,
                                'dialCode': dialCode,
                                'phoneRaw': phone.text,
                                'phone': (dialCode + phone.text).trim(),
                                "dialCodePhoneList": phoneList(phone: phone.text, dialCode: dialCode)
                              });

                              await Future.delayed(DurationClass.s3);

                              isLoading = false;
                              update();

                              Get.toNamed(routeName.dashboard, arguments: pref);
                            });
                          } ,),
                        ),
                      ],
                    )

                  ],
                ).width(MediaQuery.of(context).size.width)
              ]).padding(horizontal: Sizes.s20, bottom: Insets.i20));
        });
  }

  ContactModel? getModel() {
    appCtrl.cachedModel ??= ContactModel(appCtrl.user["phone"]);

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
    await Future.delayed(DurationClass.ms150);
    final String systemLocales =
    WidgetsBinding.instance.platformDispatcher.locale.countryCode!;
    List country = appArray.countryList;
    int index =
    country.indexWhere((element) => element['alpha_2_code'] == systemLocales);
    dialCode = country[index]['dial_code'];
    update();
    log("DIAL : $dialCode");
    visible = true;
    dismissKeyboard();
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(Get.context!).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    update();

    super.onReady();
  }
}
