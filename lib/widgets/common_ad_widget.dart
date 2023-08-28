
import 'package:flutter_theme/controllers/common_controller/ad_controller.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config.dart';

class AdCommonLayout extends StatelessWidget {
  final AlignmentGeometry? alignment;
  final BannerAd? bannerAd;
  final bool bannerAdIsLoaded;
  final Widget? currentAd;

  const AdCommonLayout(
      {Key? key,
      this.alignment,
      this.bannerAdIsLoaded = false,
      this.bannerAd,
      this.currentAd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdController>(builder: (addCtrl) {

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (appCtrl.userAppSettingsVal!.isAdmobEnable!)
            appCtrl.userAppSettingsVal!.isGoogleAdEnable!
                ? (bannerAd != null && bannerAdIsLoaded)
                    ? AdWidget(ad: bannerAd!)
                        .height(Sizes.s50)
                        .paddingOnly(bottom: Insets.i10)
                        .width(MediaQuery.of(context).size.width)
                    : Container()
                : Container(alignment: Alignment.bottomCenter, child: currentAd)
                    .paddingSymmetric(
                        vertical: Insets.i10, horizontal: Insets.i20)
                    .width(MediaQuery.of(context).size.width)
        ]
      );
    });
  }
}
