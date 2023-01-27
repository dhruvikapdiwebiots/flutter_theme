import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:intl/intl.dart';

class CallList extends StatelessWidget {
  final callListCtrl = Get.put(CallListController());

  CallList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallListController>(builder: (_) {
      return Scaffold(
        backgroundColor: appCtrl.appTheme.whiteColor,
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(callListCtrl.user["id"])
                .collection(collectionName.collectionCallHistory)
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              log("dsds : ${snapshot.hasData}");
              if (!snapshot.hasData) {
                log("snapshot.hasData : ${snapshot.hasData}");
                return Container(
                    margin: const EdgeInsets.only(
                    bottom: Insets.i10, left: Insets.i5, right: Insets.i5));
              } else {
                return ListView.builder(
                  shrinkWrap: true,

                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding:const EdgeInsets.symmetric(horizontal: Insets.i15,vertical: Insets.i4),
                          leading: ImageLayout(id: snapshot.data!.docs[index].data()["id"] == callListCtrl.user["id"] ? snapshot.data!.docs[index].data()["receiverId"]: snapshot.data!.docs[index].data()["id"]),
                          title: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where("id", isEqualTo:snapshot.data!.docs[index].data()["id"] == callListCtrl.user["id"] ? snapshot.data!.docs[index].data()["receiverId"]: snapshot.data!.docs[index].data()["id"]  )
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                if(userSnapshot.hasData){
                                  if (snapshot.data != null) {
                                    return Text(userSnapshot.data!.docs[0].data()["name"],style: AppCss.poppinsSemiBold14.textColor(appCtrl.appTheme.blackColor),);
                                  } else {
                                    return Container();
                                  }
                                }else{
                                  return Container();
                                }
                              }),

                          subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                 snapshot.data!.docs[index].data()['type'] == 'inComing'
                                    ? ( snapshot.data!.docs[index].data()['started'] == null
                                    ? Icons.call_missed
                                    : Icons.call_received)
                                    : ( snapshot.data!.docs[index].data()['started'] == null
                                    ? Icons.call_made_rounded
                                    : Icons.call_made_rounded),
                                size: 15,
                                color:  snapshot.data!.docs[index].data()['type'] == 'inComing'
                                    ? ( snapshot.data!.docs[index].data()['started'] == null
                                    ? appCtrl.appTheme.redColor
                                    : appCtrl.appTheme.greenColor)
                                    : ( snapshot.data!.docs[index].data()['started'] == null
                                    ? appCtrl.appTheme.redColor
                                    : appCtrl.appTheme.greenColor),
                              ),
                              const HSpace(Sizes.s5),
                              Text(
                                  DateFormat('MMMM dd, HH:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(snapshot.data!.docs[index].data()["timestamp"].toString()))),
                                  style: AppCss.poppinsMedium12
                                      .textColor(appCtrl.appTheme.accent))
                            ]
                          ),
                          trailing: Icon(snapshot.data!.docs[index].data()["isVideoCall"] ?Icons.video_camera_back : Icons.call,color: appCtrl.appTheme.primary),
                        ),
                        Divider(color: appCtrl.appTheme.lightGrey1Color,endIndent: Insets.i15,indent: Insets.i15,height: 1,)
                      ],
                    );
                  },
                  itemCount: snapshot.data!.docs.length,
                );
              }
            }),
      );
    });
  }
}
