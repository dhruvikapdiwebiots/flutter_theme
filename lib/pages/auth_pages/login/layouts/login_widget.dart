import 'package:flutter/gestures.dart';

import '../../../../config.dart';

class LoginWidget {
  //common social
  Widget commonSocial(image, {GestureTapCallback? onTap, padding}) => Padding(
        padding: EdgeInsets.all(padding),
        child: InkWell(
            onTap: onTap,
            child: Image.asset(image,
                height: image == imageAssets.phone ? Sizes.s42 : Sizes.s45,
                width: image == imageAssets.phone ? Sizes.s42 : Sizes.s45)),
      );

  //logo image
  Widget logoImage() => Image.asset(imageAssets.logo,
      height: Sizes.s50, width: Sizes.s50, fit: BoxFit.cover);

  //welcome back text
  Widget welcomeBackText() => Text(fonts.welcomeBack.tr,
      style: AppCss.poppinsSemiBold16.textColor(appCtrl.appTheme.primary));

  //forgot password
  Widget forgotPasswordText() => Text(fonts.forgotPassword.tr,
      style: AppCss.poppinsBold14.textColor(appCtrl.appTheme.primary));

  //don't have account
  Widget noAccount() => RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: "${fonts.doNotHaveAccount.tr}  ",
          style: AppCss.poppinsRegular12.textColor(appCtrl.appTheme.primary),
          children: <TextSpan>[
            TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.toNamed(routeName.signup),
                text: fonts.signUp.tr,
                style: AppCss.poppinsBold12
                    .textColor(appCtrl.appTheme.primary)
                    .textDecoration(TextDecoration.underline))
          ]));

  //or layout
  Widget orLayout() =>Text("--------- or ---------",
      style:
      AppCss.poppinsMedium16.textColor(appCtrl.appTheme.primary));

  //sign in button
  Widget signInButton({GestureTapCallback? onTap}) => CommonButton(
      title: fonts.signIn.tr,
      width: MediaQuery.of(Get.context!).size.width - Sizes.s120,
      style:
      AppCss.poppinsMedium18.textColor(appCtrl.appTheme.accent),
      onTap: onTap,
      radius: AppRadius.r25,
      height: Sizes.s40);
}
