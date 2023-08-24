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
                .collection('users').doc(chatCtrl.pId)

                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  return chatCtrl.pId ==  "0" ? Container(): Text(
                      snapshot.data!.exists?   snapshot.data!.data()!["status"] == "Offline"
                        ? DateFormat('HH:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(snapshot.data!.data()!
                            ['lastSeen'])))
                        : snapshot.data!.data()!["status"] : "Offline",
                    textAlign: TextAlign.center,
                    style: AppCss.poppinsLight14
                        .textColor(appCtrl.appTheme.txtColor),
                  );
                }
              } else {
                return Container();
              }
            });
      }
    );
  }
}
