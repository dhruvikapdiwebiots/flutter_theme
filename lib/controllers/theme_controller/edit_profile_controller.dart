import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_theme/config.dart';

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
    await storage.write(session.id, userid);
    FirebaseFirestore.instance
        .collection('users')
        .doc(user["id"])
        .update({'status': "Online"});
    Get.offAllNamed(routeName.dashboard);
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
