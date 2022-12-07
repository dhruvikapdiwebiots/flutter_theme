import '../../../../config.dart';

class IntroPageLayout extends StatelessWidget {
  const IntroPageLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<IntroController> (
      builder: (introCtrl) {
        return introCtrl.pageViewModelData.isNotEmpty ? Expanded(
            child: Center(
                child: PageView(
                    controller: introCtrl.pageController,
                    pageSnapping: true,
                    onPageChanged: (index) {
                      introCtrl.currentShowIndex = index;
                      introCtrl.update();
                    },
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      PagePopup(imageData: introCtrl.pageViewModelData[0]),
                      PagePopup(imageData: introCtrl.pageViewModelData[1]),
                      PagePopup(imageData: introCtrl.pageViewModelData[2]),
                    ]))):Container();
      }
    );
  }
}
