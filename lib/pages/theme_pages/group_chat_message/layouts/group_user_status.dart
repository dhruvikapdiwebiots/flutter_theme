
import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupUserLastSeen extends StatelessWidget {
  const GroupUserLastSeen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder<GroupChatMessageController>(
        builder: (chatCtrl) {
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groupMessage').doc(chatCtrl.pId).collection("chat").doc(chatCtrl.documentId)
                  .snapshots(),
              builder: (context, snapshot) {
                print("snapshot.data : ${snapshot.data!}" );
                if (snapshot.data != null) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                appCtrl.appTheme.primary)));
                  } else {

                    chatCtrl.message = (snapshot.data!.data());
                    return Text(
                      snapshot.data!.data()!["status"].contains(chatCtrl.user["name"]) ? "" : snapshot.data!.data()!["status"],
                      textAlign: TextAlign.center,
                      style: AppCss.poppinsMedium14
                          .textColor(appCtrl.appTheme.whiteColor),
                    );
                  }
                } else {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              appCtrl.appTheme.primary)));
                }
              });
        }
    );
  }
}
