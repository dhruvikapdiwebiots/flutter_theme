import 'package:pinput/pinput.dart';

import '../../../../config.dart';

class OtpInput extends StatelessWidget {
  const OtpInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (otpCtrl) {
      return Pinput(
        controller: otpCtrl.otp,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        focusNode: otpCtrl.focusNode,
        androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
        listenForMultipleSmsOnAndroid: true,
        enableSuggestions: true,
        length: 6,
        defaultPinTheme: OtpCommon().defaultPinTheme,
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        onCompleted: (pin) {
          otpCtrl.onFormSubmitted();
          debugPrint('onCompleted: $pin');
        },
        onChanged: (value) {
          debugPrint('onChanged: $value');
        },
        cursor: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
              margin: const EdgeInsets.only(bottom: 9),
              width: Sizes.s18,
              height: 1,
              color: appCtrl.isTheme
                  ? appCtrl.appTheme.white
                  : appCtrl.appTheme.primary)
        ]),
        focusedPinTheme: OtpCommon().defaultPinTheme.copyWith(
            decoration: OtpCommon().defaultPinTheme.decoration!.copyWith(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: appCtrl.isTheme
                        ? appCtrl.appTheme.white
                        : appCtrl.appTheme.primary))),
        submittedPinTheme: OtpCommon().defaultPinTheme.copyWith(
            decoration: OtpCommon().defaultPinTheme.decoration!.copyWith(
                color: appCtrl.appTheme.white,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                    color: appCtrl.isTheme
                        ? appCtrl.appTheme.white
                        : appCtrl.appTheme.primary))),
        errorPinTheme: OtpCommon()
            .defaultPinTheme
            .copyBorderWith(border: Border.all(color: appCtrl.appTheme.redColor)),
      );
    });
  }
}
