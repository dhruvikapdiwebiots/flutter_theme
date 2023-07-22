import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupMessageCardLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;
  final AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>? userSnapShot,
      snapshot;

  const GroupMessageCardLayout(
      {Key? key,
      this.document,
      this.currentUserId,
      this.userSnapShot,
      this.snapshot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("SNAP  : ${(snapshot!.data!.exists)}");
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            CommonImage(
                image: snapshot!.data!.exists ? (snapshot!.data!)["image"] :"",
                name: snapshot!.data!.exists ?  (snapshot!.data!)["name"] :"C"),
            const HSpace(Sizes.s12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(snapshot!.data!.exists ? snapshot!.data!["name"]:"",
                  style: AppCss.poppinsblack14
                      .textColor(appCtrl.appTheme.blackColor)),
              const VSpace(Sizes.s5),
              document!["lastMessage"] != null
                  ? GroupCardSubTitle(
                      currentUserId: currentUserId,
                      name: userSnapShot!.data!["name"],
                      document: document,
                      hasData: userSnapShot!.hasData)
                  : Container(height: Sizes.s15)
            ])
          ]),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(collectionName.groups)
                  .doc(document!["groupId"])
                  .collection(collectionName.chat)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int number = getGroupUnseenMessagesNumber(snapshot.data!.docs);
                  return Column(
                    children: [
                      Text(
                          DateFormat('HH:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(document!['updateStamp']))),
                          style: AppCss.poppinsMedium12
                              .textColor(currentUserId == document!["senderId"]
                                  ? appCtrl.appTheme.txtColor
                                  : number == 0
                                      ? appCtrl.appTheme.txtColor
                                      : appCtrl.appTheme.primary)),
                      if ((currentUserId != document!["senderId"]))
                        number == 0
                            ? Container()
                            : Container(
                                height: Sizes.s20,
                                width: Sizes.s20,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: Insets.i5),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        appCtrl.appTheme.lightPrimary,
                                        appCtrl.appTheme.primary
                                      ],
                                    )),
                                child: Text(number.toString(),
                                    textAlign: TextAlign.center,
                                    style: AppCss.poppinsSemiBold10
                                        .textColor(appCtrl.appTheme.whiteColor)
                                        .textHeight(1.3))),
                    ],
                  );
                } else {
                  return Container();
                }
              }),
        ]).paddingSymmetric(vertical: Insets.i10);
  }
}
