import '../../../config.dart';

class Splash extends StatelessWidget {
  final splashCtrl = Get.put(SplashController());
   Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (_) {
        return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
                child: Image.asset(
                  imageAssets.splashIcon, // replace your Splashscreen icon
                  height: Sizes.s160, //keep height according to requirement
                  width: Sizes.s160 //keep width according to requirement
                )));
      }
    );
  }
}
