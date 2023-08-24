import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../config.dart';

class DocImageLayout extends StatelessWidget {
  final MessageModel? document;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onTap;
  final bool isReceiver, isGroup, isBroadcast;
  final String? currentUserId;

  const DocImageLayout(
      {Key? key,
      this.document,
      this.onLongPress,
      this.isReceiver = false,
      this.isGroup = false,
      this.currentUserId,
      this.isBroadcast = false,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Column(
        crossAxisAlignment:
            isReceiver ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Stack(clipBehavior: Clip.none, children: [
            Column(
              children: [
                if (isGroup)
                  if (isReceiver)
                    if (document!.sender != currentUserId)
                      Align(
                          alignment: Alignment.topLeft,
                          child: Column(children: [
                            Text(document!.senderName.toString(),
                                style: AppCss.poppinsMedium12
                                    .textColor(appCtrl.appTheme.primary)),
                            const VSpace(Sizes.s8)
                          ])),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Image.asset(imageAssets.jpg, height: Sizes.s20),
                        const HSpace(Sizes.s10),
                        Expanded(
                          child: Text(
                            decryptMessage(document!.content)
                                .split("-BREAK-")[0],
                            textAlign: TextAlign.start,
                            style: AppCss.poppinsMedium12.textColor(isReceiver
                                ? appCtrl.appTheme.lightBlackColor
                                : appCtrl.appTheme.white),
                          ),
                        ),
                      ],
                    )
                        .width(220)
                        .paddingSymmetric(
                            horizontal: Insets.i10, vertical: Insets.i15)
                        .decorated(
                            color: isReceiver
                                ? appCtrl.appTheme.lightGrey1Color
                                : appCtrl.appTheme.lightPrimary,
                            borderRadius: BorderRadius.circular(AppRadius.r8)),
                    const VSpace(Sizes.s2),
                    IntrinsicHeight(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isGroup)
                              if (!isReceiver && !isBroadcast)
                                Icon(Icons.done_all_outlined,
                                    size: Sizes.s15,
                                    color: document!.isSeen == true
                                        ? appCtrl.appTheme.primary
                                        : appCtrl.appTheme.gray),
                            const HSpace(Sizes.s5),
                            IntrinsicHeight(
                                child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (document!.isFavourite != null)
                                  if (document!.isFavourite == true)
                                    if (appCtrl.user["id"] ==
                                        document!.favouriteId)
                                      Icon(Icons.star,
                                          color: appCtrl.appTheme.txtColor,
                                          size: Sizes.s10),
                                const HSpace(Sizes.s3),
                                Text(
                                  DateFormat('HH:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(document!.timestamp.toString()))),
                                  style: AppCss.poppinsMedium12
                                      .textColor(appCtrl.appTheme.txtColor),
                                ),
                              ],
                            ))
                          ]).marginSymmetric(
                          vertical: Insets.i3, horizontal: Insets.i10),
                    )
                  ],
                )
              ],
            ),
            if (document!.emoji != null)
              EmojiLayout(emoji: document!.emoji)
          ])
        ],
      )
          .paddingAll(Insets.i8)
          .decorated(
              color: isReceiver
                  ? appCtrl.appTheme.whiteColor
                  : appCtrl.appTheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.r8))
          .marginSymmetric(horizontal: Insets.i5, vertical: Insets.i5),
    );
  }
}
