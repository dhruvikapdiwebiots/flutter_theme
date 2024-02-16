import 'dart:developer';

import '../../../../config.dart';

class PopUpAction extends StatelessWidget {
  const PopUpAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return dashboardCtrl.selectedIndex == 0
          ? PopupMenuButton(
              color: appCtrl.appTheme.whiteColor,
              padding: EdgeInsets.zero,
              iconSize: Sizes.s20,
              onSelected: (result) async {},
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r8)),
              itemBuilder: (ctx) => [
                if (appCtrl.usageControlsVal!.allowCreatingBroadcast!)
                  _buildPopupMenuItem("newBroadCast", 0),
                if (appCtrl.usageControlsVal!.allowCreatingGroup!)
                  _buildPopupMenuItem("newGroup", 1),
                _buildPopupMenuItem("setting", 2),
              ],
              child: SvgPicture.asset(
                svgAssets.more,
                height: Sizes.s22,
                  colorFilter:ColorFilter.mode(appCtrl.appTheme.blackColor,BlendMode.srcIn)
              ).paddingAll(Insets.i10),
            )
          : dashboardCtrl.selectedIndex == 1
              ? PopupMenuButton(
                  color: appCtrl.appTheme.whiteColor,
                  icon: Icon(Icons.more_vert, color: appCtrl.appTheme.white),
                  itemBuilder: (context) {
                    return [
                      ...dashboardCtrl.statusAction
                          .asMap()
                          .entries
                          .map((e) => PopupMenuItem<int>(
                                value: 0,
                                onTap: () {},
                                child: Text(
                                  trans(e.value["title"]),
                                  style: AppCss.poppinsMedium14
                                      .textColor(appCtrl.appTheme.blackColor),
                                ).inkWell(onTap: () {

                                  Get.toNamed(routeName.setting,arguments: dashboardCtrl.pref);
                                }),
                              ))
                          .toList(),
                    ];
                  },
                )
              : PopupMenuButton(
                  color: appCtrl.appTheme.whiteColor,
                  icon: Icon(Icons.more_vert, color: appCtrl.appTheme.white),
                  itemBuilder: (context) {
                    return [
                      ...dashboardCtrl.callsAction
                          .asMap()
                          .entries
                          .map((e) => PopupMenuItem<int>(
                                value: 0,
                                onTap: () {},
                                child: Text(
                                  trans(e.value["title"]),
                                  style: AppCss.poppinsMedium14
                                      .textColor(appCtrl.appTheme.blackColor),
                                ).inkWell(onTap: () async {
                                  log("title : ${e.value["title"]}");

                                  if (e.value["title"] == "clearLogs") {
                                    Get.back();
                                    await FirebaseFirestore.instance
                                        .collection("calls")
                                        .doc(dashboardCtrl.user["id"])
                                        .collection("collectionCallHistory")
                                        .get()
                                        .then((value) {
                                      value.docs
                                          .asMap()
                                          .entries
                                          .forEach((element) {
                                        FirebaseFirestore.instance
                                            .collection("calls")
                                            .doc(dashboardCtrl.user["id"])
                                            .collection("collectionCallHistory")
                                            .doc(element.value.id)
                                            .delete();
                                      });
                                    });
                                  } else {
                                    Get.toNamed(routeName.setting,arguments: dashboardCtrl.pref);
                                  }
                                }),
                              ))
                          .toList(),
                    ];
                  },
                );
    });
  }

  PopupMenuItem _buildPopupMenuItem(String title, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        children: [
          Text(
            title,
            style:
                AppCss.poppinsMedium14.textColor(appCtrl.appTheme.blackColor),
          )
        ],
      ),
    );
  }
}
