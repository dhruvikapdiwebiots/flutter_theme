import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_theme/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool emailValidate = false;
  bool passwordValidation = false;
  bool nameValidation = false;
  bool confirmPasswordValidation = false;
  bool passEye = true,confirmPassEye =true;

  TextEditingController nameText = TextEditingController();
  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();
  TextEditingController confirmPasswordText = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

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

  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

// CHECK VALIDATION

  void checkValidation() async {
    RegExp regex =  RegExp(pattern.toString());
    if (nameText.text.isEmpty) {
      nameValidation = true;
      emailValidate = false;
      passwordValidation = false;
      confirmPasswordValidation = false;
      showToast(fonts.nameError.tr);
    } else if (emailText.text.isEmpty) {
      emailValidate = true;
      passwordValidation = false;
      showToast(fonts.emailError.tr);
    } else if (!regex.hasMatch(emailText.text)) {
      emailValidate = true;
      passwordValidation = false;
      showToast(fonts.emailValidError.tr);
    } else if (passwordText.text.isEmpty) {
      emailValidate = false;
      passwordValidation = true;
      showToast(fonts.passwordError.tr);
    } else if (passwordText.text.length < 8) {
      emailValidate = false;
      passwordValidation = true;
      showToast(fonts.passwordLengthError.tr);
    } else if (confirmPasswordText.text.isEmpty) {
      emailValidate = false;
      nameValidation = false;
      passwordValidation = false;
      confirmPasswordValidation = true;
      showToast(fonts.confirmPasswordError.tr);
    } else if (confirmPasswordText.text.toString() != passwordText.text.toString()) {
      emailValidate = false;
      nameValidation = false;
      passwordValidation = false;
      confirmPasswordValidation = true;
      showToast(fonts.confirmPasswordErrorDes.tr);
    } else {
      isLoading = true;
      dismissKeyBoard();
      emailValidate = false;
      passwordValidation = false;
      signUp(emailText.text, passwordText.text);
    }
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
              valueColor: AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary)),
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
      print("user : $user");
      assert(await user.user?.getIdToken() != null);
      cleartext();
     Get.back();
      return user.user;
    }on FirebaseAuthException catch (e) {
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
    } finally {

    }
    return null;
  }


}
