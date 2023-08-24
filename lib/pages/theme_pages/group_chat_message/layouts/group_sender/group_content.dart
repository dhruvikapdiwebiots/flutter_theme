import 'package:flutter_theme/models/message_model.dart';
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupContent extends StatelessWidget {
  final MessageModel? document;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onTap;
  final bool isSearch;
  final List? userList;

  const GroupContent({Key? key, this.document, this.onLongPress, this.onTap,this.isSearch = false,this.userList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List seen = [];
    seen =  document!.seenMessageList ?? [];
    return InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                document!.content!.length > 40
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
                                .textHeight(1.2)).backgroundColor(isSearch ? appCtrl.appTheme.orangeColor.withOpacity(.4) : appCtrl.appTheme.transparentColor))
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Insets.i12, vertical: Insets.i10),
                        decoration: ShapeDecoration(
                            color: appCtrl.appTheme.primary,
                            shape: const SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius.only(
                                    topLeft: SmoothRadius(
                                        cornerRadius: 18, cornerSmoothing: 1),
                                    topRight: SmoothRadius(
                                        cornerRadius: 18, cornerSmoothing: 1),
                                    bottomLeft: SmoothRadius(
                                        cornerRadius: 18,
                                        cornerSmoothing: 1)))),
                        child: Text(decryptMessage(document!.content),
                            overflow: TextOverflow.clip,
                            style: AppCss.poppinsMedium13
                                .textColor(appCtrl.appTheme.white)
                                .letterSpace(.2)
                                .textHeight(1.2))),
                if (document!.emoji != null)
                  EmojiLayout(emoji: document!.emoji)
              ],
            ),
             VSpace(document!.emoji != null? Sizes.s18: Sizes.s5),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (document!.isFavourite != null)
                  if (document!.isFavourite == true)
                    if(appCtrl.user["id"] == document!.favouriteId.toString())
                    Icon(Icons.star,color: appCtrl.appTheme.txtColor,size: Sizes.s10),
                  const HSpace(Sizes.s3),
                  Icon(Icons.done_all_outlined,
                      size: Sizes.s15,
                      color: userList!.length == seen.length
                          ? appCtrl.appTheme.primary
                          : appCtrl.appTheme.grey),
                  const HSpace(Sizes.s3),
                  Text(
                    DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document!.timestamp!.toString()))),
                    style:
                        AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor),
                  ),
                ],
              )
            )
          ],
        ).marginSymmetric(horizontal: Insets.i15));
  }
}
