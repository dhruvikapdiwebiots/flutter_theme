import 'package:flutter_theme/config.dart';

class SettingController extends GetxController {
  List settingList = [];
  dynamic user;

  @override
  void onReady() {
    // TODO: implement onReady
    settingList = appArray.settingList;
    user = appCtrl.storage.read(session.user) ?? "";
    update();
    super.onReady();
  }

  editProfile() {
    user = appCtrl.storage.read(session.user);

    Get.toNamed(routeName.editProfile,
        arguments: {"resultData": user, "isPhoneLogin": false});
  }

  deleteUser() async {
    await showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        actionsPadding: const EdgeInsets.symmetric(vertical: Insets.i15,horizontal: Insets.i15),
        backgroundColor: appCtrl.appTheme.whiteColor,
        title: Text(fonts.deleteAccount.tr),
        content: Text(
          fonts.deleteConfirmation.tr,
          style: AppCss.poppinsMedium14
              .textColor(appCtrl.appTheme.blackColor)
              .textHeight(1.3),
        ),
        actions: [
          SizedBox(
            width: Sizes.s80,
            child: Text(
              fonts.cancel.tr,textAlign: TextAlign.center,
              style:
                  AppCss.poppinsMedium14.textColor(appCtrl.appTheme.whiteColor),
            )
                .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i8)
                .decorated(
                    color: appCtrl.appTheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.r25)),
          ).inkWell(onTap: ()=>Get.back()),
          SizedBox(
            width: Sizes.s80,
            child: Text(
              fonts.ok.tr,textAlign: TextAlign.center,
              style:
                  AppCss.poppinsMedium14.textColor(appCtrl.appTheme.whiteColor),
            )
                .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i8)
                .decorated(
                    color: appCtrl.appTheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.r25)),
          ).inkWell(onTap: ()async{
            var user = appCtrl.storage.read(session.user);
            Get.offAllNamed(routeName.phone);
            await FirebaseFirestore.instance.collection(collectionName.users).doc(user["id"]).delete();
            await FirebaseFirestore.instance.collection(collectionName.calls).doc(user["id"]).delete();
            await FirebaseFirestore.instance.collection(collectionName.status).doc(user["id"]).delete();
            FirebaseAuth.instance.signOut();
            await appCtrl.storage.remove(session.user);
            await appCtrl.storage.remove(session.id);
            await appCtrl.storage.remove(session.isDarkMode);
            await appCtrl.storage.remove(session.isRTL);
            await appCtrl.storage.remove(session.languageCode);
            await appCtrl.storage.remove(session.languageCode);
          })
        ],
      ),
    );
  }
}
