import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';
import '../../../../config.dart';

class ContactLayout extends StatelessWidget {
  final MessageModel? document;
  final VoidCallback? onLongPress, onTap;
final String? userId;
  final bool isReceiver, isBroadcast;

  const ContactLayout(
      {Key? key,
      this.document,
      this.onLongPress,
      this.onTap,
      this.userId,
      this.isReceiver = false,
      this.isBroadcast = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Stack(
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
                        InkWell(
                            onTap: () {
                              UserContactModel user = UserContactModel(
                                  uid: "0",
                                  isRegister: false,
                                  image: decryptMessage(document!.content).split('-BREAK-')[2],
                                  username:
                                      decryptMessage(document!.content).split('-BREAK-')[0],
                                  phoneNumber: phoneNumberExtension(
                                      decryptMessage(document!.content).split('-BREAK-')[1]),
                                  description: "");
                              MessageFirebaseApi().saveContact(user);
                            },
                            child: Text(fonts.message.tr,
                                    textAlign: TextAlign.center,
                                    style: AppCss.poppinsExtraBold12.textColor(
                                        isReceiver
                                            ? appCtrl.appTheme.lightBlackColor
                                            : appCtrl.appTheme.white))
                                .marginSymmetric(vertical: Insets.i15))
                      ])),
              if (document!.emoji != null)
                EmojiLayout(emoji: document!.emoji)
            ],
          ),
          const VSpace(Sizes.s2),
          IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (document!.isFavourite !=null)
                  if(appCtrl.user["id"].toString() == document!.favouriteId.toString())
                  Icon(Icons.star,
                      color: appCtrl.appTheme.txtColor, size: Sizes.s10),
                const HSpace(Sizes.s3),
            if (!isBroadcast && !isReceiver)
              Icon(Icons.done_all_outlined,
                  size: Sizes.s15,
                  color: document!.isSeen == true
                      ? appCtrl.appTheme.primary
                      : appCtrl.appTheme.gray),
            const HSpace(Sizes.s5),
            Text(
                DateFormat('HH:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document!.timestamp!.toString()))),
                style:
                    AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor))
          ]))
        ]).marginSymmetric(horizontal: Insets.i10));
  }
}
