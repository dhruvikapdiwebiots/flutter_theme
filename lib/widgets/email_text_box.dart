import '../config.dart';

class EmailTextBox extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController? emailText;
  final ValueChanged<String>? onFieldSubmitted;
  final bool? emailValidate;
  const EmailTextBox({Key? key,this.emailText,this.focusNode,this.emailValidate,this.onFieldSubmitted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonTextBox(
        labelText: fonts.emailAddress.tr,
        focusNode: focusNode,
        controller: emailText,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        onFieldSubmitted: onFieldSubmitted,
        errorText: emailValidate!
            ? fonts.emailError
            : null);
  }
}
