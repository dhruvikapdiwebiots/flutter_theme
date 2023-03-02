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
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: appCtrl.appTheme.primary,
          child: Container(
            width: Sizes.s52,
            height: Sizes.s52,
            padding: const EdgeInsets.all(Insets.i12),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  appCtrl.appTheme.lightPrimary,
                  appCtrl.appTheme.primary
                ])),
            child: SvgPicture.asset(svgAssets.callAdd,height: Sizes.s15),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(callListCtrl.user["id"])
                .collection(collectionName.collectionCallHistory)
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {

                return Container(
                    margin: const EdgeInsets.only(
                        bottom: Insets.i10, left: Insets.i5, right: Insets.i5));
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: Insets.i10),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          horizontalTitleGap:12,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: Insets.i15, vertical: Insets.i4),
                          leading: ImageLayout(
                            isLastSeen: false,
                              id: snapshot.data!.docs[index].data()["id"] ==
                                      callListCtrl.user["id"]
                                  ? snapshot.data!.docs[index]
                                      .data()["receiverId"]
                                  : snapshot.data!.docs[index].data()["id"]),
                          title: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where("id",
                                      isEqualTo: snapshot.data!.docs[index]
                                                  .data()["id"] ==
                                              callListCtrl.user["id"]
                                          ? snapshot.data!.docs[index]
                                              .data()["receiverId"]
                                          : snapshot.data!.docs[index]
                                              .data()["id"])
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.hasData) {
                                  if (snapshot.data != null) {
                                    return Text(
                                      userSnapshot.data!.docs[0].data()["name"],
                                      style: AppCss.poppinsSemiBold14.textColor(
                                          appCtrl.appTheme.blackColor),
                                    );
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Container();
                                }
                              }),
                          subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  snapshot.data!.docs[index].data()['type'] ==
                                          'inComing'
                                      ? (snapshot.data!.docs[index]
                                                  .data()['started'] ==
                                              null
                                          ? Icons.call_missed
                                          : Icons.call_received)
                                      : (snapshot.data!.docs[index]
                                                  .data()['started'] ==
                                              null
                                          ? Icons.call_made_rounded
                                          : Icons.call_made_rounded),
                                  size: 15,
                                  color: snapshot.data!.docs[index]
                                              .data()['type'] ==
                                          'inComing'
                                      ? (snapshot.data!.docs[index]
                                                  .data()['started'] ==
                                              null
                                          ? appCtrl.appTheme.redColor
                                          : appCtrl.appTheme.greenColor)
                                      : (snapshot.data!.docs[index]
                                                  .data()['started'] ==
                                              null
                                          ? appCtrl.appTheme.redColor
                                          : appCtrl.appTheme.greenColor),
                                ),
                                const HSpace(Sizes.s5),
                                Text(
                                    DateFormat('dd/MM/yy, HH:mm a').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(snapshot.data!.docs[index]
                                                .data()["timestamp"]
                                                .toString()))),
                                    style: AppCss.poppinsMedium12
                                        .textColor(appCtrl.appTheme.statusTxtColor))
                              ]),
                          trailing: SvgPicture.asset(
                              snapshot.data!.docs[index].data()["isVideoCall"]
                                  ? svgAssets.videoCallFilled
                                  : svgAssets.callFilled,
                              color: appCtrl.appTheme.primary),
                        ),
                        const Divider(
                          color: Color.fromRGBO(49, 100, 189, .1),
                          endIndent: Insets.i15,
                          indent: Insets.i15,
                          height: 2,thickness: 1,
                        )
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
