import 'package:flutter/cupertino.dart';
import 'package:flutter_theme/config.dart';

class EditProfile extends StatelessWidget {
  final editCtrl = Get.put(EditProfileController());

  EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: (_) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: appCtrl.appTheme.primary,
            title: Text(fonts.saveProfile.tr)),
        body: SingleChildScrollView(
            child: Form(
          key: editCtrl.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: "user",
                child: Container(
                  height: Sizes.s120,
                  width: Sizes.s120,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(Insets.i15),
                  decoration: BoxDecoration(
                      color: appCtrl.appTheme.gray.withOpacity(.3),
                      image:
                          DecorationImage(image: AssetImage(imageAssets.user)),
                      shape: BoxShape.circle),
                ),
              ),
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
                  suffixIcon:
                      Icon(Icons.mail, color: appCtrl.appTheme.blackColor)),
              const VSpace(Sizes.s25),
              CommonTextBox(
                  labelText: fonts.mobileNumber.tr,
                  focusNode: editCtrl.phoneFocus,
                  controller: editCtrl.phoneText,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
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
                  suffixIcon:
                      Icon(Icons.call, color: appCtrl.appTheme.blackColor)),

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
                  suffixIcon:
                      Icon(Icons.star, color: appCtrl.appTheme.blackColor),
                  errorText:
                      editCtrl.statusValidation ? fonts.phoneError.tr : null),
              const VSpace(Sizes.s25),
              CommonButton(
                title: fonts.saveProfile.tr,
                margin: 0,
                onTap: () {
                  if (editCtrl.formKey.currentState!.validate()) {
                    editCtrl.updateUserData();
                  } else {
                  }
                },
                style: AppCss.poppinsblack14
                    .textColor(appCtrl.appTheme.whiteColor),
              )
            ],
          ).marginSymmetric(vertical: Insets.i20, horizontal: Insets.i15),
        )),
      );
    });
  }
}
