import 'dart:math' as math;
import 'package:intl/intl.dart';

import '../../../../../config.dart';

class ReceiverContent extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;

  const ReceiverContent({Key? key,this.document,this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onLongPress:  onLongPress,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Insets.i15, vertical: Insets.i10),
            width: Sizes.s220,
            decoration:  BoxDecoration(
                color: appCtrl.appTheme.whiteColor,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(Insets.i8),
                    bottomLeft: Radius.circular(Insets.i8),
                    bottomRight: Radius.circular(Insets.i8))),

            child:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(document!['content'],
                      style: AppCss.poppinsMedium14
                          .textColor(Color(0xFF586780)).letterSpace(.2).textHeight(1.2)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if(document!['isBroadcast'])
                      const Icon(Icons.volume_down,size: Sizes.s15),
                    const HSpace(Sizes.s5),

                    Text(
                      DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document!['timestamp']))),
                      style: AppCss.poppinsMedium12
                          .textColor(Color(0xFF7C7C7C)),
                    ),
                  ],
                )
              ],
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(math.pi),
            child: CustomPaint(
              painter: CustomShape(appCtrl.appTheme.whiteColor),
            ),
          )
        ],
      ).marginSymmetric(vertical: Insets.i5,horizontal: Insets.i15)
    );
  }
}
