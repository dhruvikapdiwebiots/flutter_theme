import 'package:flutter_theme/config.dart';

class Setting extends StatelessWidget {
  final settingCtrl = Get.put(SettingController());

  Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: appCtrl.appTheme.primary,
          iconTheme: IconThemeData(color: appCtrl.appTheme.whiteColor),
          title: Text(fonts.setting.tr, style:
          AppCss.poppinsblack18.textColor(appCtrl.appTheme.whiteColor)),
        ),
        body: settingCtrl.user != null && settingCtrl.user != ""
            ? Column(children: [
                Row(
                  children: [
                    UserImage(image: settingCtrl.user["image"]),
                    const HSpace(Sizes.s20),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(settingCtrl.user["name"],
                              style: AppCss.poppinsblack16
                                  .textColor(appCtrl.appTheme.blackColor)),
                          const VSpace(Sizes.s10),
                          Text(settingCtrl.user["status"],
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.grey))
                        ])
                  ],
                ).inkWell(onTap: () => settingCtrl.editProfile()),
                const VSpace(Sizes.s20),
                ...settingCtrl.settingList
                    .asMap()
                    .entries
                    .map((e) => ListTile(
                        onTap: () async {
                          if (e.key == 0) {
                            Get.toNamed(routeName.otherSetting);
                          } else if (e.key == 2) {
                            FirebaseAuth.instance.signOut();

                            var user = appCtrl.storage.read("user");
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(user["id"])
                                .update({
                              "status": "Offline",
                              "lastSeen": DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString()
                            });
                            appCtrl.storage.erase();
                            Get.offAllNamed(routeName.login);
                          }
                        },
                        minLeadingWidth: 0,
                        title: Text(trans(e.value["title"]),
                            style: AppCss.poppinsMedium14
                                .textColor(appCtrl.appTheme.blackColor)),
                        leading: Icon(e.value["icon"])))
                    .toList()
              ]).paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i20)
            : Container(),
      );
    });
  }
}
