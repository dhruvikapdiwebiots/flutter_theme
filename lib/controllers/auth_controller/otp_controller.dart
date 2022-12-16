
import 'package:flutter_theme/config.dart';


class OtpController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  TextEditingController otp = TextEditingController();

  bool isCodeSent = false;
  String? verificationId, mobileNumber;

  @override
  void onReady() {
    // TODO: implement onReady
    mobileNumber = Get.arguments;
    update();
    onVerifyCode();
    super.onReady();
  }

// Dismiss KEYBOARD

  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  homeNavigation(userid) async {
    appCtrl.storage.write("id", userid);
    Get.toNamed(routeName.dashboard);
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  //on verify code
  void onVerifyCode() {
    isCodeSent = true;
    update();

    verificationCompleted(AuthCredential phoneAuthCredential) {
      firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) {
        if (value.user != null) {
          // Handle loogged in state
          homeNavigation(value.user!.uid);
        } else {
          showToast(fonts.otpError.tr, Colors.red);
        }
      }).catchError((error) {
        showToast(fonts.tryAgain.tr, Colors.red);
      });
    }

    verificationFailed(FirebaseAuthException authException) {
      showToast(authException.message, Colors.red);
      isCodeSent = false;
      update();
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      verificationId = verificationId;
      update();
    }

    codeAutoRetrievalTimeout(String verificationId) {
      verificationId = verificationId;
      update();
    }

    //   Change country code
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91$mobileNumber",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  //on form submit
  void onFormSubmitted() async {
    AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: otp.text);

    firebaseAuth
        .signInWithCredential(authCredential)
        .then((UserCredential value) async{
      if (value.user != null) {
        await userRegister(value.user!);
        dynamic resultData = await getUserData(value.user!);

        if (resultData["name"] == "") {
          Get.toNamed(routeName.editProfile, arguments: resultData);
        } else {
          homeNavigation(resultData);
        }
      } else {
        showToast(fonts.otpError.tr, Colors.red);
      }
    }).catchError((error) {
      showToast(fonts.somethingWrong.tr, Colors.red);
    });
  }

  //get data
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

  //user register
  userRegister(User user)async{
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    firebaseMessaging.getToken().then((token) async{
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'chattingWith': null,
        'id': user.uid,
        'image': user.photoURL ?? "",
        'name': user.displayName ?? "",
        'pushToken': token,
        'status': "Offline",
        "typeStatus": "Offline",
        "phone": user.phoneNumber ?? "",
        "email": user.email,
        "deviceName":appCtrl.deviceName,
        "device":appCtrl.device,
        "statusDesc":"Hello, I am using Chatter"
      });
    });
  }

}
