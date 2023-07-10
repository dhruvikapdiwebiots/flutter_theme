import 'package:flutter_theme/config.dart';

class CallList extends StatelessWidget {
  final callListCtrl = Get.put(CallListController());

  CallList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallListController>(builder: (_) {
      return Scaffold(
        backgroundColor: appCtrl.appTheme.bgColor,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              AdCommonLayout(
                  bannerAdIsLoaded: callListCtrl.bannerAdIsLoaded,
                  bannerAd: callListCtrl.bannerAd,
                  currentAd: callListCtrl.currentAd),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName.calls)
                      .doc(callListCtrl.user["id"])
                      .collection(collectionName.collectionCallHistory)
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return CommonEmptyLayout(
                        gif: gifAssets.call,
                        title: fonts.emptyCallTitle.tr,
                        desc: fonts.emptyCallDesc.tr,
                      );
                    } else if (!snapshot.hasData) {
                      return Container(
                          margin: const EdgeInsets.only(
                              bottom: Insets.i10,
                              left: Insets.i5,
                              right: Insets.i5));
                    } else {
                      return CallListLayout(snapshot: snapshot);
                    }
                  })
            ]
          )
        )
      );
    });
  }
}
