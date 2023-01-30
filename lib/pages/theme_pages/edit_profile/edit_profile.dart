import 'package:flutter_theme/config.dart';

class EditProfile extends StatelessWidget {
  final editCtrl = Get.put(EditProfileController());

  EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: (_) {
      return AgoraToken(
        scaffold: PickupLayout(
          scaffold: Scaffold(
            backgroundColor: appCtrl.appTheme.whiteColor,
            appBar: AppBar(
                automaticallyImplyLeading: false,
                leading:
                    Icon(Icons.arrow_back, color: appCtrl.appTheme.whiteColor)
                        .inkWell(onTap: () => Get.back()),
                backgroundColor: appCtrl.appTheme.primary,
                title: Text(
                  fonts.saveProfile.tr,
                  style: AppCss.poppinsblack16
                      .textColor(appCtrl.appTheme.whiteColor),
                )),
            body: editCtrl.isLoading
                ? CommonLoader(isLoading: editCtrl.isLoading)
                    .height(MediaQuery.of(context).size.height)
                : SingleChildScrollView(
                    child: Form(
                    key: editCtrl.formKey,
                    child: editCtrl.user != null && editCtrl.user != ""
                        ?const EditProfileBody().marginSymmetric(
                            vertical: Insets.i20, horizontal: Insets.i15)
                        : Container(),
                  )),
          ),
        ),
      );
    });
  }
}
