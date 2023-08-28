
import '../../../../config.dart';

class GroupUserLastSeen extends StatelessWidget {
  const GroupUserLastSeen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(collectionName.groups)
              .doc(chatCtrl.pId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              String nameList = "";
              List userList =
                  snapshot.data!.exists ? snapshot.data!.data()!["users"] : [];
              for (var i = 0; i < userList.length; i++) {
                if (nameList != "") {
                  nameList = "$nameList, ${userList[i]["name"]}";
                } else {
                  nameList = userList[i]["name"];
                }
              }
              String status = snapshot.data!.exists
                  ? snapshot.data!.data()!["status"] ?? ""
                  : "";
              return status != ""
                  ? status.contains(appCtrl.user["name"])
                      ? snapshot.data!.data()!["users"] != ""
                          ? Text(
                              "${userList.length == 1 ? 1 : (userList.length - 1).toString()} ${fonts.people.tr}",
                              textAlign: TextAlign.center,
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.txtColor),
                            )
                          : Text(
                              chatCtrl.nameList!.length.toString(),
                              textAlign: TextAlign.center,
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.txtColor),
                            )
                      : Text(
                          status,
                          textAlign: TextAlign.center,
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.txtColor),
                        )
                  : snapshot.data!.exists
                      ? snapshot.data!.data()!["users"] != ""
                          ? Text(
                              nameList,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.txtColor),
                            )
                          : Text(
                              chatCtrl.nameList!.length.toString(),
                              textAlign: TextAlign.center,
                              style: AppCss.poppinsMedium14
                                  .textColor(appCtrl.appTheme.txtColor),
                            )
                      : Text(
                          "${userList.length == 1 ? 1 : (userList.length - 1).toString()} ${fonts.people.tr}",
                          textAlign: TextAlign.center,
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.txtColor),
                        );
            } else {
              return Container();
            }
          });
    });
  }
}
