
import 'package:flutter_theme/config.dart';

class SignupController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  bool emailValidate = false;
  bool passwordValidation = false;
  bool nameValidation = false;
  bool confirmPasswordValidation = false;
  bool passEye = true, confirmPassEye = true;

  final authController = Get.isRegistered<FirebaseAuthController>()
      ? Get.find<FirebaseAuthController>()
      : Get.put(FirebaseAuthController());

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


  bool isLoading = false;
  bool isLoggedIn = false;
  User? currentUser;
  var userId = '';


// CLEAR TEXT
  cleartext() {
    emailText.text = "";
    passwordText.text = "";
    update();
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


  //REGISTER USER DATA
  void userRegister(User? user) async {
    firebaseMessaging.getToken().then((token) async {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'chattingWith': null,
        'id': user.uid,
        'image': user.photoURL ?? "",
        'name': user.displayName ?? nameText.text,
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
