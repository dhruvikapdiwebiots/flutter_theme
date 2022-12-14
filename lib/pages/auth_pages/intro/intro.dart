import '../../../config.dart';


class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final introCtrl = Get.put(IntroController());

  @override
  void dispose() {
    // TODO: implement dispose
    introCtrl.sliderTimer.cancel();
    introCtrl.pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IntroController>(builder: (_) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: appCtrl.appTheme.whiteColor,
          body: Stack(
alignment: Alignment.bottomLeft,
            children: [
              Image.asset(
                imageAssets.wave,
                height: Sizes.s160,
                width: Sizes.s220,
                fit: BoxFit.fill,
              ),
              Column(children: <Widget>[
                VSpace(MediaQuery.of(context).padding.top),

                //intro page layout
                const IntroPageLayout(),

                //start button
                Padding(
                    padding: const EdgeInsets.only(
                      top: Insets.i10
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //indicator layout
                          IndicatorLayout(controller: introCtrl.pageController)
                              .paddingSymmetric(
                                  horizontal: Insets.i15, vertical: Insets.i70),

                          Icon(introCtrl.currentShowIndex == 2 ?Icons.check : Icons.arrow_forward,
                                  color: appCtrl.appTheme.whiteColor)
                              .paddingAll(Insets.i10)
                              .decorated(
                                  color: appCtrl.appTheme.primary,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r50))
                              .paddingSymmetric(horizontal: Insets.i15)
                              .inkWell(onTap: () => introCtrl.navigateToLogin())
                        ],
                      ),
                    ))
              ]),
            ],
          ));

            //start button
    });
  }
}
