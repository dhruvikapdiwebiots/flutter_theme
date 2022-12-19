import 'dart:developer';

import 'package:flutter_theme/config.dart';

class FirebaseAuthController extends GetxController{
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  var firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;
  final facebookLogin = FacebookLogin(debug: true);
  var auth = FirebaseAuth.instance;

  //sign in
  Future<int> handleSignIn(String type) async {
    switch (type) {
      case "G":
        try {
          GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
          GoogleSignInAuthentication googleAuth =
          await googleSignInAccount!.authentication;
          final googleAuthCred = GoogleAuthProvider.credential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
          User? user =
              (await firebaseAuth.signInWithCredential(googleAuthCred)).user;
          await userRegister(user!);
          isLoading = false;
          dynamic resultData = await getUserData(user);
          if (resultData["phone"] == "") {
            Get.toNamed(routeName.editProfile, arguments: resultData);
          } else {
            homeNavigation(resultData);
          }

          return 1;
        } catch (error) {

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
        dynamic resultData = await getUserData(user!);
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

  Future<Object?> getUserData(User user, {isStorage = false, users}) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .doc(isStorage ? users["id"] : user.uid)
        .get();
    dynamic resultData;
    if (result.exists) {
      Map<String, dynamic>? data = result.data();
      resultData = data;
      return resultData;
    }
    return resultData;
  }


  // SIGN IN WITH EMAIL
  Future<User?> signIn(String email, String password) async {
    try {
      var user = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final User currentUser = firebaseAuth.currentUser!;
      assert(user.user!.uid == currentUser.uid);
      isLoading = false;
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


// SIGN UP IN FIREBASE
  Future<User?> signUp(email, password) async {
    try {
      var user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      assert(await user.user?.getIdToken() != null);
      userRegister(user.user!);
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
                }));

        ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
        log('The account already exists for that email.');
      }
    } catch (e) {
      log("catch : $e");
    } finally {}
    return null;
  }

  //navigate to home
  homeNavigation(user) async {
    await appCtrl.storage.write("id", user["id"]);
    await appCtrl.storage.write("user", user);
    FirebaseFirestore.instance
        .collection('users')
        .doc(user["id"])
        .update({'status': "Online"});

    Get.toNamed(routeName.dashboard);
  }



  //register user
  userRegister(User user) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'chattingWith': null,
        'id': user.uid,
        'image': user.photoURL ?? "",
        'name': user.displayName,
        'pushToken': token,
        'status': "Offline",
        "typeStatus": "Offline",
        "phone": user.phoneNumber ?? "",
        "email": user.email,
        "deviceName": appCtrl.deviceName,
        "device": appCtrl.device,
        "statusDesc": "Hello, I am using Chatter"
      });
    });
  }
}