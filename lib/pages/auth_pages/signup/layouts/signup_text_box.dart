import 'package:flutter/cupertino.dart';
import 'package:flutter_theme/config.dart';

class SignupTextBox extends StatelessWidget {
  const SignupTextBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupController>(
      builder: (signupCtrl) {
        return Column(
          children: [
            //name text box
            NameTextBox(
                onFieldSubmitted: (value) {
                  signupCtrl.fieldFocusChange(
                      context, signupCtrl.nameFocus, signupCtrl.emailFocus);
                },
                nameFocus: signupCtrl.nameFocus,
                nameText: signupCtrl.nameText,
                nameValidation: signupCtrl.nameValidation),
            const VSpace(Sizes.s16),

            //email text box
            EmailTextBox(
                emailText: signupCtrl.emailText,
                emailValidate: signupCtrl.emailValidate,
                focusNode: signupCtrl.emailFocus,
                onFieldSubmitted: (value) => signupCtrl.fieldFocusChange(
                    context,
                    signupCtrl.emailFocus,
                    signupCtrl.passwordFocus)),
            const VSpace(Sizes.s16),

            //password text box
            PasswordTextBox(
                focusNode: signupCtrl.passwordFocus,
                onPressed: () => signupCtrl.toggle(),
                passEye: signupCtrl.passEye,
                passwordText: signupCtrl.passwordText,
                passwordValidation: signupCtrl.passwordValidation),
            const VSpace(Sizes.s16),

            //confirm password text box
            PasswordTextBox(
                focusNode: signupCtrl.confirmPasswordFocus,
                onPressed: () => signupCtrl.confirmToggle(val),
                passEye: signupCtrl.confirmPassEye,
                labelText: fonts.confirmPassword.tr,
                passwordText: signupCtrl.confirmPasswordText,
                passwordValidation: signupCtrl.confirmPasswordValidation),
            const VSpace(Sizes.s20)
          ],
        );
      }
    );
  }
}
