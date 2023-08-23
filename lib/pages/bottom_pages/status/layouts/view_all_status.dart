import 'dart:developer';

import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_list_card.dart';
import 'package:provider/provider.dart';

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
        return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
          return Consumer<FetchContactController>(
              builder: (context, availableContacts, _child) {
log("ALLL : ${statusCtrl.allViewStatusList.length}");
            return Stack(
              children: [
                Container(
                    alignment: Alignment.topCenter,
                    width: MediaQuery.of(context).size.width,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                   /*   ...availableContacts
                          .alreadyJoinedSavedUsersPhoneNameAsInServer
                          .asMap()
                          .entries
                          .map((e) {
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(collectionName.users)
                                .doc(e.value.id)
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
                                List<Status> statusList = [];
                                List status = statusCtrl.statusListWidget(snapshot);

                                status.asMap().entries.forEach((element) {
                                  Status convertStatus = Status.fromJson(element.value);

                                  if (element.value.containsKey("seenAllStatus")) {

                                    if (convertStatus.seenAllStatus!
                                        .contains(statusCtrl.user["id"])) {
                                      if (!statusList.contains(Status.fromJson(element.value))) {
                                        statusList.add(Status.fromJson(element.value));
                                      }
                                    }
                                  }
                                });

                                return ListView.builder(
                                    itemCount: statusList.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Get.toNamed(routeName.statusView,
                                              arguments: statusList[index]);
                                        },
                                        child: StatusListCard(snapshot: statusList[index]),
                                      );
                                    });
                              }
                            });
                      })*/
                      ListView.builder(
                          itemCount: statusCtrl.allViewStatusList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Get.toNamed(routeName.statusView,
                                    arguments: statusCtrl.allViewStatusList[index]);
                              },
                              child: StatusListCard(snapshot: statusCtrl.allViewStatusList[index]),
                            );
                          })
                    ])),
              ],
            );
          });
        });
      });
    });
  }
}
