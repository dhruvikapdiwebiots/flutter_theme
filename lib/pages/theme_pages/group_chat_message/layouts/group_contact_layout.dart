import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupContactLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final VoidCallback? onLongPress,onTap;
  final String? currentUserId;
  final bool isReceiver;

  const GroupContactLayout(
      {Key? key,
      this.document,
      this.onLongPress,
      this.currentUserId,
      this.isReceiver = false,this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
                decoration: ShapeDecoration(
                    color: isReceiver
                        ? appCtrl.appTheme.chatSecondaryColor
                        : appCtrl.appTheme.primary,
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius.only(
                            topLeft: const SmoothRadius(
                                cornerRadius: 20, cornerSmoothing: 1),
                            topRight: const SmoothRadius(
                                cornerRadius: 20, cornerSmoothing: 1),
                            bottomLeft: SmoothRadius(
                                cornerRadius: isReceiver ? 0 : 20,
                                cornerSmoothing: 1),
                            bottomRight: SmoothRadius(
                                cornerRadius: isReceiver ? 20 : 0,
                                cornerSmoothing: 1)))),
                width:  Sizes.s250 ,
                height:isReceiver ? Sizes.s150:Sizes.s120,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (document!["sender"] != currentUserId)
                        Column(children: [
                          Text(document!['senderName'],
                              style: AppCss.poppinsMedium12
                                  .textColor(appCtrl.appTheme.primary)).paddingAll(Insets.i5).decorated(color: appCtrl.appTheme.whiteColor,borderRadius: BorderRadius.circular(AppRadius.r20)),

                        ]).marginSymmetric(horizontal: Insets.i10,vertical: Insets.i5),
                      Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ContactListTile(
                                document: document, isReceiver: isReceiver)
                                .marginOnly(top: Insets.i5)
                          ]),
                      const VSpace(Sizes.s8),
                      Divider(
                          thickness: 1.5,
                          color: isReceiver
                              ? appCtrl.appTheme.lightDividerColor.withOpacity(.2)
                              : appCtrl.appTheme.white,
                          height: 1),
                      Column(
                        children: [
                          InkWell(
                              onTap: () {
                                UserContactModel user = UserContactModel(
                                    uid: "0",
                                    isRegister: false,
                                    image: decryptMessage(document!['content']).split('-BREAK-')[2],
                                    username:
                                    decryptMessage(document!['content']).split('-BREAK-')[0],
                                    phoneNumber: phoneNumberExtension(
                                        decryptMessage(document!['content']).split('-BREAK-')[1]),
                                    description: "");
                                MessageFirebaseApi().saveContact(user);
                              },
                              child: Text(fonts.message.tr,
                                  textAlign: TextAlign.center,
                                  style: AppCss.poppinsExtraBold12.textColor(
                                      isReceiver
                                          ? appCtrl.appTheme.lightBlackColor
                                          : appCtrl.appTheme.white))
                                  .marginSymmetric(vertical: Insets.i12)),
                          IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (document!.data().toString().contains('isFavourite'))
                                    if(appCtrl.user["id"] == document!["favouriteId"])
                                    Icon(Icons.star,color: appCtrl.appTheme.txtColor,size: Sizes.s10),
                                  const HSpace(Sizes.s3),
                                  Text(
                                    DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document!['timestamp']))),
                                    style:
                                    AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor),
                                  ),
                                ],
                              ).alignment(Alignment.bottomRight).marginSymmetric(horizontal: Insets.i10)
                          )
                        ],
                      )
                    ])),
            if (document!.data().toString().contains('emoji'))
              EmojiLayout(emoji: document!["emoji"])
          ],
        )

            .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10));
  }
}
