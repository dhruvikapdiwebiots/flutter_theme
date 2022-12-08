import '../../../../config.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (loginCtrl) {
      return Form(
        key: loginCtrl.formKey,
        child: Column(
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
              LoginWidget()
                  .signInButton(onTap: () {
                    if(loginCtrl.formKey.currentState!.validate()){
                      loginCtrl.dismissKeyBoard();
                      loginCtrl.signIn(loginCtrl.emailText.text, loginCtrl.passwordText.text);
                    }
              }),
              const VSpace(Sizes.s12),

              //forgot password text box
              LoginWidget()
                  .forgotPasswordText()
                  .inkWell(onTap: () => Get.toNamed(routeName.forgotPassword)),
              const VSpace(Sizes.s15),

              //don't have account
              LoginWidget().noAccount(),
              const VSpace(Sizes.s15),

              //or layout
              LoginWidget().orLayout(),
              const HSpace(Sizes.s10),

              //social layout
              const SocialLayout()
            ]),
      );
    });
  }
}
