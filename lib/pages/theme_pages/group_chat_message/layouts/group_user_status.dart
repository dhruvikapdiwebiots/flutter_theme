import '../../../../config.dart';

class GroupUserLastSeen extends StatelessWidget {
  const GroupUserLastSeen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("groups")
              .doc(chatCtrl.pId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.data()!["status"] != ""
                  ? Text(
                      snapshot.data!
                              .data()!["status"]
                              .contains(chatCtrl.user["name"])
                          ? chatCtrl.nameList
                          : snapshot.data!.data()!["status"],
                      textAlign: TextAlign.center,
                      style: AppCss.poppinsMedium12
                          .textColor(appCtrl.appTheme.whiteColor),
                    )
                  : Text(
                      chatCtrl.nameList ?? "",
                      textAlign: TextAlign.center,
                      style: AppCss.poppinsMedium12
                          .textColor(appCtrl.appTheme.whiteColor),
                    );
            } else {
              return Text(
                chatCtrl.nameList ?? "",
                textAlign: TextAlign.center,
                style: AppCss.poppinsMedium12
                    .textColor(appCtrl.appTheme.whiteColor),
              );
            }
          });
    });
  }
}
