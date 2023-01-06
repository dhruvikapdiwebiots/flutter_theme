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
  final authController = Get.isRegistered<FirebaseAuthController>()
      ? Get.find<FirebaseAuthController>()
      : Get.put(FirebaseAuthController());
  var firebaseAuth = FirebaseAuth.instance;

  dynamic usageControls;
  dynamic userAppSettings;

  bool isLoading = false;
  bool isLoggedIn = false;
  User? currentUser;
  var userId = '';

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

  //get storage data
  getData() async {
    var users = storage.read(session.user) ?? '';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    log("user : $users");
    if (users == "") {
      log("null");
    } else {
      dynamic resultData = await authController.getUserData(user!,
          isStorage: true, users: users);
      if (resultData["phone"] == "") {
        Get.toNamed(routeName.editProfile, arguments:  {"resultData" : resultData,"isPhoneLogin":false});
      } else {
        authController.homeNavigation(resultData);
      }
    }
  }

  // SIGN IN WITH GOOGLE
  void initiateSignIn(String type) {
    isLoading = true;
    authController.handleSignIn(type).then((result) {
      if (result == 1) {
        loggedIn = true;
        update();
      } else {}
    });
  }

  // get admin permission data
  getPermissionData() async {
    usageControls = appCtrl.storage.read(session.usageControls);
    userAppSettings = appCtrl.storage.read(session.userAppSettings);
    update();
    getData();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    getPermissionData();

    super.onReady();
  }
}
