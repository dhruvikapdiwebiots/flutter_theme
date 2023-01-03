import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../config.dart';

class UserLastSeen extends StatelessWidget {
  const UserLastSeen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ChatController>(
      builder: (chatCtrl) {
        log("pid : ${chatCtrl.pId}");
        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
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
                        .textColor(appCtrl.appTheme.grey),
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
