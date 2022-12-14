
import 'package:intl/intl.dart';

import '../../../../config.dart';

class UserOnlineStatus extends StatelessWidget {
  final String? id;
  const UserOnlineStatus({Key? key,this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where("id", isEqualTo: id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          appCtrl.appTheme.primary)));
            } else {
              return Text(
                  snapshot.data!.docs[0]["status"] == "Offline"
                      ? DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(snapshot.data!.docs[0]
                          ['lastSeen'])))
                      : snapshot.data!.docs[0]["status"],
                  textAlign: TextAlign.center,
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.grey)
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
}
