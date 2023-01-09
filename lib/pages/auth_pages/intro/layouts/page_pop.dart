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
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 100,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            height: index == selectedIndex ?  Sizes.s250 :0,
                            width: index == selectedIndex ? Sizes.s250:0,
                            decoration: BoxDecoration(color: appCtrl.appTheme.borderGray,shape: BoxShape.circle),
                          ).paddingAll(Insets.i40).decorated(color: appCtrl.appTheme.grey.withOpacity(.2),shape: BoxShape.circle),
                          Image.asset(
                            imageData.assetsImage,
                            fit: BoxFit.fill,
                          ),
                        ],
                      ),
                      const VSpace(Sizes.s22),

                      AnimatedOpacity(
                        duration: const Duration(seconds: 2),
                        opacity:index == selectedIndex ? 1.0:0.0,
                        child: Text(
                          imageData.subtitleText.tr,
                          textAlign: TextAlign.center,
                          style: AppCss.poppinsBold20
                              .textColor(appCtrl.appTheme.txt).letterSpace(.2).textHeight(1.2)
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        );
      }
    );
  }
}