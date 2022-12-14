import '../../../../config.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (loginCtrl) {
      return Form(
        key: loginCtrl.formKey,
        child: loginCtrl.usageControls != null && loginCtrl.usageControls != "" ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //logo
              LoginWidget().logoImage(),
              const VSpace(Sizes.s5),

              //welcome back text
              LoginWidget().welcomeBackText(),
              const VSpace(Sizes.s20),

              //email text box
              EmailTextBox(
                  emailText: loginCtrl.emailText,
                  emailValidate: loginCtrl.emailValidate,
                  focusNode: loginCtrl.emailFocus,
                  onFieldSubmitted: (value) => loginCtrl.fieldFocusChange(
                      context, loginCtrl.emailFocus, loginCtrl.passwordFocus)),
              const VSpace(Sizes.s20),

              //password text box
              PasswordTextBox(
                focusNode: loginCtrl.passwordFocus,
                onPressed: () => loginCtrl.toggle(),
                passEye: loginCtrl.passEye,
                passwordText: loginCtrl.passwordText,
                passwordValidation: loginCtrl.passwordValidation,
              ),
              const VSpace(Sizes.s20),

              //sign in button
              LoginWidget().signInButton(onTap: ()async {
                if (loginCtrl.formKey.currentState!.validate()) {
                  loginCtrl.dismissKeyBoard();
                  loginCtrl.isLoading = true;
                  loginCtrl.update();
                await  loginCtrl.authController.signIn(
                      loginCtrl.emailText.text, loginCtrl.passwordText.text);
                loginCtrl.emailText.text ="";
                loginCtrl.passwordText.text ="";
                  loginCtrl.isLoading = false ;
                loginCtrl.update();
                }
              }),
              const VSpace(Sizes.s12),

              //forgot password text box
              LoginWidget()
                  .forgotPasswordText()
                  .inkWell(onTap: () => Get.toNamed(routeName.forgotPassword)),
              const VSpace(Sizes.s15),

              if (!loginCtrl.usageControls["existence_users"])
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  //don't have account
                  LoginWidget().noAccount(),
                  const VSpace(Sizes.s15),
                ]),
              //or layout
              LoginWidget().orLayout(),
              const HSpace(Sizes.s10),

              //social layout
              const SocialLayout()
            ]):Container(),
      );
    });
  }
}
