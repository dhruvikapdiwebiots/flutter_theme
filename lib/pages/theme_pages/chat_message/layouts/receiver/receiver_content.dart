
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
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Insets.i15, vertical: Insets.i10),
        width: Sizes.s220,
        decoration:  BoxDecoration(
            color: appCtrl.isTheme ? appCtrl.appTheme.white : const Color(0xffF2F2F2),
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(Insets.i20),
                bottomLeft: Radius.circular(Insets.i20),
                bottomRight: Radius.circular(Insets.i20))),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(document!['content'],
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.primary).letterSpace(.2).textHeight(1.2)),
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
                      .textColor(appCtrl.appTheme.primary),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
