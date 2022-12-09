import '../../../../../../config.dart';

class IconCreation extends StatelessWidget {
  final IconData? icons;
  final Color? color;
  final String? text;
  const IconCreation({Key? key,this.text,this.color,this.icons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: AppRadius.r30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: Sizes.s30,
              color: appCtrl.appTheme.whiteColor,
            ),
          ),
          const VSpace(Sizes.s5),
          Text(
            text!,
            style: AppCss.poppinsblack14.textColor(appCtrl.appTheme.whiteColor),
          )
        ],
      ),
    );
  }
}
