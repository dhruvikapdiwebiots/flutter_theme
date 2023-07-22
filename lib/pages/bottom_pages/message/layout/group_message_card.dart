
import 'dart:developer';

import '../../../../config.dart';

class GroupMessageCard extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;

  const GroupMessageCard({Key? key, this.document, this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
        });
  }
}
