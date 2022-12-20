
import '../../../../config.dart';

class GroupUserLastSeen extends StatelessWidget {
  const GroupUserLastSeen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("groupMessage")
              .doc(chatCtrl.pId)
              .collection("chat")
              .snapshots(),
          builder: (context, snapshot) {
            return snapshot.data!.docs.isEmpty
                ? Container()
                : Text(
                    snapshot.data!.docs[0]
                            .data()["status"]
                            .contains(chatCtrl.user["name"])
                        ? ""
                        : snapshot.data!.docs[0].data()["status"],
                    textAlign: TextAlign.center,
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.whiteColor),
                  );
          });
    });
  }
}
