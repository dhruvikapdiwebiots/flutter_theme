import '../config.dart';

class BackIcon extends StatelessWidget {
  const BackIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset( appCtrl.isRTL ? svgAssets.arrowForward : svgAssets.arrowBack, height: Sizes.s18)
        .paddingAll(Insets.i12)
        .decorated(
        color: appCtrl.appTheme.whiteColor,
        boxShadow: [
          const BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 5,
              spreadRadius: 1,
              color: Color.fromRGBO(0, 0, 0, 0.08))
        ],
        borderRadius: BorderRadius.circular(AppRadius.r10))
        .marginSymmetric(vertical: Insets.i5, horizontal: Insets.i20)
        .paddingSymmetric(vertical: Insets.i14)
        .inkWell(onTap: () => Get.back());
  }
}
