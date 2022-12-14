import '../../../../config.dart';

class SignupBody extends StatelessWidget {
  const SignupBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(builder: (signupCtrl) {
      return Padding(
          padding: const EdgeInsets.all(Insets.i40),
          child: Form(
            key: signupCtrl.formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LoginWidget().logoImage(),
                  const VSpace(Sizes.s5),

                  //lets get started text
                  SignupWidget().letGetStarted(),
                  const VSpace(Sizes.s16),

                  //all text box
                  const SignupTextBox(),

                  //signup button
                  SignupWidget().signupButton(onTap: () async {
                    if (signupCtrl.formKey.currentState!.validate()) {
                      signupCtrl.dismissKeyBoard();
                      signupCtrl.isLoading = true;
                      signupCtrl.update();
                      await signupCtrl.authController.signUp(
                          signupCtrl.emailText.text,
                          signupCtrl.passwordText.text,signupCtrl.nameText.text);
                      signupCtrl.cleartext();
                      signupCtrl.isLoading = false;
                      signupCtrl.update();
                    }
                  }),
                  const VSpace(Sizes.s20),

                  //already account
                  SignupWidget().alreadyAccount()
                ]),
          ));
    });
  }
}
