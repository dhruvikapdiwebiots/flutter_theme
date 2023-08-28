import '../config.dart';

class BackIcon extends StatelessWidget {
  final bool verticalPadding;
  const BackIcon({Key? key,this.verticalPadding = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      appCtrl.isRTL ? svgAssets.arrowForward : svgAssets.arrowBack,
      colorFilter: ColorFilter.mode( appCtrl.appTheme.blackColor, BlendMode.srcIn),
      height: Sizes.s18,
    )
        .paddingSymmetric(horizontal: Insets.i16, vertical: verticalPadding ? Insets.i15 : Insets.i10)
        .decorated(
            borderRadius: BorderRadius.circular(AppRadius.r10),
            boxShadow: [
              const BoxShadow(
                  offset: Offset(0, 2),
                  blurRadius: 5,
                  spreadRadius: 1,
                  color: Color.fromRGBO(0, 0, 0, 0.08))
            ],
            color: appCtrl.appTheme.whiteColor)
        .marginSymmetric(horizontal: Insets.i20, vertical: Insets.i20)
        .inkWell(onTap: () => Get.back());
  }
}
