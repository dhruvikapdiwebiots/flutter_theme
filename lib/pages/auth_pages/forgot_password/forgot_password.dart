

import '../../../config.dart';

class ForgotPassword extends StatelessWidget {
  final forgotPasswordCtrl = Get.put(ForgotPasswordController());

  ForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(builder: (_) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.accent,
          resizeToAvoidBottomInset: false,
          body: Column(children: <Widget>[
            VSpace(MediaQuery.of(context).padding.top),
            //back button
            CommonWidget().backIcon(),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //logo
                  LoginWidget().logoImage(),
                  const VSpace(Sizes.s10),

                  //reset password text
                  Text(fonts.resetPassword.tr,
                      textAlign: TextAlign.center,
                      style: AppCss.poppinsblack18
                          .textColor(appCtrl.appTheme.primary)),
                  const VSpace(Sizes.s10),

                  //description
                  Text(fonts.resetPasswordDesc.tr,
                      textAlign: TextAlign.center,
                      style: AppCss.poppinsMedium14
                          .textColor(appCtrl.appTheme.primary)),
                  const VSpace(Sizes.s30),

                  //email text box
                  EmailTextBox(
                      focusNode: forgotPasswordCtrl.textFocus,
                      emailValidate: forgotPasswordCtrl.textValidate,
                      emailText: forgotPasswordCtrl.controller),
                  const VSpace(Sizes.s30),

                  //done button
                  CommonButton(
                      title: fonts.done.tr,
                      radius: AppRadius.r25,
                      onTap: () => forgotPasswordCtrl.checkValidation(),
                      width: MediaQuery.of(context).size.width - Sizes.s120,
                      height: Sizes.s42,
                      style: AppCss.poppinsMedium18
                          .textColor(appCtrl.appTheme.accent)),
                  const VSpace(Sizes.s10)
                ]).paddingAll(Insets.i40)
          ]));
    });
  }
}
