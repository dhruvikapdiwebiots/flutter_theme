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
        debugPrint(
            "appCtrl.userContactList : ${appCtrl.userContactList.length}");
        return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 50,
            child: Column(children: [
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
                      if (!snapshot.hasData) {
                        return Container();
                      } else {
                        List<Status> statusList = [];
                        List status = statusCtrl.statusListWidget(snapshot);
                        status.asMap().entries.forEach((element) {
                          statusList.add(Status.fromJson(element.value));
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
                                child: StatusListCard(
                                    index: index,
                                    snapshot: statusList[index],
                                    status: statusList),
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
