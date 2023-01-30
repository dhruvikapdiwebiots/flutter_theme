import '../../../../config.dart';

class NameTextBox extends StatelessWidget {
  final TextEditingController? nameText;
  final FocusNode? nameFocus;
  final bool? nameValidation;
  final ValueChanged<String>? onFieldSubmitted;
  final InputBorder? border;
  final Widget? suffixIcon;

  const NameTextBox(
      {Key? key,
        this.nameText,
        this.suffixIcon,
        this.nameFocus,
        this.border,
        this.nameValidation,
        this.onFieldSubmitted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonTextBox(
        controller: nameText,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        focusNode: nameFocus,
        border: border,
        validator: (val){
          if(val!.isEmpty){
            return fonts.nameError.tr;
          }else {
            return null;
          }
        },
        suffixIcon: suffixIcon,
        errorText: nameValidation! ? fonts.nameError.tr : null,
        labelText: fonts.name.tr,
        onFieldSubmitted: onFieldSubmitted);
  }
}