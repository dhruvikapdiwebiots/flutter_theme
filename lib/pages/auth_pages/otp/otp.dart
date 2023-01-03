import 'package:flutter_theme/config.dart';

class Otp extends StatelessWidget {
  final otpCtrl = Get.put(OtpController());

  Otp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (_) {
      return GetBuilder<PhoneController>(builder: (phoneCtrl) {
        return Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          body: Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Insets.i20, vertical: Insets.i50),
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
                      ).inkWell(onTap: () => Get.back()),
                      Image.asset(
                        imageAssets.otp,
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                      ),
                      const VSpace(Sizes.s15),
                      const Padding(
                          padding: EdgeInsets.all(Insets.i40), child: OtpBody())
                    ],
                  ),
                ),
              ),
              if (otpCtrl.isLoading) LoginLoader(isLoading: otpCtrl.isLoading)
            ],
          ),
        );
      });
    });
  }
}
