import 'dart:developer';

import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_list_card.dart';

import '../../../../config.dart';

class ViewAllStatusListLayout extends StatefulWidget {
  const ViewAllStatusListLayout({Key? key}) : super(key: key);

  @override
  State<ViewAllStatusListLayout> createState() =>
      _ViewAllStatusListLayoutState();
}

class _ViewAllStatusListLayoutState extends State<ViewAllStatusListLayout> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {

      return GetBuilder<AppController>(builder: (appCtrl) {
        return Container(
            alignment: Alignment.topCenter,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 50,
            child: appCtrl.firebaseContact.isEmpty
                ? CommonEmptyLayout(
                    gif: gifAssets.status,
                    title: fonts.emptyStatusTitle.tr,
                    desc: fonts.emptyStatusDesc.tr)
                : Column(children: [
                    ...appCtrl.firebaseContact.asMap().entries.map((e) {
                      return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection(collectionName.users)
                              .doc(e.value["id"])
                              .collection(collectionName.status)
                              .orderBy("updateAt", descending: true)
                              .limit(15)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container();
                            } else if (!snapshot.hasData) {
                              return Container();
                            } else {
                              statusCtrl.statusList = [];
                              List status =
                                  statusCtrl.statusListWidget(snapshot);
                              status.asMap().entries.forEach((element) {
                                Status convertStatus =
                                    Status.fromJson(element.value);

                                if (element.value
                                    .containsKey("seenAllStatus")) {
                                  if (convertStatus.seenAllStatus!
                                      .contains(statusCtrl.user["id"])) {
                                    if (!statusCtrl.statusList.contains(
                                        Status.fromJson(element.value))) {
                                      if(!statusCtrl.statusList.contains(Status.fromJson(element.value))) {
                                        statusCtrl.statusList
                                            .add(
                                            Status.fromJson(element.value));
                                      }
                                    }
                                  }
                                }
                              });
                              log("statusCtrl.statusList : ${statusCtrl.statusList.length}");
                              return ListView.builder(
                                  itemCount: statusCtrl.statusList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        Get.toNamed(routeName.statusView,
                                            arguments:
                                                statusCtrl.statusList[index]);
                                      },
                                      child: StatusListCard(
                                          isSeen: true,
                                          snapshot:
                                              statusCtrl.statusList[index]),
                                    );
                                  });
                            }
                          });
                    })
                  ]));
      });
    });
  }
}
