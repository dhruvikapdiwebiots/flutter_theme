

import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupSenderImage extends StatelessWidget {
  final MessageModel? document;
  final VoidCallback? onPressed, onLongPress;
  final List? userList;
  const GroupSenderImage(
      {Key? key, this.document, this.onPressed, this.onLongPress,this.userList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List seen = [];
    seen = document!.seenMessageList ?? [];
    return InkWell(
        onLongPress: onLongPress,
        onTap: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: Insets.i10,
                    ),
                    decoration: ShapeDecoration(
                        color: appCtrl.appTheme.primary,
                        shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 20, cornerSmoothing: 1))),
                    child: ClipSmoothRect(
                        clipBehavior: Clip.hardEdge,
                        radius: SmoothBorderRadius(
                            cornerRadius: 20, cornerSmoothing: 1),
                        child: Material(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 15, cornerSmoothing: 1),
                                clipBehavior: Clip.hardEdge,
                                child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                        width: Sizes.s160,
                                        height: Sizes.s150,
                                        decoration: ShapeDecoration(
                                            color: appCtrl.appTheme.accent,
                                            shape: SmoothRectangleBorder(
                                                borderRadius:
                                                    SmoothBorderRadius(
                                                        cornerRadius: 10,
                                                        cornerSmoothing: 1))),
                                        child: Container()),
                                    imageUrl:
                                        decryptMessage(document!.content),
                                    width: Sizes.s160,
                                    height: Sizes.s150,
                                    fit: BoxFit.cover))
                            .paddingAll(Insets.i10))),
                if (document!.emoji !=null)
                  EmojiLayout(emoji: document!.emoji)
              ],
            ),
            const VSpace(Sizes.s2),
            IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  if (document!.isFavourite != null)
                  if (document!.isFavourite == true)
                    if(appCtrl.user["id"] == document!.favouriteId.toString())
                    Icon(Icons.star,
                        color: appCtrl.appTheme.txtColor, size: Sizes.s10),
                  const HSpace(Sizes.s3),
                      Icon(Icons.done_all_outlined,
                          size: Sizes.s15,
                          color: userList!.length == seen.length
                              ? appCtrl.appTheme.primary
                              : appCtrl.appTheme.grey),
                  const HSpace(Sizes.s3),
                  Text(
                    DateFormat('HH:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document!.timestamp.toString()))),
                    style: AppCss.poppinsMedium12
                        .textColor(appCtrl.appTheme.txtColor),
                  ).marginOnly(right: Insets.i12),
                ]))
          ],
        ));
  }
}
