import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../config.dart';

class SenderImage extends StatelessWidget {
  final dynamic document;
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
                        imageUrl: decryptMessage(document!["content"]),
                        width: Sizes.s160,
                        height: Sizes.s150,
                        fit: BoxFit.cover,
                      ),
                    ).paddingAll(Insets.i10),
                  ),
                ),
                if (document!.data().toString().contains('emoji'))
                  EmojiLayout(emoji: document!["emoji"])
              ],
            ),
            Row(
              children: [
                if (document!.data().toString().contains('isFavourite'))
                  if(appCtrl.user["id"]  != document.data()["senderId"])
                  Icon(Icons.star,
                      color: appCtrl.appTheme.txtColor, size: Sizes.s10),
                const HSpace(Sizes.s3),
                if (!isBroadcast)
                  Icon(Icons.done_all_outlined,
                      size: Sizes.s15,
                      color: document!['isSeen'] == false
                          ? appCtrl.appTheme.primary
                          : appCtrl.appTheme.gray),
                const HSpace(Sizes.s5),
                Text(
                  DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document!['timestamp']))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.txtColor),
                )
              ],
            ).marginSymmetric(horizontal: Insets.i8, vertical: Insets.i4)
          ],
        ));
  }
}
