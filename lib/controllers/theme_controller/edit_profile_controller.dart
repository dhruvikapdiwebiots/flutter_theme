import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:flutter_theme/utilities/helper.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  dynamic user;
  bool emailValidate = false, isCorrect = false;
  bool nameValidation = false;
  bool phoneValidation = false;
  bool statusValidation = false;
  bool mobileNumber = false;
  PhoneNumber number = PhoneNumber(dialCode: "+91", isoCode: 'IN');

  TextEditingController nameText = TextEditingController();
  TextEditingController emailText = TextEditingController();
  TextEditingController phoneText = TextEditingController();
  TextEditingController statusText = TextEditingController();
  TextEditingController passwordText = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode statusFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  SharedPreferences? pref;

  final storage = GetStorage();
  var debugPrintgedIn = false;

  bool passwordValidation = false;
  bool passEye = true;

// EYE TOGGLE
  void toggle() {
    passEye = !passEye;
    update();
  }

  var auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isLoggedIn = false;
  bool isPhoneLogin = false;
  XFile? imageFile;
  String imageUrl = "", dialCode = "+91";
  var userId = '';

  homeNavigation(userid) async {
    contactPermissions(userid);
  }

  contactPermissions(userid) {
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fonts.contactList.tr,
                          style: AppCss.poppinsBold18
                              .textColor(appCtrl.appTheme.txt)),
                      Icon(CupertinoIcons.multiply, color: appCtrl.appTheme.txt)
                          .inkWell(onTap: () => Get.back())
                    ])
              ]),
              content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const VSpace(Sizes.s20),
                    Text(fonts.contactPer.tr,
                        style: AppCss.poppinsLight12
                            .textColor(appCtrl.appTheme.txt)
                            .textHeight(1.3)),
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
                                color: appCtrl.appTheme.whiteColor,
                                border:
                                    Border.all(color: appCtrl.appTheme.primary),
                                title: fonts.cancel.tr,
                                style: AppCss.poppinsMedium14
                                    .textColor(appCtrl.appTheme.primary),
                                onTap: () async {
                                  Get.back();
                                  final FetchContactController registerAvailableContact =
                                  Provider.of<FetchContactController>(Get.context!, listen: false);
                                  registerAvailableContact.setIsLoading(false);

                                  await appCtrl.storage
                                      .write(session.isIntro, true);
                                  await Future.delayed(DurationClass.s3);
                                  helper.hideLoading();
                                  await storage.write(session.id, userid);
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user["id"])
                                      .update({'status': "Online"});
                                  Get.offAllNamed(routeName.dashboard,
                                      arguments: pref);
                                },
                              ),
                            ),
                            const HSpace(Sizes.s15),
                            Expanded(
                              child: CommonButton(
                                title: fonts.accept.tr,
                                style: AppCss.poppinsMedium14
                                    .textColor(appCtrl.appTheme.white),
                                onTap: () async {
                                  Get.back();
                                  final FetchContactController
                                      registerAvailableContact =
                                      Provider.of<FetchContactController>(
                                          Get.context!,
                                          listen: false);
                                  log("INIT PAGEaaa");
                                  registerAvailableContact.fetchContacts(
                                      Get.context!,
                                      appCtrl.user["phone"],
                                      pref!,
                                      false);
                                  await appCtrl.storage
                                      .write(session.isIntro, true);
                                  await Future.delayed(DurationClass.s3);
                                  helper.hideLoading();
                                  await storage.write(session.id, userid);
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user["id"])
                                      .update({'status': "Online"});
                                  Get.offAllNamed(routeName.dashboard,
                                      arguments: pref);
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ).width(MediaQuery.of(context).size.width)
                  ]).padding(horizontal: Sizes.s20, bottom: Insets.i20));
        });
  }

  showToast(error) {
    Fluttertoast.showToast(msg: error);
  }

