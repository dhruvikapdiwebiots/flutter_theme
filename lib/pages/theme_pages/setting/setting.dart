import 'package:flutter_theme/config.dart';


class Setting extends StatelessWidget {
  final settingCtrl = Get.put(SettingController());

  Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(builder: (_) {
      return DirectionalityRtl(
          child: AgoraToken(
              scaffold: PickupLayout(
                  scaffold: Scaffold(
                      appBar: CommonAppBar(text: fonts.setting.tr),
                      backgroundColor: appCtrl.appTheme.bgColor,
                      body: settingCtrl.user != null || settingCtrl.user != ""
                          ? GetBuilder<AppController>(builder: (appCtrl) {
                              return Column(children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      //user image
                                      Row(children: [
                                        Hero(
                                            tag: "user",
                                            child: CommonImage(
                                                image:
                                                    settingCtrl.user["image"],
                                                name: settingCtrl.user["name"],
                                                height: Sizes.s55,
                                                width: Sizes.s55)),
                                        const HSpace(Sizes.s12),
                                        Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(settingCtrl.user["name"],
                                                  style: AppCss.poppinsblack16
                                                      .textColor(appCtrl
                                                          .appTheme
                                                          .blackColor)),
                                              const VSpace(Sizes.s3),
                                              Text("Personal Info",
                                                  style: AppCss.poppinsLight14
                                                      .textColor(appCtrl
                                                          .appTheme.txtColor))
                                            ])
                                      ]),
                                      SvgPicture.asset(
                                              appCtrl.isRTL
                                                  ? svgAssets.arrowBack
                                                  : svgAssets.arrowForward,
                                              height: Sizes.s15,
                                              color:
                                                  appCtrl.appTheme.blackColor)
                                          .paddingAll(Insets.i15)
                                          .decorated(
                                              color: appCtrl.appTheme.txtColor
                                                  .withOpacity(.1),
                                              shape: BoxShape.circle)
                                          .marginSymmetric(vertical: Insets.i5)
                                          .paddingSymmetric(
                                              vertical: Insets.i14)
                                          .inkWell(
                                              onTap: () =>
                                                  settingCtrl.editProfile())
                                    ]),
                                const VSpace(Sizes.s15),
                                const Divider(
                                    color: Color.fromRGBO(49, 100, 189, 0.1),
                                    thickness: 2),

                                //setting list
                                ...settingCtrl.settingList
                                    .asMap()
                                    .entries
                                    .map((e) => Column(children: [
                                          SettingListCard(
                                              index: e.key, data: e.value),
                                          if (e.key !=
                                              settingCtrl.settingList.length -
                                                  1)
                                            const Divider(
                                                    color: Color.fromRGBO(
                                                        49, 100, 189, 0.1),
                                                    thickness: 1,
                                                    height: 0)
                                                .paddingSymmetric(
                                                    vertical: Insets.i15)
                                        ]))
                                    .toList()
                              ]).paddingSymmetric(horizontal: Insets.i20);
                            })
                          : Container()))));
    });
  }
}
