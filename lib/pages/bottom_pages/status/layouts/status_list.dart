import 'dart:developer';

import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_list_card.dart';

import '../../../../config.dart';

class StatusListLayout extends StatefulWidget {
  const StatusListLayout({Key? key}) : super(key: key);

  @override
  State<StatusListLayout> createState() => _StatusListLayoutState();
}

class _StatusListLayoutState extends State<StatusListLayout> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return GetBuilder<AppController>(builder: (appCtrl) {
        debugPrint("appCtrl.userContactList : ${appCtrl.userContactList}");
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 50,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(collectionName.users)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  log("DATA : ${snapshot.data!.docs[0].data()}");
                  bool isExist =
                      checkUserExist(snapshot.data!.docs[0].data()["phone"]);
                  return isExist
                      ? StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection(collectionName.users)
                              .doc(snapshot.data!.docs[0].data()["id"])
                              .collection(collectionName.status)
                              .orderBy("updatedAt", descending: true)
                              .limit(15)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            } else {
                              debugPrint("snapshot : ${snapshot.data}");
                              if (appCtrl.userContactList.isNotEmpty) {
                                statusCtrl.status = StatusFirebaseApi()
                                    .getStatusUserList(appCtrl.userContactList,
                                        snapshot.data!);
                              }
                              return ListView.builder(
                                itemCount: statusCtrl.status.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Get.toNamed(routeName.statusView,
                                          arguments: statusCtrl.status[index]);
                                    },
                                    child: StatusListCard(
                                        index: index,
                                        snapshot: statusCtrl.status[index],
                                        status: statusCtrl.status),
                                  );
                                },
                              );
                            }
                          })
                      : Container();
                } else {
                  return Container();
                }
              }),
        );
      });
    });
  }
}
