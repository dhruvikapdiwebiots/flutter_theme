import 'package:figma_squircle/figma_squircle.dart';
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class Content extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  final bool isBroadcast;

  const Content(
      {Key? key, this.document, this.onLongPress, this.isBroadcast = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
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
                                cornerRadius: 20,
                                cornerSmoothing: .5,
                              ),
                              topRight: SmoothRadius(
                                cornerRadius: 20,
                                cornerSmoothing: 0.4,
                              ),
                              bottomLeft: SmoothRadius(
                                cornerRadius: 20,
                                cornerSmoothing: .5,
                              ))),
                    ),
                    child: Text(document!['content'],
                        overflow: TextOverflow.clip,
                        style: AppCss.poppinsMedium14
                            .textColor(appCtrl.appTheme.whiteColor)
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
                                cornerSmoothing: .5,
                              ),
                              topRight: SmoothRadius(
                                cornerRadius: 20,
                                cornerSmoothing: 0.4,
                              ),
                              bottomLeft: SmoothRadius(
                                cornerRadius: 20,
                                cornerSmoothing: .5,
                              ))),
                    ),
                    child: Text(document!['content'],
                        overflow: TextOverflow.clip,
                        style: AppCss.poppinsMedium14
                            .textColor(appCtrl.appTheme.whiteColor)
                            .letterSpace(.2)
                            .textHeight(1.2))),
            const VSpace(Sizes.s2),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isBroadcast)
                    Icon(Icons.done_all_outlined,
                        size: Sizes.s15,
                        color: document!['isSeen'] == false
                            ? appCtrl.appTheme.primary
                            : appCtrl.appTheme.whiteColor),
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
        ).marginSymmetric(vertical: Insets.i10, horizontal: Insets.i15));
  }
}
