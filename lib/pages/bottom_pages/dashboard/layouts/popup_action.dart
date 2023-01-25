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
                              log("e.key :: ${e.key}");
                              Get.back();
                              log("title : ${e.value["title"]}");
                              if (e.value["title"] == "newBroadCast") {
                                final groupChatCtrl =
                                    Get.isRegistered<CreateGroupController>()
                                        ? Get.find<CreateGroupController>()
                                        : Get.put(CreateGroupController());
                                groupChatCtrl.isGroup = false;
                                if(groupChatCtrl.contacts!.isEmpty) {
                                  groupChatCtrl.refreshContacts();
                                }
                                Get.toNamed(routeName.groupChat,
                                    arguments: false);
                              } else if (e.value["title"] == "newGroup") {
                                final groupChatCtrl =
                                    Get.isRegistered<CreateGroupController>()
                                        ? Get.find<CreateGroupController>()
                                        : Get.put(CreateGroupController());
                                groupChatCtrl.isGroup = true;
                                if(groupChatCtrl.contacts!.isEmpty) {
                                  groupChatCtrl.refreshContacts();
                                }
                                groupChatCtrl.update();
                                Get.toNamed(routeName.groupChat,
                                    arguments: true);
                              } else {
                                Get.toNamed(routeName.setting);
                              }
                              dashboardCtrl.update();
                            }),
                          ))
                      .toList(),
                ];
              },
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
                                  Get.back();
                                  Get.toNamed(routeName.setting);
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
                                  } else {
                                    Get.toNamed(routeName.setting);
                                  }
                                }),
                              ))
                          .toList(),
                    ];
                  },
                );
    });
  }
}
