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
                .collection("calls")
                .doc(callListCtrl.user["id"])
                .collection("calling")
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
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
                          contentPadding: EdgeInsets.symmetric(horizontal: Insets.i15,vertical: Insets.i4),
                          leading: CachedNetworkImage(
                              imageUrl:
                                  "https://firebasestorage.googleapis.com/v0/b/chatter-e3d94.appspot.com/o/1674202399738?alt=media&token=8d63cac9-2096-4048-a3bd-7413664a61c8",
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                    backgroundColor: appCtrl.appTheme.contactBgGray,
                                    radius: Sizes.s22,
                                    backgroundImage: NetworkImage(
                                        'https://firebasestorage.googleapis.com/v0/b/chatter-e3d94.appspot.com/o/1674202399738?alt=media&token=8d63cac9-2096-4048-a3bd-7413664a61c8'),
                                  ),
                              placeholder: (context, url) => Image.asset(
                                    imageAssets.user,
                                    color: appCtrl.appTheme.whiteColor,
                                  ).paddingAll(Insets.i15).decorated(
                                      color: appCtrl.appTheme.grey.withOpacity(.4),
                                      shape: BoxShape.circle),
                              errorWidget: (context, url, error) => Image.asset(
                                    imageAssets.user,
                                    color: appCtrl.appTheme.whiteColor,
                                  ).paddingAll(Insets.i15).decorated(
                                      color: appCtrl.appTheme.grey.withOpacity(.4),
                                      shape: BoxShape.circle)),
                          title: Text("Dhruvi",
                              style: AppCss.poppinsblack14
                                  .textColor(appCtrl.appTheme.blackColor)),

                          subtitle: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.call_received,size: Sizes.s15,color: appCtrl.appTheme.redColor,),
                              const HSpace(Sizes.s5),
                              Text(
                                  DateFormat('MMMM dd, HH:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse("1674220689935"))),
                                  style: AppCss.poppinsMedium12
                                      .textColor(appCtrl.appTheme.accent))
                            ]
                          ),
                          trailing: Icon(Icons.call,color: appCtrl.appTheme.primary),
                        ),
                      ],
                    );
                  },
                  itemCount: 10,
                );
              }
            }),
      );
    });
  }
}
