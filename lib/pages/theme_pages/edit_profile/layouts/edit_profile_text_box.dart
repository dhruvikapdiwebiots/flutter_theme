import 'package:flutter/cupertino.dart';
import 'package:flutter_theme/config.dart';

class EditProfileTextBox extends StatelessWidget {
  const EditProfileTextBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: (editCtrl) {
      return Column(
        children: [
          const VSpace(Sizes.s20),
          NameTextBox(
              nameFocus: editCtrl.nameFocus,
              nameText: editCtrl.nameText,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: appCtrl.appTheme.primary)),
              suffixIcon: Icon(CupertinoIcons.person_crop_square_fill,
                  color: appCtrl.appTheme.blackColor),
              nameValidation: editCtrl.nameValidation),
          const VSpace(Sizes.s25),
          //email text box
          EmailTextBox(
              emailText: editCtrl.emailText,
              emailValidate: editCtrl.emailValidate,
              focusNode: editCtrl.emailFocus,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: appCtrl.appTheme.primary)),
              suffixIcon: Icon(Icons.mail, color: appCtrl.appTheme.blackColor)),
          const VSpace(Sizes.s25),
          CommonTextBox(
              labelText: fonts.mobileNumber.tr,
              focusNode: editCtrl.phoneFocus,
              controller: editCtrl.phoneText,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.phone,
              readOnly:editCtrl.phoneText.text.isNotEmpty ? true :false,
              validator: (val) {
                if (val!.isEmpty) {
                  return fonts.phoneError.tr;
                } else {
                  return null;
                }
              },
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: appCtrl.appTheme.primary)),
              maxLength: 10,
              suffixIcon: Icon(Icons.call, color: appCtrl.appTheme.blackColor)),

          const VSpace(Sizes.s25),
          CommonTextBox(
              labelText: fonts.status.tr,
              focusNode: editCtrl.statusFocus,
              controller: editCtrl.statusText,
              textInputAction: TextInputAction.done,
              maxLength: 130,
              keyboardType: TextInputType.multiline,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: appCtrl.appTheme.primary)),
              suffixIcon: Icon(Icons.star, color: appCtrl.appTheme.blackColor),
              errorText:
                  editCtrl.statusValidation ? fonts.phoneError.tr : null),
          const VSpace(Sizes.s25),

        ],
      );
    });
  }
}
