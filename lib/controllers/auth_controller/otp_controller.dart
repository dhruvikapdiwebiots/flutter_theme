
import 'package:flutter_theme/config.dart';


class OtpController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  TextEditingController otp = TextEditingController();

  bool isCodeSent = false;
  String? verificationCode, mobileNumber;

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

  homeNavigation(user) async {
    print(user);
    appCtrl.storage.write("id", user["id"]);
    await appCtrl.storage.write("user", user);
    await  FirebaseFirestore.instance
        .collection('users')
        .doc(user["id"])
        .update({'status': "Online"});

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
          homeNavigation(value.user);
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
        codeSent: (String verificationId, int? resendToken) async {
          verificationCode = verificationId;
          var phoneUser = FirebaseAuth.instance.currentUser;
          update();

        },
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  //on form submit
  void onFormSubmitted() async {
    print(otp.text);
    print(verificationCode);
    AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verificationCode!, smsCode: otp.text);
    print("authCredential : $authCredential");
    firebaseAuth
        .signInWithCredential(authCredential)
        .then((UserCredential value) async{
      if (value.user != null) {
        User user = value.user!;
        FirebaseFirestore.instance.collection("users").where("phone",isEqualTo: mobileNumber).get().then((value) async{
          if (value.docs.isNotEmpty) {

            if (value.docs[0].data()["name"] == "") {
              Get.toNamed(routeName.editProfile, arguments: value.docs[0].data());
            } else {
              homeNavigation(value.docs[0].data());
            }
          }else{
            await userRegister(user);
            dynamic resultData = await getUserData(user);
            if (resultData["name"] == "") {
              Get.toNamed(routeName.editProfile, arguments: resultData);
            } else {
              homeNavigation(resultData);
            }
          }
        });
      } else {
        showToast(fonts.otpError.tr, Colors.red);

      }
    }).catchError((error) {
      print("error : $error");
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
        "phone": mobileNumber,
        "email": user.email,
        "deviceName":appCtrl.deviceName,
        "device":appCtrl.device,
        "statusDesc":"Hello, I am using Chatter"
      });
    });
  }

}
