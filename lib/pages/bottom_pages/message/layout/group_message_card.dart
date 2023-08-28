

import '../../../../config.dart';

class GroupMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;
  final dynamic data;

  const GroupMessageCard(
      {Key? key, this.document, this.currentUserId, this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName.groups)
            .doc(document!["groupId"])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {

            return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(document!["senderId"])
                        .snapshots(),
                    builder: (context, userSnapShot) {
                      if (userSnapShot.hasData) {
                        return GroupMessageCardLayout(
                                snapshot: snapshot,
                                document: document,
                                data: data,
                                currentUserId: currentUserId,
                                userSnapShot: userSnapShot,)
                            .inkWell(onTap: () {
                          var data = {
                            "message": document!.data(),
                            "groupData": snapshot.data!.data()
                          };
                          Get.toNamed(routeName.groupChatMessage,
                              arguments: data);
                        });
                      } else {
                        return Container();
                      }
                    })
                .width(MediaQuery.of(context).size.width)
                .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i4)
                .commonDecoration()
                .marginSymmetric(horizontal: Insets.i10);
          }
        });*/
    return GroupMessageCardLayout(
      document: document,
      data: data,
      currentUserId: currentUserId,
    )
        .width(MediaQuery.of(context).size.width)
        .paddingSymmetric(horizontal: Insets.i15, vertical: Insets.i4)
        .commonDecoration()
        .marginSymmetric(horizontal: Insets.i10)
        .inkWell(onTap: () async {
      await FirebaseFirestore.instance
          .collection(collectionName.groups)
          .doc(document!["groupId"])
          .get()
          .then((value) {
        var data = {
          "message": document!.data(),
          "groupData": value.data()
        };
        Get.toNamed(routeName.groupChatMessage,
            arguments: data);
      });
    });
  }
}
