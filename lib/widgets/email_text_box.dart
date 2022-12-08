import '../config.dart';

class EmailTextBox extends StatelessWidget {
  final FocusNode? focusNode;
  final TextEditingController? emailText;
  final ValueChanged<String>? onFieldSubmitted;
  final bool? emailValidate;
  final Widget? suffixIcon;
  final InputBorder? border;
  const EmailTextBox({Key? key,this.emailText,this.focusNode,this.emailValidate,this.onFieldSubmitted,this.suffixIcon,this.border}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonTextBox(
        labelText: fonts.emailAddress.tr,
        focusNode: focusNode,
        controller: emailText,
        textInputAction: TextInputAction.next,
        border: border,
        validator: (val){
          Pattern pattern =
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
          RegExp regex =  RegExp(pattern.toString());
          if (val!.isEmpty) {

            return fonts.emailError.tr;
          } else if (!regex.hasMatch(val)) {

            return fonts.emailValidError.tr;
          }else{
            return null;
          }
        },
        keyboardType: TextInputType.emailAddress,
        onFieldSubmitted: onFieldSubmitted,
        suffixIcon: suffixIcon,);
  }
}
