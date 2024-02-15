import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_theme/config.dart';

class NoInternet extends StatelessWidget {
  final ConnectivityResult? connectionStatus;
  final DocumentSnapshot<Map<String, dynamic>>? rm,uc;
  const NoInternet({Key? key, this.connectionStatus, this.rm, this.uc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Connectivity().onConnectivityChanged,
        builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {

          if (snapshot.data != ConnectivityResult.none ||
              snapshot.data != null) {
            final splashCtrl = Get.find<SplashController>();
            splashCtrl.onReady();
          }
          return snapshot.data == ConnectivityResult.none ||
                  snapshot.data == null
              ? Scaffold(
                  backgroundColor: appCtrl.appTheme.whiteColor,
                  body: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(imageAssets.noInternet),
                      const VSpace(Sizes.s30),
                      Text(
                        fonts.oops.tr,
                        style: AppCss.poppinsBold16
                            .textColor(appCtrl.appTheme.blackColor),
                      ),
                      const VSpace(Sizes.s6),
                      Text(
                        fonts.noInternet.tr,
                        textAlign: TextAlign.center,
                        style: AppCss.poppinsMedium14
                            .textColor(appCtrl.appTheme.txtColor),
                      )
                    ],
                  ).marginSymmetric(horizontal: Insets.i30)),
                )
              : Splash(rm: rm,uc: uc,);
        });
  }
}
