import 'dart:async';

import 'package:flutter_theme/config.dart';

class SplashController extends GetxController{


  @override
  void onReady() {
    // TODO: implement onReady
    //Firebase.initializeApp();
    startTime();
    super.onReady();
  }

  // START TIME
  startTime() async {
    var duration =
    const Duration(seconds: 3); // timedelay to display splash screen
    return Timer(duration, navigationPage);
  }

  //navigate to login page
  loginNavigation() async {
    Get.offAllNamed(routeName.login);

  }

  //check whether user login or not
  void navigationPage() async {
    /*final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    print("AAA");
    print(user);
    if (user == null) {
      // Cheking if user is already login or not
      Navigator.of(context).pushReplacementNamed(
          INTROSLIDER); // Navigate to intro slider if user id is null
    } else {
      _loginNavigation(); // navigate to homepage if user id is not null
    }*/
  }

}