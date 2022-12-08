import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_theme/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  bool emailValidate = false;
  bool passwordValidation = false;
  bool nameValidation = false;
  bool confirmPasswordValidation = false;
  bool passEye = true, confirmPassEye = true;

  TextEditingController nameText = TextEditingController();
  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();
  TextEditingController confirmPasswordText = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
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

// CLEAR TEXT
  cleartext() {
    emailText.text = "";
    passwordText.text = "";
  }

// EYE TOGGLE

  void toggle() {
    passEye = !passEye;
    update();
  }

  //confirm
  void confirmToggle(val) {
    confirmPassEye = !confirmPassEye;
    update();
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

// SIGN UP IN FIREBASE
  Future<User?> signUp(email, password) async {
    try {
      var user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      assert(await user.user?.getIdToken() != null);
      userRegister(user.user);
      cleartext();
      Get.back();
      return user.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        final snackBar = SnackBar(
          content: const Text('The account already exists for that email.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
        log('The account already exists for that email.');
      }
    } catch (e) {
      log("catch : $e");
    } finally {}
    return null;
  }

  //REGISTER USER DATA
  void userRegister(User? user) async {
    String token = firebaseMessaging.getToken().toString();

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'chattingWith': null,
      'id': user.uid,
      'image': user.photoURL ?? "",
      'name': user.displayName ?? nameText.text,
      'pushToken': token,
      'status': "Online",
      "typeStatus": "Online",
      "phone": user.phoneNumber ?? "",
      "email": user.email,
      "statusDesc":"Hello, I am using Chatter"
    });
  }
}
