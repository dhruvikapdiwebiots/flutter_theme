import 'dart:developer';

import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class Content extends StatelessWidget {
  final MessageModel? document;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onTap;
  final bool isBroadcast;
  final String? userId;

  const Content(
      {Key? key,
      this.document,
      this.onLongPress,
      this.onTap,
      this.isBroadcast = false,
      this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                decryptMessage(document!.content).length > 40
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Insets.i12, vertical: Insets.i14),
                        width: Sizes.s280,
                        decoration: ShapeDecoration(
                          color: appCtrl.appTheme.primary,
                          shape: const SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius.only(
                                  topLeft: SmoothRadius(
                                      cornerRadius: 20, cornerSmoothing: 1),
                                  topRight: SmoothRadius(
                                      cornerRadius: 20, cornerSmoothing: 1),
                                  bottomLeft: SmoothRadius(
                                      cornerRadius: 20, cornerSmoothing: 1))),
                        ),
                        child: Text(decryptMessage(document!.content),
                            overflow: TextOverflow.clip,
                            style: AppCss.poppinsMedium13
                                .textColor(appCtrl.appTheme.white)
                                .letterSpace(.2)
                                .textHeight(1.2)))
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Insets.i12, vertical: Insets.i10),
                        decoration: ShapeDecoration(
                            color: appCtrl.appTheme.primary,
                            shape: const SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius.only(
                                    topLeft: SmoothRadius(
                                      cornerRadius: 18,
                                      cornerSmoothing: 1,
                                    ),
                                    topRight: SmoothRadius(
                                      cornerRadius: 18,
                                      cornerSmoothing: 1,
                                    ),
                                    bottomLeft: SmoothRadius(
                                        cornerRadius: 18,
                                        cornerSmoothing: 1)))),
                        child: Text(decryptMessage(document!.content),
                            overflow: TextOverflow.clip,
                            style: AppCss.poppinsMedium13
                                .textColor(appCtrl.appTheme.white)
                                .letterSpace(.2)
                                .textHeight(1.2))),
                if (document!.emoji !=null )
                  EmojiLayout(emoji: document!.emoji)
              ],
            ),
             VSpace(document!.emoji !=null  ? Sizes.s15: Sizes.s2),
            IntrinsicHeight(
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (document!.isFavourite != null)
                if(appCtrl.user["id"] == document!.favouriteId)
                  Icon(Icons.star,
                      color: appCtrl.appTheme.txtColor, size: Sizes.s10),
              const HSpace(Sizes.s3),
              if (!isBroadcast)
                Icon(Icons.done_all_outlined,
                    size: Sizes.s15,
                    color: document!.isSeen == true
                        ? appCtrl.appTheme.primary
                        : appCtrl.appTheme.gray),
              const HSpace(Sizes.s5),
              Text(
                  DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document!.timestamp!))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.txtColor))
            ]))
          ],
        ).marginSymmetric( horizontal: Insets.i15));
  }
}
