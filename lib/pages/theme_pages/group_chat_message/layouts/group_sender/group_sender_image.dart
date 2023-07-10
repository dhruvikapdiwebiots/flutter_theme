import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupSenderImage extends StatelessWidget {
  final DocumentSnapshot? document;
  final VoidCallback? onPressed, onLongPress;

  const GroupSenderImage(
      {Key? key, this.document, this.onPressed, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                                        decryptMessage(document!['content']),
                                    width: Sizes.s160,
                                    height: Sizes.s150,
                                    fit: BoxFit.cover))
                            .paddingAll(Insets.i10))),
                if (document!.data().toString().contains('emoji'))
                  EmojiLayout(emoji: document!["emoji"])
              ],
            ),
            const VSpace(Sizes.s2),
            IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  if (document!.data().toString().contains('isFavourite'))
                    if(appCtrl.user["id"] == document!["favouriteId"])
                    Icon(Icons.star,
                        color: appCtrl.appTheme.txtColor, size: Sizes.s10),
                  const HSpace(Sizes.s3),
                  Text(
                    DateFormat('HH:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document!['timestamp']))),
                    style: AppCss.poppinsMedium12
                        .textColor(appCtrl.appTheme.txtColor),
                  ).marginOnly(right: Insets.i12),
                ]))
          ],
        ));
  }
}
