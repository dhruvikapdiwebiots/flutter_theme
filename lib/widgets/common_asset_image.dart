import '../config.dart';

class CommonAssetImage extends StatelessWidget {
  final double? height,width;
  const CommonAssetImage({Key? key,this.width,this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        decoration: ShapeDecoration(
            color: appCtrl.appTheme.grey.withOpacity(.4),
            shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                    cornerRadius: 12, cornerSmoothing: 1))),
        child: Image.asset(imageAssets.user,
            height: height,
            width: width,

            color: appCtrl.appTheme.whiteColor)
            .paddingAll(Insets.i15));
  }
}
