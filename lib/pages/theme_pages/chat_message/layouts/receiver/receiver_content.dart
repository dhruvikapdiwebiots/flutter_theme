import 'dart:math' as math;
import 'package:figma_squircle/figma_squircle.dart';
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class ReceiverContent extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onTap;

  const ReceiverContent({Key? key, this.document, this.onLongPress, this.onTap})
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
              Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Insets.i12, vertical: Insets.i14),
                  width: Sizes.s230,
                  decoration: ShapeDecoration(
                    color: appCtrl.appTheme.primary,
                    shape: const SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius.only(
                            topLeft:
                                SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
                            topRight: SmoothRadius(
                                cornerRadius: 20, cornerSmoothing: 1),
                            bottomRight: SmoothRadius(
                              cornerRadius: 20,
                              cornerSmoothing: 1
                            ))),
                  ),
                  child: Text(document!['content'],
                      style: AppCss.poppinsMedium14
                          .textColor(appCtrl.appTheme.white)
                          .letterSpace(.2)
                          .textHeight(1.2))),
              if (document!.data().toString().contains('emoji'))
                EmojiLayout(emoji: document!["emoji"])
            ],
          ),
          const VSpace(Sizes.s2),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (document!['isBroadcast'])
                  const Icon(Icons.volume_down, size: Sizes.s15),
                const HSpace(Sizes.s5),
                Text(
                  DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document!['timestamp']))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.txtColor),
                ),
              ],
            ),
          )
        ],
      ).marginSymmetric(vertical: Insets.i5, horizontal: Insets.i15),
    );
  }
}
