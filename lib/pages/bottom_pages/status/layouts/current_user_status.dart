
import 'package:flutter_theme/pages/bottom_pages/status/layouts/current_user_empty_status.dart';
import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_layout.dart';

import '../../../../config.dart';

class CurrentUserStatus extends StatelessWidget {
  final String? currentUserId;
  const CurrentUserStatus({Key? key,this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('status')
            .where("uid", isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            if (!snapshot.data!.docs.isNotEmpty) {
              return CurrentUserEmptyStatus(onTap: () {
                Status status = Status.fromMap(
                    snapshot.data!.docs[0].data());

                Get.toNamed(routeName.statusView,
                    arguments: status);
              });
            } else {
              return StatusLayout(snapshot: snapshot);
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
