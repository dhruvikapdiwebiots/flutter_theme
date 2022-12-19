import 'package:flutter/cupertino.dart';
import 'package:flutter_theme/config.dart';

class OtherSetting extends StatelessWidget {
  const OtherSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DirectionalityRtl(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appCtrl.appTheme.primary,
          iconTheme: IconThemeData(color: appCtrl.appTheme.whiteColor),
          title: Text(fonts.chats.tr,
              style:
                  AppCss.poppinsblack18.textColor(appCtrl.appTheme.whiteColor)),
        ),
        body: Column(
          children: [
            ListTile(
                onTap: () {
                  appCtrl.isTheme = !appCtrl.isTheme;

                  appCtrl.update();
                  ThemeService().switchTheme(appCtrl.isTheme);
                },
                minLeadingWidth: 0,
                title: Text(fonts.theme.tr,
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.blackColor)),
                leading: const Icon(Icons.sunny)),
            ListTile(
                minLeadingWidth: 0,
                onTap: () => language(),
                title: Text(fonts.language.tr,
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.blackColor)),
                leading: const Icon(CupertinoIcons.globe)),  ListTile(
                minLeadingWidth: 0,
                onTap: ()async {
                  appCtrl.isRTL = !appCtrl.isRTL;
                  appCtrl.update();
                  await appCtrl.storage.write("isRTL", appCtrl.isRTL);
                  Get.forceAppUpdate();
                },
                title: Text("RTL",
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.blackColor)),
                leading:  Icon(appCtrl.isRTL || appCtrl.languageVal == "ar" ? Icons.arrow_back: Icons.arrow_forward)),

          ],
        ).paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i20),
      ),
    );
  }
}
