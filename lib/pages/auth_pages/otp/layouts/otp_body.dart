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
            ),
            const VSpace(Sizes.s30),
            PinInputTextField(
              pinLength: 6,

              decoration: CirclePinDecoration(
                textStyle: AppCss.poppinsMedium18.textColor(appCtrl.appTheme.blackColor),
                bgColorBuilder: PinListenColorBuilder(
                    appCtrl.appTheme.grey.withOpacity(.5),
                    appCtrl.appTheme.grey.withOpacity(.5)),
                hintTextStyle: TextStyle(color: appCtrl.appTheme.whiteColor),
                hintText: "000000",
                gapSpace: 6,
                strokeColorBuilder: PinListenColorBuilder(
                    appCtrl.appTheme.grey.withOpacity(.5),
                    appCtrl.appTheme.grey.withOpacity(.5)),
              ),
              controller: otpCtrl.otp,
              textInputAction: TextInputAction.done,
              onSubmit: (pin) {
                if (pin.length == 6) {
                  otpCtrl.onFormSubmitted();
                }
              },
              onChanged: (String value) {
                if (value.length == 6) {
                  otpCtrl.onFormSubmitted();
                }
              },
              focusNode: FocusNode(),
            ),
            const VSpace(Sizes.s30),

            //done button
            CommonButton(
                title: fonts.done.tr.toUpperCase(),
                radius: AppRadius.r25,
                onTap: () => otpCtrl.onFormSubmitted(),
                style: AppCss.poppinsMedium18
                    .textColor(appCtrl.appTheme.whiteColor)),
            const VSpace(Sizes.s10)
          ]);
    });
  }
}
