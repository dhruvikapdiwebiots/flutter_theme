  import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../config.dart';

class Splash extends StatelessWidget {
  final splashCtrl = Get.put(SplashController());
   Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool typewriter(double width) => width > 15;
    return GetBuilder<SplashController>(
      builder: (_) {
        return Scaffold(
            backgroundColor: appCtrl.appTheme.whiteColor,
            body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                     imageAssets.splashIcon, // replace your Splashscreen icon
                      height: Sizes.s160, //keep height according to requirement
                      width: Sizes.s160 //keep width according to requirement
                    ),
                    const VSpace(Sizes.s15),
                    AnimatedTextKit(
                      animatedTexts: [
                        TyperAnimatedText(fonts.chatter.tr.toUpperCase(),textStyle: AppCss.poppinsblack16.textColor(appCtrl.appTheme.txt))
                      ],
                      onTap: () {
                      },
                    ),
                  ],
                )));
      }
    );
  }
}
