import 'package:flutter_theme/config.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class EditProfileTextBox extends StatelessWidget {
  const EditProfileTextBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: (editCtrl) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const VSpace(Sizes.s20),
        Text(
          fonts.userName.tr,
          style: AppCss.poppinsMedium15.textColor(appCtrl.appTheme.blackColor),
        ),
        const VSpace(Sizes.s8),
        NameTextBox(
            nameFocus: editCtrl.nameFocus,
            nameText: editCtrl.nameText,
            nameValidation: editCtrl.nameValidation),
        const VSpace(Sizes.s28),
        //email text box
        Text(
          fonts.email.tr,
          style: AppCss.poppinsMedium15.textColor(appCtrl.appTheme.blackColor),
        ),
        const VSpace(Sizes.s8),
        EmailTextBox(
            emailText: editCtrl.emailText,
            emailValidate: editCtrl.emailValidate,
            focusNode: editCtrl.emailFocus,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: appCtrl.appTheme.primary))),
        const VSpace(Sizes.s28),
        Text(
          fonts.mobileNumber.tr,
          style: AppCss.poppinsMedium15.textColor(appCtrl.appTheme.blackColor),
        ),
        const VSpace(Sizes.s8),
        Theme(
            data: ThemeData(
                dialogTheme:
                    DialogTheme(backgroundColor: appCtrl.appTheme.white)),
            child: InternationalPhoneNumberInput(
                textStyle:
                    AppCss.poppinsMedium16.textColor(appCtrl.appTheme.txt),
                onInputChanged: (PhoneNumber number) {
                  editCtrl.dialCode = number.dialCode!;
                  editCtrl.update();
                  if (number.phoneNumber!.isNotEmpty) {
                    editCtrl.mobileNumber = false;
                  }
                  editCtrl.update();
                },
                onInputValidated: (bool value) {
                  editCtrl.isCorrect = value;
                  editCtrl.update();

                },
                selectorConfig: const SelectorConfig(
                    leadingPadding: 0,
                    trailingSpace: false,
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
                selectorButtonOnErrorPadding: 0,
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: appCtrl.appTheme.txt),
                initialValue: editCtrl.number,

                textFieldController: editCtrl.phoneText,
                scrollPadding: EdgeInsets.zero,
                formatInput: false,

                inputDecoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(AppRadius.r8)),
                  fillColor: const Color.fromRGBO(153, 158, 166, .1),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                inputBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(AppRadius.r8)),
                onSaved: (PhoneNumber number) {})),
      /*  CommonTextBox(
            focusNode: editCtrl.phoneFocus,
            controller: editCtrl.phoneText,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.phone,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(AppRadius.r8)),
            filled: true,
            fillColor: const Color.fromRGBO(153, 158, 166, .1),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: Insets.i16, vertical: Insets.i16),
            readOnly: editCtrl.phoneText.text.isNotEmpty ? true : false,
            validator: (val) {
              if (val!.isEmpty) {
                return fonts.phoneError.tr;
              } else {
                return null;
              }
            },
            maxLength: 10),*/

        const VSpace(Sizes.s28),
        Text(fonts.addStatus.tr,
            style:
                AppCss.poppinsMedium15.textColor(appCtrl.appTheme.blackColor)),
        const VSpace(Sizes.s8),
        CommonTextBox(
            focusNode: editCtrl.statusFocus,
            controller: editCtrl.statusText,
            textInputAction: TextInputAction.done,
            maxLength: 130,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: Insets.i16, vertical: Insets.i1),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(AppRadius.r8)),
            filled: true,
            fillColor: const Color.fromRGBO(153, 158, 166, .1),
            keyboardType: TextInputType.multiline,
            errorText: editCtrl.statusValidation ? fonts.phoneError.tr : null),
        const VSpace(Sizes.s45)
      ]);
    });
  }
}
