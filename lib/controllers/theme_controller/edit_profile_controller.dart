import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_theme/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode statusFocus = FocusNode();

  final storage = GetStorage();
  var loggedIn = false;

  var auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isLoggedIn = false;
  User? currentUser;
  var userId = '';

  homeNavigation(userid) async {
    await storage.write("id", userid);
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
}
