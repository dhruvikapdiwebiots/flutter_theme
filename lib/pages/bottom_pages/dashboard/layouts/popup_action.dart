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
              icon: Icon(Icons.more_vert, color: appCtrl.appTheme.white),
              itemBuilder: (context) {
                return [
                  ...dashboardCtrl.actionList
                      .asMap()
                      .entries
                      .map((e) => PopupMenuItem<int>(
                            value: 0,
                            onTap: () {
                              log("message : ${e.key}");
                            },
                            child: Text(
                              trans(e.value["title"]),
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.blackColor),
                            ).inkWell(onTap: () {
                              dashboardCtrl.selectedPopTap = e.key;
                              Get.back();
                              log("title : ${e.value["title"]}");
                              if (e.key == 0) {

                                Get.toNamed(routeName.groupChat,
                                    arguments: false);
                              } else if (e.key == 1) {

                                Get.toNamed(routeName.groupChat,
                                    arguments: true);
                              } else {
                                Get.toNamed(routeName.setting);
                              }
                              dashboardCtrl.selectedPopTap = e.key;
                              dashboardCtrl.update();
                            }),
                          ))
                      .toList(),
                ];
              },
              onSelected: (value) => dashboardCtrl.popupMenuTap(value))
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
                                  Get.back();
                                  Get.toNamed(routeName.setting);
                                }),
                              ))
                          .toList(),
                    ];
                  },
                  onSelected: (value) => dashboardCtrl.popupMenuTap(value))
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
                                  Get.back();
                                  if (e.value["title"] == "clearLogs") {
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
                                  }
                                }),
                              ))
                          .toList(),
                    ];
                  },
                  onSelected: (value) => dashboardCtrl.popupMenuTap(value));
    });
  }
}
