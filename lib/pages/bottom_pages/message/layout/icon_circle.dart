import '../../../../config.dart';

class IconCircle extends StatelessWidget {
  const IconCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomRight,
        child: Icon(Icons.circle,
            color: appCtrl.appTheme.greenColor,
            size: Sizes.s12)
            .paddingAll(0.8)
            .decorated(
            color: appCtrl.appTheme.whiteColor,
            shape: BoxShape.circle));
  }
}
