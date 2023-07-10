import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/widgets/common_app_bar.dart';

class EditProfile extends StatelessWidget {
  final editCtrl = Get.put(EditProfileController());

  EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(builder: (_) {
      return AgoraToken(
        scaffold: PickupLayout(
          scaffold: Scaffold(
            backgroundColor: appCtrl.appTheme.bgColor,
            appBar: CommonAppBar(text: fonts.saveProfile.tr),
            body:
                 Stack(
                  children: [
                    SingleChildScrollView(
                        child: Form(
                        key: editCtrl.formKey,
                        child: editCtrl.user != null && editCtrl.user != ""
                            ?const EditProfileBody().marginSymmetric(
                                vertical: Insets.i20, horizontal: Insets.i15)
                            : Container(),
                      )),
                   if( editCtrl.isLoading)
                     CommonLoader(isLoading: editCtrl.isLoading)

                  ],
                ),
          ),
        ),
      );
    });
  }
}
