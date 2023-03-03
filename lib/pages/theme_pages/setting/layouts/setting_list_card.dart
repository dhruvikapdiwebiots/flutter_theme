import 'package:figma_squircle/figma_squircle.dart';

import '../../../../config.dart';

class SettingListCard extends StatelessWidget {
  final dynamic data;
  final int? index;

  const SettingListCard({Key? key, this.data, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(builder: (settingCtrl) {
      return index == 0
          ? ListTile(
              dense: true,
              onTap: () => settingCtrl.onSettingTap(index),
              minLeadingWidth: 0,
              contentPadding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
              title: Text(trans(data["title"]),
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.blackColor)),
              subtitle: Text(appCtrl.languageVal == "en" ? "English" :appCtrl.languageVal == "ar" ? "Arabic" : appCtrl.languageVal == "hi" ? "Hindi" : "Gujarati",
                  style: AppCss.poppinsLight12
                      .textColor(appCtrl.appTheme.txtColor)),
              leading: SvgPicture.asset(
                data["icon"],
              ).paddingAll(Insets.i10).decorated(
                    color: appCtrl.appTheme.profileSettingColor,
                    borderRadius:
                        SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
                  ))
          : ListTile(
              contentPadding: EdgeInsets.zero,
          onTap: () => settingCtrl.onSettingTap(index),
              minLeadingWidth: 0,
              title: Text(trans(data["title"]),
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.blackColor)),
              leading: SvgPicture.asset(
                data["icon"],
              ).paddingAll(Insets.i10).decorated(
                    color: appCtrl.appTheme.profileSettingColor,
                    borderRadius:
                        SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
                  ));
    });
  }
}
