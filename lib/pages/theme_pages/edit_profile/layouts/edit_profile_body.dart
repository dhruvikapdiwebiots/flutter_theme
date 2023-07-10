import 'dart:developer';

import '../../../../config.dart';

class EditProfileBody extends StatelessWidget {
  const EditProfileBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: (editCtrl) {
      log("EDIR : ${editCtrl.user["image"]}");
      return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        //image layout
        Stack(
          children: [
            const EditProfileImage(),
            Positioned(
              bottom: 0,
              right: -1,
              child: Align(
                      alignment: Alignment.bottomRight,
                      child: SvgPicture.asset(svgAssets.edit,
                              height: Sizes.s15)
                          .paddingAll(Insets.i6)
                          .decorated(
                              color: appCtrl.appTheme.primary,
                              shape: BoxShape.circle))
                  .paddingAll(Insets.i1)
                  .decorated(
                      color: appCtrl.appTheme.white,
                      shape: BoxShape.circle),
            )
          ],
        ).width(Sizes.s115)
            .inkWell(onTap: () => editCtrl.imagePickerOption(context)),

        //all input box layout
        const VSpace(Sizes.s22),
        const EditProfileTextBox(),
        CommonButton(
            title: fonts.saveProfile.tr,
            margin: 0,
            onTap: () {
              if (editCtrl.formKey.currentState!.validate()) {
                editCtrl.updateUserData();
              } else {}
            },
            style: AppCss.poppinsblack14.textColor(appCtrl.appTheme.whiteColor))
      ]);
    });
  }
}
