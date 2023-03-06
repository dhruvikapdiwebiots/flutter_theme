import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../config.dart';

class ContactLayout extends StatelessWidget {
  final dynamic document;
  final VoidCallback? onLongPress;

  final bool isReceiver;

  const ContactLayout(
      {Key? key, this.document, this.onLongPress, this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Insets.i5),
                decoration: ShapeDecoration(
                  color: isReceiver
                      ? appCtrl.appTheme.chatSecondaryColor
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
                            cornerRadius: isReceiver ? 0 : 20,
                            cornerSmoothing: .5,
                          ),
                          bottomRight: SmoothRadius(
                            cornerRadius: isReceiver ? 20 : 0,
                            cornerSmoothing: .5,
                          ))),
                ),
                width: Sizes.s250,
                height: Sizes.s110,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ContactListTile(
                            document: document,
                            isReceiver: isReceiver,
                          ).marginOnly(top: Insets.i5),

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
                                log("con : ${user.phoneNumber}");
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
            const VSpace(Sizes.s5),
            Text(
              DateFormat('HH:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(document!['timestamp']))),
              style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor),
            ).marginSymmetric(horizontal: Insets.i5)
          ],
        ).marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10));
  }
}
