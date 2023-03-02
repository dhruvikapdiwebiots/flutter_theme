import '../../../config.dart';

class Splash extends StatelessWidget {
  final splashCtrl = Get.put(SplashController());

  Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (_) {
      return Scaffold(
          backgroundColor: appCtrl.appTheme.primary,
          body: Center(
              child: Image.asset(
            imageAssets.splashIcon, // replace your Splashscreen icon
            width: Sizes.s210,
          )));
    });
  }
}
