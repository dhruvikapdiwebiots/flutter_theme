import '../../../../config.dart';

class NameTextBox extends StatelessWidget {
  final TextEditingController? nameText;
  final FocusNode? nameFocus;
  final bool? nameValidation;
  final ValueChanged<String>? onFieldSubmitted;

  const NameTextBox(
      {Key? key,
      this.nameText,
      this.nameFocus,
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
        errorText: nameValidation! ? fonts.nameError.tr : null,
        labelText: fonts.name.tr,
        onFieldSubmitted: onFieldSubmitted);
  }
}
