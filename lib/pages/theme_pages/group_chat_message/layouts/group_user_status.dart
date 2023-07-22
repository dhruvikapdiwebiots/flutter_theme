import 'dart:developer';

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
              log("USERID : ${chatCtrl.pId}");
              List userList = snapshot.data!.data()!["users"];
              String status = snapshot.data!.data()!["status"] ?? "";
              return  status != ""
                  ? status.contains(appCtrl.user["name"]) ? snapshot.data!.data()!["users"] != ""
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
              ) : Text(
                      status,
                      textAlign: TextAlign.center,
                      style: AppCss.poppinsMedium14
                          .textColor(appCtrl.appTheme.txtColor),
                    )
                  : snapshot.data!.data()!["users"] != ""
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
                        );
            } else {
              return Container();
            }
          });
    });
  }
}
