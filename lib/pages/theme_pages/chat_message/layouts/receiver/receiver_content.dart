import 'dart:math' as math;
import 'package:figma_squircle/figma_squircle.dart';
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class ReceiverContent extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;

  const ReceiverContent({Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
       /* child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Insets.i15, vertical: Insets.i10),
              width: Sizes.s220,
              decoration: BoxDecoration(
                  color: appCtrl.appTheme.whiteColor,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(Insets.i8),
                      bottomLeft: Radius.circular(Insets.i8),
                      bottomRight: Radius.circular(Insets.i8))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(document!['content'],
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.lightBlackColor)
                              .letterSpace(.2)
                              .textHeight(1.2)),
                    ),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      if (document!['isBroadcast'])
                        const Icon(Icons.volume_down, size: Sizes.s15),
                      const HSpace(Sizes.s5),
                      Text(
                        DateFormat('HH:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document!['timestamp']))),
                        style: AppCss.poppinsMedium12
                            .textColor(const Color(0xFF7C7C7C)),
                      )
                    ])
                  ]),
            ),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: CustomPaint(
                painter: CustomShape(appCtrl.appTheme.whiteColor),
              ),
            )
          ],
        ).marginSymmetric(vertical: Insets.i5, horizontal: Insets.i5)*/
    child:  Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal:Insets.i12,vertical: Insets.i14),
            width: Sizes.s230,
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
                      bottomRight: SmoothRadius(
                        cornerRadius: 20,
                        cornerSmoothing: .5,
                      ))),
            ),
            child: Text(document!['content'],
                style: AppCss.poppinsMedium14
                    .textColor(appCtrl.appTheme.whiteColor)
                    .letterSpace(.2)
                    .textHeight(1.2))),
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
    ).marginSymmetric(vertical: Insets.i5, horizontal: Insets.i15),);
  }
}
