
import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class SenderImage extends StatelessWidget {
  final MessageModel? document;
  final VoidCallback? onPressed, onLongPress;
  final bool isBroadcast;
  final String? userId;

  const SenderImage({Key? key, this.document, this.onPressed, this.onLongPress,this.isBroadcast =false,this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        onTap:onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: Insets.i10,),
                  decoration: ShapeDecoration(
                    color: appCtrl.appTheme.primary,
                    shape:  SmoothRectangleBorder(
                        borderRadius:SmoothBorderRadius(cornerRadius: 20,cornerSmoothing: 1)),
                  ),
                  child: ClipSmoothRect(
                    clipBehavior: Clip.hardEdge,
                    radius: SmoothBorderRadius(
                      cornerRadius: 20,
                      cornerSmoothing: 1,
                    ),
                    child: Material(
                      borderRadius: SmoothBorderRadius(cornerRadius: 15,cornerSmoothing: 1),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                            width: Sizes.s160,
                            height: Sizes.s150,
                            decoration: ShapeDecoration(
                              color: appCtrl.appTheme.accent,
                              shape:  SmoothRectangleBorder(
                                  borderRadius:SmoothBorderRadius(cornerRadius: 10,cornerSmoothing: 1)),
                            ),
                            child: Container()),
                        imageUrl: decryptMessage(document!.content),
                        width: Sizes.s160,
                        height: Sizes.s150,
                        fit: BoxFit.fill,
                      ),
                    ).paddingAll(Insets.i10),
                  ),
                ),
                if (document!.emoji != null)
                  EmojiLayout(emoji: document!.emoji)
              ],
            ),
            Row(
              children: [
                if (document!.isFavourite != null)
                  if(appCtrl.user["id"]  != document!.sender)
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
                          int.parse(document!.timestamp.toString()))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.txtColor),
                )
              ],
            ).marginSymmetric(horizontal: Insets.i8, vertical: Insets.i4)
          ],
        ));
  }
}
