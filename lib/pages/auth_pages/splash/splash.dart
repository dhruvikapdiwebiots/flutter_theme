
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config.dart';

class Splash extends StatelessWidget {
  final SharedPreferences? pref;
 final DocumentSnapshot<Map<String, dynamic>>? rm,uc;
  final splashCtrl = Get.put(SplashController());

  Splash({Key? key,this.pref,this.rm, this.uc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (_) {

      splashCtrl.pref = pref;
      splashCtrl.rm = rm;
      splashCtrl.uc = uc;
      return Scaffold(
          backgroundColor: appCtrl.appTheme.primary,
          body: Center(
              child: Image.asset(
            imageAssets.splashIcon, // replace your Splashscreen icon
            width: Sizes.s210,
          )));
    });
  }
}
