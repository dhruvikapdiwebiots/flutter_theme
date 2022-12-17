
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
                  .collection('groups')
                  .where("id", isEqualTo: chatCtrl.pId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                appCtrl.appTheme.primary)));
                  } else {
                    chatCtrl.message = (snapshot.data!).docs;
                    return Text(
                      snapshot.data!.docs[0]["status"] == "Offline"
                          ? DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(snapshot.data!.docs[0]
                              ['lastSeen'])))
                          : snapshot.data!.docs[0]["status"],
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
