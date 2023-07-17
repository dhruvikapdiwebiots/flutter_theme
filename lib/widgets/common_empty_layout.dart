import '../config.dart';

class CommonEmptyLayout extends StatelessWidget {
  final String? title,desc,gif;
  const CommonEmptyLayout({Key? key,this.title,this.desc,this.gif}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(gif!,height: Sizes.s150),
            const VSpace(Sizes.s12),
            Text(title!,style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.blackColor)),
            const VSpace(Sizes.s6),
            Text(desc!.tr,textAlign: TextAlign.center,style: AppCss.poppinsLight14.textColor(appCtrl.appTheme.txtColor).textHeight(1.6).letterSpace(.2)).marginSymmetric(horizontal: Insets.i35),
          ]).height(MediaQuery.of(context).size.height),
    );
  }
}
