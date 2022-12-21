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

  final authController = Get.isRegistered<FirebaseAuthController>()
      ? Get.find<FirebaseAuthController>()
      : Get.put(FirebaseAuthController());

  final storage = GetStorage();
  var loggedIn = false;

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
  User? currentUser;
  XFile? imageFile;
  String imageUrl = "";
  var userId = '';

  homeNavigation(userid) async {
    await storage.write("id", userid);
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

  getData() async {
    userId = storage.read('id') ?? '';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user == null) {
    } else {
      homeNavigation(userId);
    }
  }

  Widget buildLoader() {
    return Positioned(
      child: isLoading
          ? Container(
              color: appCtrl.appTheme.accent.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        appCtrl.appTheme.primary)),
              ),
            )
          : Container(),
    );
  }

  updateUserData() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: emailText.text)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ScaffoldMessenger.of(Get.context!)
            .showSnackBar(const SnackBar(content: Text("Email Already Exist")));
      } else {
        FirebaseFirestore.instance.collection('users').doc(user["id"]).update({
          'image': "",
          'name': nameText.text,
          'status': "Online",
          "typeStatus": "",
          "phone": phoneText.text,
          "email": emailText.text,
          "statusDesc": statusText.text
        }).then((result) {
          log("new USer true");
          Get.offAllNamed(routeName.dashboard);
        }).catchError((onError) {
          log("onError");
        });
      }
    });

    await storage.write("id", user["id"]);
    await storage.write("user", user);
  }

  @override
  void onReady() {
    // TODO: implement onReady
    statusText.text = "Hello, I am using Chatter";
    user = Get.arguments;
    nameText.text = user["name"] ?? "";
    emailText.text = user["email"] ?? "";
    phoneText.text = user["phone"] ?? "";
    statusText.text = user["statusDesc"] ?? "";
    update();
    super.onReady();
  }

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    log("imageFile : $imageFile");
    if (imageFile != null) {
      update();
      uploadFile();
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    log("reference : $reference");
    var file = File(imageFile!.path);
    UploadTask uploadTask = reference.putFile(file);
    log("uploadTask : ${uploadTask}");
    uploadTask.then((res) {
      log("res : $res");
      res.ref.getDownloadURL().then((downloadUrl) async {
        user["image"] = imageUrl;
        await storage.write("user", user);
        imageUrl = downloadUrl;
        log(user["id"]);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user["id"])
            .update({'image': imageUrl});
        update();
        log(user["image"]);

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
