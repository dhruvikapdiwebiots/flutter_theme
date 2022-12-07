import 'package:flutter/gestures.dart';
import 'package:flutter_theme/config.dart';

class SignupWidget {
  //lets get started text
  Widget letGetStarted() => Text(fonts.letGetStarted.tr,
      style: AppCss.poppinsSemiBold16.textColor(appCtrl.appTheme.primary));

  //signup button
  Widget signupButton({GestureTapCallback? onTap})=> CommonButton(
      title: fonts.signUp.tr,
      radius: AppRadius.r25,
      onTap:onTap,
      style:
      AppCss.poppinsMedium18.textColor(appCtrl.appTheme.accent));

  //already account
  Widget alreadyAccount() => RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: "${fonts.alreadyAccount.tr}  ",
          style: AppCss.poppinsRegular12
              .textColor(appCtrl.appTheme.primary),
          children: <TextSpan>[
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.toNamed(routeName.login),
                text: fonts.signIn.tr,
                style: AppCss.poppinsBold12
                    .textColor(appCtrl.appTheme.primary)
                    .textDecoration(TextDecoration.underline))
          ]));
}
