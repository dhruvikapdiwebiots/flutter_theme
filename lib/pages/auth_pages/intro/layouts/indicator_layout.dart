import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../config.dart';

class IndicatorLayout extends StatelessWidget {
  final PageController? controller;
  const IndicatorLayout({Key? key,this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller:controller!,
      count: 3,
      axisDirection: Axis.horizontal,
      effect: SlideEffect(
          activeDotColor: appCtrl.appTheme.primary,
          dotHeight: 6,
          dotColor: appCtrl.appTheme.whiteColor,
          dotWidth: Sizes.s15),
    );
  }
}
