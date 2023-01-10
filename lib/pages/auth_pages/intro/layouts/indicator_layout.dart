import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../config.dart';

class IndicatorLayout extends StatelessWidget {
  final PageController? controller;
  const IndicatorLayout({Key? key,this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
        controller: controller!,
        count: 3,
        effect: WormEffect(
            dotHeight: 12,
            dotWidth: 12,
            type: WormType.thin,
            activeDotColor: appCtrl.appTheme.primary,
            dotColor: appCtrl.appTheme.whiteColor
          // strokeWidth: 5,
        ));
  }
}
