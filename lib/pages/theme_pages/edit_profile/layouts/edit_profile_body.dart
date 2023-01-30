

import '../../../../config.dart';

class EditProfileBody extends StatelessWidget {
  const EditProfileBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      builder: (editCtrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //image layout
            Hero(
              tag: "user",
              child: editCtrl.user["image"] != "" &&
                  editCtrl.user["image"] != null
                  ? const EditProfileImage()
                  : Container(
                height: Sizes.s120,
                width: Sizes.s120,
                alignment: Alignment.center,
                padding:
                const EdgeInsets.all(Insets.i15),
                decoration: BoxDecoration(
                    color: appCtrl.appTheme.gray
                        .withOpacity(.3),
                    image: DecorationImage(
                        image: AssetImage(
                            imageAssets.user)),
                    shape: BoxShape.circle),
              ),
            ).inkWell(
                onTap: () =>
                    editCtrl.imagePickerOption(context)),

            //all input box layout
            const EditProfileTextBox(),
            CommonButton(
              title: fonts.saveProfile.tr,
              margin: 0,
              onTap: () {
                if (editCtrl.formKey.currentState!
                    .validate()) {
                  editCtrl.updateUserData();
                } else {}
              },
              style: AppCss.poppinsblack14
                  .textColor(appCtrl.appTheme.whiteColor)
            )
          ]
        );
      }
    );
  }
}
