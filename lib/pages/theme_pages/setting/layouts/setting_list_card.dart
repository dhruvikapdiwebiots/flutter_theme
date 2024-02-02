

import 'package:flutter_switch/flutter_switch.dart';

import '../../../../config.dart';

class SettingListCard extends StatelessWidget {
  final dynamic data;
  final int? index;

  const SettingListCard({Key? key, this.data, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(builder: (settingCtrl) {
      return
          Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            SvgPicture.asset(
              data["icon"],
              height: Sizes.s22,width: Sizes.s22,
            ).paddingAll(Insets.i10).decorated(
                  color: appCtrl.appTheme.profileSettingColor,
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
                ),
            const HSpace(Sizes.s10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trans(data["title"]),
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.blackColor)),
                if (index == 0 || index ==1)
                  index == 0? Text(
                      appCtrl.languageVal == "en"
                          ? "English"
                          : appCtrl.languageVal == "ar"
                              ? "Arabic"
                              : appCtrl.languageVal == "hi"
                                  ? "Hindi"
                                  : "Gujarati",
                      style: AppCss.poppinsLight12
                          .textColor(appCtrl.appTheme.txtColor)).marginOnly(top: Insets.i3) : Text(
                     "Sync contact for web Login access",
                      style: AppCss.poppinsLight12
                          .textColor(appCtrl.appTheme.txtColor)).marginOnly(top: Insets.i3)
              ],
            )
          ]),
          data["title"] == "rtl" ||
                  data["title"] == "theme" ||
                  data["title"] == "fingerprintLock"
              ?
          FlutterSwitch(
              activeColor: appCtrl.appTheme.primary.withOpacity(0.2),
              activeToggleColor: appCtrl.appTheme.primary,
              inactiveToggleColor:appCtrl.appTheme.whiteColor ,
              inactiveColor: appCtrl.appTheme.profileSettingColor,
              width: Sizes.s40,
              height: Sizes.s24,
              toggleSize: Sizes.s16,
              value: data["title"] == "rtl"
                  ? appCtrl.isRTL
                  : data["title"] == "theme"
                  ? appCtrl.isTheme
                  : appCtrl.isBiometric,
              borderRadius: AppRadius.r12,
              onToggle: (value) {
                settingCtrl.onSettingTap(index);
                appCtrl.update();
              },
          )
              : SvgPicture.asset(
                      appCtrl.isRTL
                          ? svgAssets.arrowBack
                          : svgAssets.arrowForward,
                      height: Sizes.s10,
              colorFilter: ColorFilter.mode( appCtrl.appTheme.blackColor, BlendMode.srcIn))
                  .paddingAll(Insets.i12)
                  .decorated(
                      color: appCtrl.appTheme.txtColor.withOpacity(.1),
                      shape: BoxShape.circle)
                  .inkWell(onTap: () => settingCtrl.onSettingTap(index)),
        ],
      ).marginSymmetric(vertical: Insets.i5).inkWell(onTap: () => settingCtrl.onSettingTap(index));
    });
  }
}
