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
          backgroundColor: appCtrl.appTheme.accent,
          body: Column(children: <Widget>[
            VSpace(MediaQuery.of(context).padding.top),
            //skip layout
            Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 2.0),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(fonts.skip.tr,
                            style: AppCss.poppinsBold16
                                .textColor(appCtrl.appTheme.primary))
                        .inkWell(onTap: () {}))),
            //intro page layout
            const IntroPageLayout(),

            //indicator layout
            IndicatorLayout(controller: introCtrl.pageController),

            //start button
            Padding(
                padding:
                    const EdgeInsets.only(top: Insets.i40, bottom: Insets.i40),
                child: Align(
                  alignment: Alignment.center,
                  child: CommonButton(
                      title: fonts.start.tr,
                      color: appCtrl.appTheme.primary,
                      radius: AppRadius.r25,
                      width: Sizes.s150,
                      onTap: () => introCtrl.navigateToLogin(),
                      style: AppCss.poppinsMedium16
                          .textColor(appCtrl.appTheme.accent)),
                ))
          ]));
    });
  }
}
