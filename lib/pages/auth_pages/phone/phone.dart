import 'package:shared_preferences/shared_preferences.dart';

import '../../../config.dart';

class PhoneLogin extends StatelessWidget {
  final SharedPreferences? preferences;
  final phoneCtrl = Get.put(PhoneController());

  PhoneLogin({Key? key, this.preferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PhoneController>(builder: (_) {
      if (preferences != null) {
        phoneCtrl.pref = preferences;
        phoneCtrl.update();
      }
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          body: Container(
              color: appCtrl.appTheme.whiteColor,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedOpacity(
                              opacity: phoneCtrl.visible ? 1.0 : 0.0,
                              duration: const Duration(seconds: 2),
                              child: Image.asset(
                                imageAssets.login1,
                                fit: BoxFit.fitWidth,
                                width: MediaQuery.of(context).size.width,
                              ).paddingSymmetric(vertical: Insets.i20)),
                          const VSpace(Sizes.s15),
                          const PhoneBody().paddingAll(Insets.i15)
                        ]),
                  ),
                  if (phoneCtrl.isLoading)
                    CommonLoader(isLoading: phoneCtrl.isLoading)
                ],
              )),
        ),
      );
    });
  }
}
