
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
              const EditProfileTextBox(),
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
