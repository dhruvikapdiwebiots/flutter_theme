import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/firebase_contact_model.dart';
import 'package:flutter_theme/utilities/helper.dart';

class EditProfileController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  dynamic user;
  bool emailValidate = false;
  bool nameValidation = false;
  bool phoneValidation = false;
  bool statusValidation = false;

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
  String imageUrl = "";
  var userId = '';

  homeNavigation(userid) async {
    helper.hideLoading();
    await storage.write(session.id, userid);
    FirebaseFirestore.instance
        .collection('users')
        .doc(user["id"])
        .update({'status': "Online"});
    Get.offAllNamed(routeName.dashboard);
    if(isPhoneLogin ==true){
      log("CHACNGE");
      await checkPermission();
    }
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
            ScaffoldMessenger.of(Get.context!)
                .showSnackBar(
                const SnackBar(content: Text("Email Already Exist")));
          } else {
            FirebaseFirestore.instance.collection(collectionName.users)
                .doc(user["id"])
                .update(
                {
                  'image': imageUrl,
                  'name': nameText.text,
                  'status': "Online",
                  "typeStatus": "",
                  "phone": phoneText.text,
                  "email": emailText.text,
                  "statusDesc": statusText.text,
                  "pushToken": token,
                  "isActive":true
                })
                .then((result) async {
              debugPrint("new USer true");
              FirebaseFirestore.instance.collection(collectionName.users)
                  .doc(user["id"])
                  .get()
                  .then((value) async {
                await storage.write("id", user["id"]);
                await storage.write(session.user, value.data());
                appCtrl.user = value.data();
                appCtrl.update();
              });

              Get.toNamed(routeName.dashboard);
              if(isPhoneLogin ==true){
                await checkPermission();
              }
            }).catchError((onError) {
              debugPrint("onError");
            });
          }
        });
      } else {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("email", isEqualTo: emailText.text)
            .limit(1)
            .get()
            .then((value) {
          FirebaseFirestore.instance.collection(collectionName.users).doc(user["id"]).update(
              {
                'image': imageUrl,
                'name': nameText.text,
                'status': "Online",
                "typeStatus": "",
                "phone": phoneText.text,
                "email": emailText.text,
                "statusDesc": statusText.text,
                "pushToken": token,
                "isActive":true
              }).then((result) async {
            debugPrint("new USer true");
            FirebaseFirestore.instance.collection(collectionName.users).doc(user["id"])
                .get()
                .then((value) async {
              await storage.write(session.id, user["id"]);
              await storage.write(session.user, value.data());
              appCtrl.user = value.data();
              appCtrl.update();
            });
            Get.toNamed(routeName.dashboard);
          }).catchError((onError) {
            debugPrint("onError");
          });
        });
      }
      isLoading = false;
      update();
    });
  }

  @override
  void onReady() {
    // TODO: implement onReady
    statusText.text = "Hello, I am using Chatter";
    var data = Get.arguments;
    user = data["resultData"];
    isPhoneLogin = data["isPhoneLogin"];
    nameText.text = user["name"] ?? "";
    emailText.text = user["email"] ?? "";
    phoneText.text = user["phone"] ?? "";
    statusText.text = user["statusDesc"] ?? "";
    imageUrl = user["image"] ?? "";
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
              .doc(user["id"]).get().then((snap) async{

                await appCtrl.storage.write(session.user,snap.data());
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
