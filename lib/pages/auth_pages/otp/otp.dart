import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/widgets/loading_component.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Otp extends StatelessWidget {
  final SharedPreferences? pref;
  final otpCtrl = Get.put(OtpController());

  Otp({Key? key,this.pref}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (_) {
otpCtrl.pref =pref;
otpCtrl.update();
      return Scaffold(
        backgroundColor: appCtrl.appTheme.whiteColor,
        body: LoadingComponent(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.i20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: appCtrl.appTheme.blackColor,
                      )
                          .inkWell(onTap: () => Get.back())
                          .paddingOnly(top: Insets.i50),
                      Image.asset(
                        imageAssets.otp,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                      ),
                      const VSpace(Sizes.s15),
                      const OtpBody(),

                      const VSpace(Sizes.s15),
                    ],
                  ),
                ),
              ),
              
            ],
          ),
        ),
      );
    });
  }
}
