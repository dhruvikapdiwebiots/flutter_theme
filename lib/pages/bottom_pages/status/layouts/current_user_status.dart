import 'dart:developer';

import '../../../../config.dart';

class CurrentUserStatus extends StatelessWidget {
  final String? currentUserId;

  const CurrentUserStatus({Key? key, this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(statusCtrl.currentUserId)
              .collection(collectionName.status)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Container();
            } else if (snapshot.hasData) {
              log("HAS DATA : ${snapshot.data!.docs.length}");
              if (snapshot.data != null) {
                if (!snapshot.data!.docs.isNotEmpty) {
                  return CurrentUserEmptyStatus(
                      currentUserId: currentUserId,
                    onTap: ()=> statusCtrl.pickAssets(),);
                } else {
                  return StatusLayout(snapshot: snapshot);
                }
              } else {
                return CurrentUserEmptyStatus(
                    currentUserId: currentUserId,
                    onTap: ()=> statusCtrl.pickAssets());
              }
            } else {
              return Container();
            }
          });
    });
  }
}
