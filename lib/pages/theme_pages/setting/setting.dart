import 'package:flutter_theme/config.dart';

class Setting extends StatelessWidget {
  final settingCtrl = Get.put(SettingController());

  Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(builder: (_) {
      print(" dsf : R${settingCtrl.user}");
      return Scaffold(
        backgroundColor: appCtrl.appTheme.whiteColor,
        body: settingCtrl.user != null || settingCtrl.user != ""
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
                          UserOnlineStatus(id: settingCtrl.user["id"])
                        ])
                  ],
                ).inkWell(onTap: () => settingCtrl.editProfile()),
                const VSpace(Sizes.s20),

                //setting list
                ...settingCtrl.settingList
                    .asMap()
                    .entries
                    .map((e) => SettingListCard(index: e.key, data: e.value))
                    .toList()
              ]).paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i20)
            : Container(),
      );
    });
  }
}
