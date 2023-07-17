import 'dart:developer';

import 'package:flutter_theme/config.dart';

class CallList extends StatelessWidget {
  final callListCtrl = Get.put(CallListController());

  CallList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallListController>(builder: (_) {
      return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
        return Scaffold(
            backgroundColor: appCtrl.appTheme.bgColor,
            floatingActionButton: FloatingActionButton(
              onPressed: () => Get.toNamed(routeName.callContactList),
              backgroundColor: appCtrl.appTheme.primary,
              child: Container(
                width: Sizes.s52,
                height: Sizes.s52,
                padding: const EdgeInsets.all(Insets.i12),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      appCtrl.isTheme
                          ? appCtrl.appTheme.primary.withOpacity(.8)
                          : appCtrl.appTheme.lightPrimary,
                      appCtrl.appTheme.primary
                    ])),
                child: SvgPicture.asset(svgAssets.callAdd, height: Sizes.s15),
              ),
            ),
            body: Stack(alignment: Alignment.topCenter, children: [
              AdCommonLayout(
                  bannerAdIsLoaded: callListCtrl.bannerAdIsLoaded,
                  bannerAd: callListCtrl.bannerAd,
                  currentAd: callListCtrl.currentAd),
              StreamBuilder(
                  stream: dashboardCtrl.userText.text.isNotEmpty &&
                          dashboardCtrl.selectedIndex == 2
                      ? dashboardCtrl.onSearch(dashboardCtrl.userText.text)
                      : FirebaseFirestore.instance
                          .collection(collectionName.calls)
                          .doc(appCtrl.user["id"])
                          .collection(collectionName.collectionCallHistory)
                          .orderBy("timestamp", descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    log("snapshot : ${snapshot.hasData}");
                    if (snapshot.hasError) {
                      return Container();
                    } else if (!snapshot.hasData) {
                      return CommonEmptyLayout(
                        gif: gifAssets.call,
                        title: fonts.emptyCallTitle.tr,
                        desc: fonts.emptyCallDesc.tr,
                      );
                    } else {

                      return snapshot.data!.docs.isEmpty
                          ? CommonEmptyLayout(
                              gif: gifAssets.call,
                              title: fonts.emptyCallTitle.tr,
                              desc: fonts.emptyCallDesc.tr,
                            )
                          : CallListLayout(snapshot: snapshot);
                    }
                  })
            ]).height(MediaQuery.of(context).size.height));
      });
    });
  }
}
