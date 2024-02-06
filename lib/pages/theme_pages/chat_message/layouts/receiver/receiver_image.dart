import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class ReceiverImage extends StatelessWidget {
  final MessageModel? document;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onTap;

  const ReceiverImage({Key? key, this.document, this.onLongPress,this.onTap})
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
            clipBehavior: Clip.none ,
            children: [
              Container(

                decoration: ShapeDecoration(
                  color: appCtrl.appTheme.chatSecondaryColor,
                  shape: const SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                          topLeft: SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing:1
                          ),
                          topRight: SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing: 1
                          ),
                          bottomRight: SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing: 1
                          ))),
                ),
                child:ClipSmoothRect(
                    clipBehavior: Clip.hardEdge,
                    radius: SmoothBorderRadius(
                      cornerRadius: 20,
                      cornerSmoothing: 1,
                    ),
                    child: Material(
                      borderRadius: SmoothBorderRadius(cornerRadius: 20,cornerSmoothing: 1),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                            width: Sizes.s160,

                            decoration: BoxDecoration(
                              color: appCtrl.appTheme.accent,
                              borderRadius: BorderRadius.circular(AppRadius.r8),
                            ),
                            child: Container()),
                        imageUrl: decryptMessage(document!.content),
                        width: Sizes.s160,
                        fit: BoxFit.cover,
                      ),
                    ).paddingSymmetric(horizontal:Insets.i10).paddingOnly(bottom: Insets.i12)
                )
              ),
              if (document!.emoji!= null)
                EmojiLayout(emoji: document!.emoji)
            ],
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                if (document!.isFavourite != null)
                  if(appCtrl.user["id"] == document!.favouriteId)
                    Icon(Icons.star,
                        color: appCtrl.appTheme.txtColor, size: Sizes.s10),
                const HSpace(Sizes.s3),
                Text(
                  DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document!.timestamp!.toString()))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.txtColor),
                ).marginSymmetric(horizontal: Insets.i5, vertical: Insets.i8),
              ],
            ),
          )
        ],
      ).marginSymmetric(horizontal: Insets.i15),
    );
  }
}
