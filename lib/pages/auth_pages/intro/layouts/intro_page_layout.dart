import '../../../../config.dart';

class IntroPageLayout extends StatelessWidget {
  const IntroPageLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IntroController>(builder: (introCtrl) {
      return introCtrl.pageViewModelData.isNotEmpty
          ? Expanded(
              child: Center(
                  child: PageView(
                      controller: introCtrl.pageController,
                      pageSnapping: false,

                      onPageChanged: (index) {
                        introCtrl.currentShowIndex = index;
                        introCtrl.update();
                        if (introCtrl.currentShowIndex == 0) {
                          introCtrl.isAnimate1 = true;
                          introCtrl.isAnimate2 = false;
                          introCtrl.isAnimate3 = false;
                        }else if (introCtrl.currentShowIndex == 1) {
                          introCtrl.isAnimate1 = false;
                          introCtrl.isAnimate2 = true;
                          introCtrl.isAnimate3 = false;
                        }else{
                          introCtrl.isAnimate1 = false;
                          introCtrl.isAnimate2 = false;
                          introCtrl.isAnimate3 = true;
                        }
                        introCtrl.update();
                      },
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                  PagePopup(imageData: introCtrl.pageViewModelData[0],index: 0,selectedIndex: introCtrl.currentShowIndex,),
                  PagePopup(imageData: introCtrl.pageViewModelData[1],index: 1,selectedIndex: introCtrl.currentShowIndex),
                  PagePopup(imageData: introCtrl.pageViewModelData[2],index: 2,selectedIndex: introCtrl.currentShowIndex),
                ])))
          : Container();
    });
  }
}
