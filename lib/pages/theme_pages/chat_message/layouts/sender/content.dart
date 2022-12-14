import 'package:intl/intl.dart';

import '../../../../../config.dart';

class Content extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  final bool isBroadcast;

  const Content({Key? key, this.document, this.onLongPress,this.isBroadcast = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Insets.i15, vertical: Insets.i10),
          width: Sizes.s220,
          decoration: BoxDecoration(
              color: appCtrl.isTheme ? appCtrl.appTheme.white :appCtrl.appTheme.primary,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(Insets.i20),
                  topLeft: Radius.circular(Insets.i20),
                  bottomLeft: Radius.circular(Insets.i20))),
          margin: const EdgeInsets.symmetric(
              vertical: Insets.i5, horizontal: Insets.i10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(document!['content'],
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.whiteColor)
                        .letterSpace(.2)
                        .textHeight(1.2)),
              ),
              const HSpace(Sizes.s8),
              Row(
                children: [
                  Text(
                    DateFormat('HH:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document!['timestamp']))),
                    style: AppCss.poppinsMedium12
                        .textColor(appCtrl.appTheme.whiteColor),
                  ),
                  const HSpace(Sizes.s5),
                  if(!isBroadcast)
                  Icon(Icons.done_all_outlined,
                      size: Sizes.s15,
                      color: document!['isSeen'] == true
                          ? appCtrl.appTheme.secondary
                          : appCtrl.appTheme.whiteColor)
                ],
              )
            ],
          )),
    );
  }
}
