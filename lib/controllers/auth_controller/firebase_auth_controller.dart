import 'dart:developer';

import 'package:flutter_theme/config.dart';


class FirebaseAuthController extends GetxController {

  var firebaseAuth = FirebaseAuth.instance;
  bool isLoading = false;

  var auth = FirebaseAuth.instance;


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
          Get.toNamed(routeName.editProfile,
              arguments: {"resultData": resultData, "isPhoneLogin": false});
        } else {
          homeNavigation(resultData);
        }
      });
    } catch (e) {
      log("catch : $e");
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

      dynamic resultData = await getUserData(user.user!);
      if (resultData["phone"] == "") {
        Get.toNamed(routeName.editProfile,
            arguments: {"resultData": resultData, "isPhoneLogin": false});
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
  Future<User?> signUp(email, password, name) async {
    try {
      var user = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      assert(await user.user?.getIdToken() != null);
      userRegister(user.user!, name: name);
      Get.back();
      return user.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        final snackBar = SnackBar(
            content: Text(fonts.accountAlreadyExists.tr),
            action: SnackBarAction(
                label: fonts.undo.tr,
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
    await appCtrl.storage.write(session.id, user["id"]);
    await appCtrl.storage.write(session.user, user);
    FirebaseFirestore.instance
        .collection('users')
        .doc(user["id"])
        .update({'status': "Online"});

    Get.toNamed(routeName.dashboard);
  }

  //register user
  userRegister(User user, {String? name}) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async {
      FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user.email)
          .limit(1)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(content: Text(fonts.emailAlreadyExist.tr)));
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'chattingWith': null,
            'id': user.uid,
            'image': user.photoURL ?? "",
            'name': user.displayName ?? name,
            'pushToken': token,
            'status': "Offline",
            "typeStatus": "Offline",
            "phone": user.phoneNumber ?? "",
            "email": user.email,
            "deviceName": appCtrl.deviceName,
            "device": appCtrl.device,
            "statusDesc": "Hello, I am using Chatter"
          });
        }
      });
    });
  }
}
