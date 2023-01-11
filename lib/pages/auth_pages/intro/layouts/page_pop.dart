import '../../../../config.dart';

class PagePopup extends StatelessWidget {
  final PageViewData imageData;
final int? index,selectedIndex;
  const PagePopup({Key? key, required this.imageData,this.index,this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IntroController>(
      builder: (introCtrl) {
        return Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SvgPicture.asset(
                      imageData.assetsImage,
                      height: Sizes.s400,
                      fit: BoxFit.fill,
                    ).paddingSymmetric(vertical: Insets.i10),
                    const VSpace(Sizes.s25),
                    Image.asset(imageAssets.line),
                    const VSpace(Sizes.s15),
                    AnimatedOpacity(
                      duration: const Duration(seconds: 2),
                      opacity:index == selectedIndex ? 1.0:0.0,
                      child: Text(
                          imageData.titleText.tr,
                          textAlign: TextAlign.center,
                          style: AppCss.poppinsBold16
                              .textColor(appCtrl.appTheme.txt).letterSpace(.2).textHeight(1.3)
                      ),
                    ),
                    const VSpace(Sizes.s15),

                    AnimatedOpacity(
                      duration: const Duration(seconds: 2),
                      opacity:index == selectedIndex ? 1.0:0.0,
                      child: Text(
                        imageData.subtitleText.tr,
                        textAlign: TextAlign.center,
                        style: AppCss.poppinsMedium12
                            .textColor(appCtrl.appTheme.txt).letterSpace(.2).textHeight(1.3)
                      ).paddingSymmetric(horizontal: Insets.i15)
                    ),
                  ]),
            ),
          ],
        );
      }
    );
  }
}