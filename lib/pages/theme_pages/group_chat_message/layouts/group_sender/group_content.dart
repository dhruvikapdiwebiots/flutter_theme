import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupContent extends StatelessWidget {
  final DocumentSnapshot? document;
  final GestureLongPressCallback? onLongPress;
final GestureTapCallback? onTap;
  const GroupContent(
      {Key? key, this.document, this.onLongPress,this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        onTap: onTap,

        child:Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                document!['content'].length > 40
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
                    child: Text(document!['content'],
                        overflow: TextOverflow.clip,
                        style: AppCss.poppinsMedium13
                            .textColor(appCtrl.appTheme.white)
                            .letterSpace(.2)
                            .textHeight(1.2)))
                    : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Insets.i12, vertical: Insets.i14),
                    decoration: ShapeDecoration(
                        color: appCtrl.appTheme.primary,
                        shape: const SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius.only(
                                topLeft: SmoothRadius(
                                  cornerRadius: 20,
                                  cornerSmoothing: 1,
                                ),
                                topRight: SmoothRadius(
                                  cornerRadius: 20,
                                  cornerSmoothing: 1,
                                ),
                                bottomLeft: SmoothRadius(
                                    cornerRadius: 20,
                                    cornerSmoothing: 1)))),
                    child: Text(document!['content'],
                        overflow: TextOverflow.clip,
                        style: AppCss.poppinsMedium13
                            .textColor(appCtrl.appTheme.white)
                            .letterSpace(.2)
                            .textHeight(1.2))),
                if (document!.data().toString().contains('emoji'))
                  EmojiLayout(emoji: document!["emoji"])
              ],
            ),
            const VSpace(Sizes.s2),

            Text(
              DateFormat('HH:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(document!['timestamp']))),
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.txtColor),
            )
          ],
        ).marginSymmetric(horizontal: Insets.i15)
    );
  }
}
