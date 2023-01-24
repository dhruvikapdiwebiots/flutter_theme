import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupContactLayout extends StatelessWidget {
  final DocumentSnapshot? document;
  final VoidCallback? onLongPress;
  final String? currentUserId;
  final bool isReceiver;

  const GroupContactLayout(
      {Key? key,
      this.document,
      this.onLongPress,
      this.currentUserId,
      this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(
        onLongPress: onLongPress,
        child: Stack(
          alignment: isReceiver ? Alignment.topLeft : Alignment.topRight,
          children: [
            Container(
                decoration: BoxDecoration(
                    color: isReceiver
                        ? appCtrl.appTheme.white
                        : appCtrl.appTheme.primary,
                    borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(AppRadius.r8),
                        bottomRight: const Radius.circular(AppRadius.r8),
                        topLeft: isReceiver
                            ? const Radius.circular(0)
                            : const Radius.circular(AppRadius.r8),
                        topRight: isReceiver
                            ? const Radius.circular(AppRadius.r8)
                            : const Radius.circular(0))),
                width: Sizes.s250,
                height: isReceiver ?Sizes.s150 : Sizes.s120,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isReceiver)
                            if (document!["sender"] != currentUserId)
                              Column(children: [
                                Text(document!['senderName'],
                                    style: AppCss.poppinsMedium12
                                        .textColor(appCtrl.appTheme.primary)),
                              ]).paddingAll(Insets.i10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ContactListTile(
                                document: document,
                                isReceiver: isReceiver,
                              ).marginOnly(top: Insets.i5),
                              Text(
                                DateFormat('HH:mm a').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document!['timestamp']))),
                                style: AppCss.poppinsMedium12.textColor(isReceiver
                                    ? appCtrl.appTheme.primary
                                    : appCtrl.appTheme.whiteColor),
                              ).marginSymmetric(horizontal: Insets.i10),
                            ],
                          )
                        ],
                      ),
                      const VSpace(Sizes.s8),
                      Divider(
                          thickness: 1.5,
                          color: isReceiver
                              ? appCtrl.appTheme.lightDividerColor
                                  .withOpacity(.2)
                              : appCtrl.appTheme.whiteColor,
                          height: 1),
                      IntrinsicHeight(
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                            Expanded(
                                child: InkWell(
                              onTap: () {
                                UserContactModel user = UserContactModel(
                                    uid: " 0",
                                    isRegister: false,
                                    image: document!['content']
                                        .split('-BREAK-')[2],
                                    username: document!['content']
                                        .split('-BREAK-')[0],
                                    phoneNumber: phoneNumberExtension(
                                        document!['content']
                                            .split('-BREAK-')[1]),
                                    description: "");
                                MessageFirebaseApi().saveContact(user, true);
                              },
                              child: Text(fonts.message.tr,
                                      textAlign: TextAlign.center,
                                      style: AppCss.poppinsExtraBold12
                                          .textColor(isReceiver
                                              ? appCtrl.appTheme.lightBlackColor
                                              : appCtrl.appTheme.whiteColor))
                                  .marginSymmetric(vertical: Insets.i15),
                            )),
                            VerticalDivider(
                              endIndent: 10,
                              indent: 10,
                              thickness: 1.5,
                              color: isReceiver
                                  ? appCtrl.appTheme.lightDividerColor
                                      .withOpacity(.2)
                                  : appCtrl.appTheme.whiteColor,
                            ),
                            Expanded(
                                child: InkWell(
                              onTap: () {},
                              child: Text(fonts.name.tr,
                                  textAlign: TextAlign.center,
                                  style: AppCss.poppinsExtraBold12.textColor(
                                      isReceiver
                                          ? appCtrl.appTheme.lightBlackColor
                                          : appCtrl.appTheme.whiteColor)),
                            ))
                          ]))
                    ])),
            CustomPaint(
                painter: CustomShape(isReceiver
                    ? appCtrl.appTheme.whiteColor
                    : appCtrl.appTheme.primary)),
          ],
        )
            .decorated(
                color: isReceiver
                    ? appCtrl.appTheme.whiteColor
                    : appCtrl.appTheme.primary,
                borderRadius: BorderRadius.only(
                    bottomRight: const Radius.circular(Insets.i8),
                    topRight: isReceiver
                        ? const Radius.circular(Insets.i8)
                        : const Radius.circular(0),
                    topLeft: isReceiver
                        ? const Radius.circular(0)
                        : const Radius.circular(Insets.i8),
                    bottomLeft: const Radius.circular(Insets.i8)))
            .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10));
  }
}
