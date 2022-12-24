
import 'dart:async';

import 'package:flutter_theme/config.dart';




class IntroController extends GetxController{
  var pageController = PageController(initialPage: 0);
  List pageViewModelData =[];

  var title = fonts.title;
  var subtitle = fonts.subtitle;
  var subtitle2 = fonts.subtitle2;
  var subtitle3 = fonts.subtitle3;

  late Timer sliderTimer;
  var currentShowIndex = 0;


  @override
  void onReady() {
    // TODO: implement onReady
    pageViewModelData.add(PageViewData(
      titleText: title,
      subtitleText: subtitle,
      assetsImage: imageAssets.logo,
    ));

    pageViewModelData.add(PageViewData(
      titleText: title,
      subtitleText: subtitle2,
      assetsImage: imageAssets.intro1,
    ));

    pageViewModelData.add(PageViewData(
      titleText: title,
      subtitleText: subtitle3,
      assetsImage: imageAssets.intro2,
    ));

    // set timer and page controller according to current Index
    sliderTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (currentShowIndex == 0) {
        pageController.animateTo(MediaQuery.of(Get.context!).size.width,
            duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn);
      } else if (currentShowIndex == 1) {
        pageController.animateTo(MediaQuery.of(Get.context!).size.width * 2,
            duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn);
      } else if (currentShowIndex == 2) {
        pageController.animateTo(0,
            duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn);
      }
    });
    update();
    super.onReady();
  }

//navigate to Login
  navigateToLogin() {
   Get.toNamed(routeName.phone);
   appCtrl.storage.write("isIntro", true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sliderTimer.cancel();
    pageController.dispose();

    update();
    super.dispose();
  }

}