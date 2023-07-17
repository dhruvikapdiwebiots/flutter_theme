import 'dart:developer';

import '../../../../config.dart';

class StatusListStream extends StatelessWidget {
  final String? id;

  const StatusListStream({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
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
              List<Status> statusList = [];
              List status = statusCtrl.statusListWidget(snapshot);
              log("status : ${status.length}");
              status.asMap().entries.forEach((element) {
                Status convertStatus = Status.fromJson(element.value);
                log("CONTAINS : $id");
                if (element.value.containsKey("seenAllStatus")) {

                  if (convertStatus.seenAllStatus!
                      .contains(statusCtrl.user["id"])) {
                    if (!statusList.contains(Status.fromJson(element.value))) {
                      statusCtrl.isData = true;
                      statusList.add(Status.fromJson(element.value));
                    }
                  }
                }
              });

              log("statusList : $statusList");

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
    });
  }
}
