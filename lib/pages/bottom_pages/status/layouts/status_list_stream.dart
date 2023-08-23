import 'dart:developer';

import '../../../../config.dart';

class StatusListStream extends StatelessWidget {
  final String? id;

  const StatusListStream({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      log("id : $id");
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(id)
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
              if (snapshot.data!.docs.isNotEmpty) {
                Status status = Status.fromJson(snapshot.data!.docs[0].data());
                for (var photo in status.photoUrl!) {
                  if (photo.seenBy!
                      .where((element) => element["uid"] == appCtrl.user["id"])
                      .isEmpty) {
                    if (!statusCtrl.statusList.contains(status)) {
                      statusCtrl.statusList.add(status);
                    }
                  }
                }
                if (status.seenAllStatus != null &&
                    status.seenAllStatus!.isNotEmpty) {
                  bool isExist =status.seenAllStatus!
                      .where((element) => element == appCtrl.user["uid"])
                      .isNotEmpty;
                  if (isExist) {
                    if (!statusCtrl.allViewStatusList.contains(status)) {
                      statusCtrl.allViewStatusList.add(status);
                    }
                  }
                }
              }

              return ListView.builder(
                  itemCount: statusCtrl.statusList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        log("LENGTH : ${statusCtrl.statusList}");
                        Get.toNamed(routeName.statusView,
                            arguments: statusCtrl.statusList[index]);
                      },
                      child: StatusListCard(
                          snapshot: statusCtrl.statusList[index]),
                    );
                  });
            }
          });
    });
  }
}
