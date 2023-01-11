import 'package:flutter/gestures.dart';
import 'package:pinput/pinput.dart';

import '../../../../config.dart';

class OtpBody extends StatelessWidget {
  const OtpBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (otpCtrl) {
      final defaultPinTheme = PinTheme(
        margin: EdgeInsets.zero,
        width: Sizes.s55,
        height: Sizes.s55,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(
          fontSize: Sizes.s18,
          color: Color.fromRGBO(30, 60, 87, 1),
        ),
        decoration: BoxDecoration(
          border: Border.all(color:appCtrl.isTheme ? appCtrl.appTheme.white : appCtrl.appTheme.primary),
        ),
      );

      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
        //verify number
        Text(fonts.verifyMobileNumber.tr,
            style:
                AppCss.poppinsMedium18.textColor(appCtrl.appTheme.blackColor)),
        const VSpace(Sizes.s10),

        //otp contain
        Text(
          fonts.otpContain.tr,
          textAlign: TextAlign.center,
          style: AppCss.poppinsMedium14
              .textColor(appCtrl.appTheme.blackColor.withOpacity(.5)),
        ).marginSymmetric(horizontal: Insets.i40),
        const VSpace(Sizes.s30),
        Pinput(
          controller: otpCtrl.otp,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          focusNode: otpCtrl.focusNode,
          androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsUserConsentApi,
          listenForMultipleSmsOnAndroid: true,
          enableSuggestions: true,
          length: 6,
          defaultPinTheme: PinTheme(
            width: Sizes.s55,
            height: Sizes.s55,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            textStyle: const TextStyle(
              fontSize: Sizes.s18,
              color: Color.fromRGBO(30, 60, 87, 1),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color:appCtrl.isTheme ? appCtrl.appTheme.white : appCtrl.appTheme.primary),
            ),
          ),

          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: (pin) {
            otpCtrl.onFormSubmitted();
            debugPrint('onCompleted: $pin');
          },
          onChanged: (value) {
            debugPrint('onChanged: $value');
          },
          cursor: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 9),
                width: Sizes.s18,
                height: 1,
                color: appCtrl.isTheme ? appCtrl.appTheme.white :appCtrl.appTheme.primary,
              ),
            ],
          ),

          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color:appCtrl.isTheme ? appCtrl.appTheme.white : appCtrl.appTheme.primary),
            ),
          ),
          submittedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              color: appCtrl.appTheme.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color:appCtrl.isTheme ? appCtrl.appTheme.white : appCtrl.appTheme.primary),
            ),
          ),
          errorPinTheme: defaultPinTheme.copyBorderWith(
            border: Border.all(color: Colors.redAccent),
          ),
        ),
        const VSpace(Sizes.s30),


        //done button
        CommonButton(
            title: fonts.done.tr.toUpperCase(),
            radius: AppRadius.r25,
            onTap: () => otpCtrl.onFormSubmitted(),
            style:
                AppCss.poppinsMedium18.textColor(appCtrl.appTheme.whiteColor)),
        const VSpace(Sizes.s25),
            RichText(

                textAlign: TextAlign.center,
                text: TextSpan(
                   
                    text: "Didn't Receive Code? ",
                    style: AppCss.poppinsMedium16
                        .textColor(appCtrl.appTheme.txt),
                    children: <TextSpan>[
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => otpCtrl.onVerifyCode(otpCtrl.mobileNumber, otpCtrl.dialCode),
                          text: "Resend",
                          style: AppCss.poppinsMedium16
                              .textColor(appCtrl.appTheme.txt).textDecoration(TextDecoration.underline))
                    ])).alignment(Alignment.center)

      ]);
    });
  }
}
