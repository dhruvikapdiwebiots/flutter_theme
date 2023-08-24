import 'package:intl/intl.dart';

import '../../../../config.dart';
import '../../../../models/message_model.dart';

class LocationLayout extends StatelessWidget {
  final GestureTapCallback? onTap;
  final VoidCallback? onLongPress;
  final MessageModel? document;
  final bool isReceiver, isBroadcast;

  const LocationLayout(
      {Key? key,
      this.onLongPress,
      this.onTap,
      this.document,
      this.isReceiver = false,
      this.isBroadcast = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: Insets.i8),
                  decoration: ShapeDecoration(
                      color: appCtrl.appTheme.primary,
                      shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.only(
                              topLeft: const SmoothRadius(
                                  cornerRadius: 20, cornerSmoothing: 1),
                              topRight: const SmoothRadius(
                                  cornerRadius: 20, cornerSmoothing: 1),
                              bottomLeft: SmoothRadius(
                                  cornerRadius: isReceiver ? 0 : 20,
                                  cornerSmoothing: 1),
                              bottomRight: const SmoothRadius(
                                  cornerRadius: 20, cornerSmoothing: 1)))),
                  child:
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    ClipRRect(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 15, cornerSmoothing: 1),
                        child: Image.asset(imageAssets.map, height: Sizes.s150))
                  ]).paddingAll(Insets.i5)),
              if (document!.emoji != null)
                EmojiLayout(emoji: document!.emoji)
            ],
          ),
          const VSpace(Sizes.s2),
          IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (document!.isFavourite != null)
                  if(appCtrl.user["id"] == document!.favouriteId)
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
          ])).marginSymmetric(horizontal: Insets.i8)
        ]));
  }
}
