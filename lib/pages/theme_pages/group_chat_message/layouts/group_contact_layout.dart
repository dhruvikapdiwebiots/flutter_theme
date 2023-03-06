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
              margin: EdgeInsets.symmetric(horizontal: Insets.i5),
                decoration: ShapeDecoration(
                  color:isReceiver
                      ? const Color.fromRGBO(153, 158, 166, 0.1)
                      : appCtrl.appTheme.primary,
                  shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: const SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing: .5,
                          ),
                          topRight: const SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing: 0.4,
                          ),
                          bottomLeft: SmoothRadius(
                            cornerRadius:isReceiver ? 0 : 20,
                            cornerSmoothing: .5,
                          ),
                          bottomRight: SmoothRadius(
                            cornerRadius:isReceiver ? 20 : 0,
                            cornerSmoothing: .5,
                          ))),
                ),
                width: Sizes.s250,
                height: isReceiver ?Sizes.s150 : Sizes.s110,
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
          ],
        )

            .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10));
  }
}
