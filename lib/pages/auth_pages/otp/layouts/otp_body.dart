import 'package:flutter/gestures.dart';

import '../../../../config.dart';

class OtpBody extends StatelessWidget {
  const OtpBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (otpCtrl) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //verify number
            Text(fonts.verifyMobileNumber.tr,
                style: AppCss.poppinsMedium18
                    .textColor(appCtrl.appTheme.blackColor)),
            const VSpace(Sizes.s10),

            //otp contain
            Text(
              fonts.otpContain.tr,
              textAlign: TextAlign.center,
              style: AppCss.poppinsMedium14
                  .textColor(appCtrl.appTheme.blackColor.withOpacity(.5)),
            ).marginSymmetric(horizontal: Insets.i40),
            const VSpace(Sizes.s30),
            const OtpInput(),
            const VSpace(Sizes.s30),

            //done button
            CommonButton(
                title: fonts.done.tr.toUpperCase(),
                radius: AppRadius.r25,
                onTap: () => otpCtrl.onFormSubmitted(),
                style: AppCss.poppinsMedium18
                    .textColor(appCtrl.appTheme.whiteColor)),
            const VSpace(Sizes.s25),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "Didn't Receive Code? ",
                    style:
                        AppCss.poppinsMedium16.textColor(appCtrl.appTheme.txt),
                    children: <TextSpan>[
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => otpCtrl.onVerifyCode(
                                otpCtrl.mobileNumber, otpCtrl.dialCodeVal),
                          text: "Resend",
                          style: AppCss.poppinsMedium16
                              .textColor(appCtrl.appTheme.txt)
                              .textDecoration(TextDecoration.underline))
                    ])).alignment(Alignment.center)
          ]);
    });
  }
}
