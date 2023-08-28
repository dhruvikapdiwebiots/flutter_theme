import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';

import '../../../../config.dart';

class GifLayout extends StatelessWidget {
  final MessageModel? document;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onTap;
  final bool isReceiver, isGroup;
  final String? currentUserId;

  const GifLayout(
      {Key? key,
      this.document,
      this.onLongPress,
      this.isReceiver = false,
      this.isGroup = false,
      this.currentUserId,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List seen = [];
    if(isGroup){

      seen = document!.seenMessageList != null ? document!.seenMessageList! : [];
    }
    return InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGroup)
              if (isReceiver)
                if (document!.sender != currentUserId)
                  Align(
                      alignment: Alignment.topLeft,
                      child: Column(children: [
                        Text(document!.senderName.toString(),
                                style: AppCss.poppinsMedium12
                                    .textColor(appCtrl.appTheme.primary))
                            .paddingSymmetric(
                                horizontal: Insets.i10, vertical: Insets.i5)
                            .decorated(
                                color: appCtrl.appTheme.whiteColor,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r20)),
                      ])),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.network(decryptMessage(document!.content),
                    height: Sizes.s100),
                IntrinsicHeight(
                        child: Row(
                  children: [
                    if (document!.isFavourite !=null)
                    if (document!.isFavourite ==true)
                      if (appCtrl.user["id"] != document!.sender)
                        Icon(Icons.star,
                            color: appCtrl.appTheme.txtColor, size: Sizes.s10),
                    const HSpace(Sizes.s3),
                    isGroup ?Icon(Icons.done_all_outlined,
                        size: Sizes.s15,
                        color:seen.contains(currentUserId)
                            ? appCtrl.appTheme.primary
                            : appCtrl.appTheme.gray) :
                    Icon(Icons.done_all_outlined,
                        size: Sizes.s15,
                        color: document!.isSeen == true
                            ? appCtrl.appTheme.primary
                            : appCtrl.appTheme.gray),
                    const HSpace(Sizes.s5),
                    Text(
                      DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document!.timestamp.toString()))),
                      style: AppCss.poppinsMedium12
                          .textColor(appCtrl.appTheme.txtColor),
                    )
                  ],
                ).marginSymmetric(horizontal: Insets.i6, vertical: Insets.i4))
                    .paddingOnly(
                  top: Insets.i5,
                ),
              ],
            ),
          ],
        ).marginSymmetric(horizontal: Insets.i10));
  }
}
