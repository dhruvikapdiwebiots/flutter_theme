

import '../../../../config.dart';

class GroupMessageCardLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final String? currentUserId;
  final dynamic data;

  const GroupMessageCardLayout({
    Key? key,
    this.document,
    this.currentUserId,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(collectionName.groups)
                    .doc(document!["groupId"])
                    .snapshots(),
                builder: (context, snapshot) {
                  return CommonImage(
                    image: snapshot.hasData? snapshot.data!.exists ? (snapshot.data!)["image"] :"" :"",
                    name: document!["name"]);
                }
              ),
            const HSpace(Sizes.s12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(document!["name"] ?? "GROUP",
                  style: AppCss.poppinsblack14
                      .textColor(appCtrl.appTheme.blackColor)),
              const VSpace(Sizes.s5),
              GroupCardSubTitle(
                  currentUserId: currentUserId,
                  name: document!["name"],
                  data: data,
                  document: document,
                  hasData: true)
            ])
          ]),
            StreamBuilder(
              stream:  FirebaseFirestore.instance.collection(collectionName.users).doc(appCtrl.user["id"])
                  .collection(collectionName.groupMessage)
                  .doc(document!["groupId"])
                  .collection(collectionName.chat).where("sender",isNotEqualTo: appCtrl.user["id"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {

                  int number = getGroupUnseenMessagesNumber(snapshot.data!.docs);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          data["time"],
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