// Dismiss KEYBOARD
  void dismissKeyBoard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  // MOVE TO NEXT FOCUS FIELD
  fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  //update user
  updateUserData() async {
    isLoading = true;
    debugPrint("imageUrl : $imageUrl");
    update();
    Get.forceAppUpdate();
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      if (isPhoneLogin) {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("email", isEqualTo: emailText.text)
            .limit(1)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
                 SnackBar(content: Text(fonts.emailAlreadyExist.tr)));

            isLoading = false;
            update();
          } else {
            FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(user["id"])
                .update({
              'image': imageUrl,
              'name': nameText.text,
              'status': "Online",
              "typeStatus": "",
              "phone": (dialCode + phoneText.text).trim(),
              "dialCode": dialCode,
              "email": emailText.text,
              "dialCodePhoneList":
                  phoneList(phone: phoneText.text, dialCode: dialCode),
              "statusDesc": statusText.text,
              "pushToken": token,
              'phoneRaw': phoneText.text,
              "isActive": true
            }).then((result) async {
              debugPrint("new USer true");
              await FirebaseFirestore.instance
                  .collection(collectionName.users)
                  .doc(user["id"])
                  .get()
                  .then((value) async {
                await storage.write("id", user["id"]);
                await storage.write(session.user, value.data());
                appCtrl.user = value.data();
                appCtrl.update();
              });
              final RecentChatController recentChatController =
                  Provider.of<RecentChatController>(Get.context!,
                      listen: false);
              log("INIT PAGE1");

              recentChatController.getModel(appCtrl.user);

              final FetchContactController registerAvailableContact =
                  Provider.of<FetchContactController>(Get.context!,
                      listen: false);
              log("INIT PAGE2");
              registerAvailableContact.fetchContacts(
                  Get.context!, appCtrl.user["phone"], pref!, false);

              await Future.delayed(DurationClass.s5);

              isLoading = false;
              update();
            homeNavigation(appCtrl.user['id']);
            }).catchError((onError) {
              debugPrint("onError :: $onError");
            });
          }
        });
        isLoading = false;
        update();
      } else {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("email", isEqualTo: emailText.text)
            .limit(1)
            .get()
            .then((value) {
          FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(user["id"])
              .update({
            'image': imageUrl,
            'name': nameText.text,
            'status': "Online",
            "typeStatus": "",
            "phone": (dialCode + phoneText.text).trim(),
            "email": emailText.text,
            "statusDesc": statusText.text,
            "dialCodePhoneList":
                phoneList(phone: phoneText.text, dialCode: dialCode),
            "pushToken": token,
            'phoneRaw': phoneText.text,
            "dialCode": dialCode,
            "isActive": true
          }).then((result) async {
            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(user["id"])
                .get()
                .then((value) async {
              await storage.write(session.id, user["id"]);
              await storage.write(session.user, value.data());
              appCtrl.user = value.data();
              appCtrl.update();
            });
            final RecentChatController recentChatController =
                Provider.of<RecentChatController>(Get.context!, listen: false);
            log("INIT PAGE3");

            recentChatController.getModel(appCtrl.user);

            debugPrint("new USer true");
            final FetchContactController registerAvailableContact =
                Provider.of<FetchContactController>(Get.context!,
                    listen: false);
            log("INIT PAGE4");
            registerAvailableContact.fetchContacts(
                Get.context!, appCtrl.user["phone"], pref!, false);

            await Future.delayed(DurationClass.s5);
            Get.toNamed(routeName.dashboard, arguments: pref);

            isLoading = false;
            update();
          }).catchError((onError) {
            isLoading = false;
            update();
            debugPrint("onErrorss :: $onError");
          });
        });
      }
    });
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    statusText.text = "Hello, I am using Chatter";
    var data = Get.arguments;
    log("number : $number");
    user = data["resultData"];
    pref = data["pref"];
    dialCode = user["dialCode"] ?? "";
    isPhoneLogin = data["isPhoneLogin"];
    nameText.text = user["name"] ?? "";
    emailText.text = user["email"] ?? "";
    phoneText.text = user["phoneRaw"] ?? "";
    statusText.text = user["statusDesc"] ?? "";
    imageUrl = user["image"] ?? "";
    log("dialCode :$dialCode");

    String? isoCode = PhoneNumber.getISO2CodeByPrefix(dialCode);
    appCtrl.pref = pref;
    number = PhoneNumber(dialCode: dialCode, isoCode: isoCode);
    appCtrl.update();
    update();
    super.onReady();
  }

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    debugPrint("imageFile : $imageFile");
    if (imageFile != null) {
      update();
      uploadFile();
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    isLoading = true;
    update();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    debugPrint("reference : $reference");
    var file = File(imageFile!.path);
    UploadTask uploadTask = reference.putFile(file);

    uploadTask.then((res) {
      debugPrint("res : $res");
      res.ref.getDownloadURL().then((downloadUrl) async {
        user["image"] = imageUrl;
        await storage.write(session.user, user);
        imageUrl = downloadUrl;
        debugPrint(user["id"]);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user["id"])
            .update({'image': imageUrl}).then((value) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(user["id"])
              .get()
              .then((snap) async {
            await appCtrl.storage.write(session.user, snap.data());
            user = snap.data();
            update();
          });
        });
        isLoading = false;
        update();
        debugPrint(user["image"]);

        update();
      }, onError: (err) {
        update();
        Fluttertoast.showToast(msg: 'Image is Not Valid');
      });
    });
  }

  //image picker option
  imagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return ImagePickerLayout(cameraTap: () {
            getImage(ImageSource.camera);
            Get.back();
          }, galleryTap: () {
            getImage(ImageSource.gallery);
            Get.back();
          });
        });
  }
}
