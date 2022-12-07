import '../config.dart';

class PasswordTextBox extends StatelessWidget {
  final TextEditingController? passwordText;
  final bool? passEye, passwordValidation;
  final FocusNode? focusNode;
  final VoidCallback? onPressed;
  final String? labelText;

  const PasswordTextBox(
      {Key? key,
      this.passwordText,
      this.focusNode,
      this.passEye,
      this.onPressed,
      this.labelText,
      this.passwordValidation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonTextBox(
        controller: passwordText,
        labelText:labelText?? fonts.password.tr,
        obscureText: passEye!,
        focusNode: focusNode,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.name,
        suffixIcon: IconButton(
          iconSize: Sizes.s20,
          onPressed: onPressed,
          icon: const Icon(Icons.remove_red_eye),
        ),
        errorText: passwordValidation! ? fonts.passwordError : null);
  }
}
