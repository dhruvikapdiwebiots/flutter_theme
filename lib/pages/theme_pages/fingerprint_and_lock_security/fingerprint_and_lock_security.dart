

import '../../../config.dart';
import '../../../controllers/theme_controller/add_fingerprint_controller.dart';

class FingerPrintLock extends StatelessWidget {
  final fingerLockCtr = Get.put(AddFingerprintController());

  FingerPrintLock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddFingerprintController>(builder: (_) {
      return DirectionalityRtl(
        child: WillPopScope(
          onWillPop: () async{
            return false;
          },
          child: Scaffold(
              appBar: CommonAppBar(text: fonts.fingerprintLock.tr,isBack: false,),
              backgroundColor: appCtrl.appTheme.bgColor,
              body: Column(children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(fonts.unlockWithFingerprint.tr,
                          style: AppCss.poppinsblack16.textColor(
                              appCtrl.appTheme.blackColor)),
                      const VSpace(Sizes.s5),
                      Text(fonts.unlockWithFingerprintDesc.tr,
                          textAlign: TextAlign.center,
                          style: AppCss.poppinsLight14
                              .textColor(appCtrl.appTheme.txtColor)),


                    ]),
                Image.asset(gifAssets.fingerLock)
              ]).paddingSymmetric(
                  horizontal: Insets.i20,
                  vertical: Insets.i10
              )),
        ),
      );
    });
  }
}
