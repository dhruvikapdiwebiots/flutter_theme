import '../../../../config.dart';

class LocationLayout extends StatelessWidget {
  final GestureTapCallback? onTap;
  final VoidCallback? onLongPress;
  const LocationLayout({Key? key,this.onLongPress,this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onTap,
      onLongPress:onLongPress,
      child: Image.asset(
        imageAssets.map,
        height: Sizes.s150,
      )
          .clipRRect(all: AppRadius.r10)
          .paddingSymmetric(
          vertical: Insets.i6, horizontal: Insets.i8)
          .decorated(
          color: appCtrl.appTheme.primary,
          borderRadius:
          BorderRadius.circular(AppRadius.r10))
          .paddingSymmetric(vertical: Insets.i10),
    );
  }
}
