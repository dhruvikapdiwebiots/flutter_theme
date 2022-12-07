import 'package:pin_input_text_field/pin_input_text_field.dart';

import '../../../../config.dart';

class OtpBody extends StatelessWidget {
  const OtpBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(builder: (otpCtrl) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //logo
            LoginWidget().logoImage(),
            const VSpace(Sizes.s10),

            //verify number
            Text(fonts.verifyMobileNumber.tr,
                style:
                    AppCss.poppinsMedium18.textColor(appCtrl.appTheme.primary)),
            const VSpace(Sizes.s10),

            //otp contain
            Text(
              fonts.otpContain.tr,
              textAlign: TextAlign.center,
              style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.primary),
            ),
            const VSpace(Sizes.s30),
            PinInputTextField(
              pinLength: 6,
              decoration: UnderlineDecoration(
                  colorBuilder: PinListenColorBuilder(
                      appCtrl.appTheme.blackColor, appCtrl.appTheme.blackColor),
                  hintText: "000000"),
              controller: otpCtrl.otp,
              autoFocus: true,
              textInputAction: TextInputAction.done,
              onSubmit: (pin) {
                if (pin.length == 6) {
                  otpCtrl.onFormSubmitted();
                } else {
                  otpCtrl.showToast("Invalid OTP", Colors.red);
                }
              },
              onChanged: (String value) {},
              focusNode: FocusNode(),
            ),
            const VSpace(Sizes.s30),

            //done button
            CommonButton(
                title: fonts.done.tr.toUpperCase(),
                radius: AppRadius.r25,
                onTap: () {
                  if (otpCtrl.otp.text.length == 6) {
                    otpCtrl.onFormSubmitted();
                  } else {
                    otpCtrl.showToast("Invalid OTP", Colors.red);
                  }
                },
                style:
                    AppCss.poppinsMedium18.textColor(appCtrl.appTheme.accent)),
            const VSpace(Sizes.s10)
          ]);
    });
  }
}
