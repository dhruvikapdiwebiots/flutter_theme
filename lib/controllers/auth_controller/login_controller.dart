import 'dart:async';
import 'dart:developer';

import 'package:flutter_theme/config.dart';

class LoginController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  bool emailValidate = false;
  bool passwordValidation = false;
  bool passEye = true;
  TextEditingController emailText = TextEditingController();
  TextEditingController passwordText = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final storage = GetStorage();
  var loggedIn = false;
  var firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final facebookLogin = FacebookLogin(debug: true);

  bool isLoading = false;
  bool isLoggedIn = false;
  User? currentUser;
  var userId = '';

  //navigate to home
  homeNavigation(user) async {
    await storage.write("id", user["id"]);
    await storage.write("user", user);
    Get.toNamed(routeName.dashboard);
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
    log("user : $user");
    if (user == null) {
      log("null");
    } else {
      dynamic resultData = await getUserData(user);
      if (resultData["phone"] == "") {
        Get.toNamed(routeName.editProfile, arguments: resultData);
      } else {
        homeNavigation(resultData);
      }
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

  // SIGN IN WITH GOOGLE
  void initiateSignIn(String type) {
    isLoading = true;
    _handleSignIn(type).then((result) {
      if (result == 1) {
        loggedIn = true;
        update();
      } else {}
    });
  }

  //sign in
  Future<int> _handleSignIn(String type) async {
    log('googleAuth : $type');
    switch (type) {
      case "G":
        try {
          GoogleSignInAccount? googleSignInAccount =
              await _googleSignIn.signIn();
          log('googleSignInAccount : $googleSignInAccount');
          GoogleSignInAuthentication googleAuth =
              await googleSignInAccount!.authentication;
          log('googleAuth : $googleAuth');
          final googleAuthCred = GoogleAuthProvider.credential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
          log('googleAuthCred : $googleAuthCred');
          User? user =
              (await firebaseAuth.signInWithCredential(googleAuthCred)).user;
          isLoading = false;
          dynamic resultData = await getUserData(user!);
          if (resultData["phone"] == "") {
            Get.toNamed(routeName.editProfile, arguments: resultData);
          } else {
            homeNavigation(resultData);
          }

          log("google : $user");
          return 1;
        } catch (error) {
          log('error : $error');
          isLoading = false;
          return 0;
        }
    }
    return 0;
  }

  // SIGN IN WITH ANONYMOUS
  Future<void> signInAnonymously() async {
    isLoading = true;
    try {
      await FirebaseAuth.instance.signInAnonymously();
      FirebaseAuth.instance.authStateChanges().listen((firebaseUser) async {
        isLoading = false;
        User? user = firebaseUser;
        getUserData(user!);
        dynamic resultData = await getUserData(user);
        if (resultData["phone"] == "") {
          Get.toNamed(routeName.editProfile, arguments: resultData);
        } else {
          homeNavigation(resultData);
        }
      });
    } catch (e) {
      log("catch : $e");
    }
  }

  loginWithFB() async {
    log('login');
    isLoading = false;
    final result = await facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    log("result : $result");
// Check result status
    switch (result.status) {
      case FacebookLoginStatus.success:
        final token = result.accessToken!.token;
        final facebookAuthCred = FacebookAuthProvider.credential(token);
        final user =
            (await firebaseAuth.signInWithCredential(facebookAuthCred)).user;
        dynamic resultData = await getUserData(user!);
        if (resultData["phone"] == "") {
          Get.toNamed(routeName.editProfile, arguments: resultData);
        } else {
          homeNavigation(resultData);
        }
        log("user : $user");

        break;
      case FacebookLoginStatus.cancel:
        // User cancel log in
        break;
      case FacebookLoginStatus.error:
        // Log in failed
        log('Error while log in: ${result.error}');
        break;
    }
  }

  // SIGN IN WITH EMAIL

  Future<User?> signIn(String email, String password) async {
    try {
      var user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final User currentUser = firebaseAuth.currentUser!;
      assert(user.user!.uid == currentUser.uid);
      isLoading = false;
      cleartext();
      log('login : ${user.user}');
      dynamic resultData = await getUserData(user.user!);

      if (resultData["phone"] == "") {
        Get.toNamed(routeName.editProfile, arguments: resultData);
      } else {
        homeNavigation(resultData);
      }
      return user.user;
    } catch (e) {
      isLoading = false;
      update();
      showToast("Invalid Credential");
    }
    update();
    return null;
  }

  Future<Object?> getUserData(User user) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    print("result : ${result.data()}");
    dynamic resultData;
    if (result.exists) {
      Map<String, dynamic>? data = result.data();
      resultData = data;
      return resultData;
    }
    return resultData;
  }

  @override
  void onReady() {
    // TODO: implement onReady
    getData();
    super.onReady();
  }
}
