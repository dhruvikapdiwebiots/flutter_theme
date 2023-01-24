import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupLocationLayout extends StatelessWidget {
  final GestureTapCallback? onTap;
  final VoidCallback? onLongPress;
  final DocumentSnapshot? document;
  final String? currentUserId;
  final bool isReceiver;

  const GroupLocationLayout(
      {Key? key,
      this.onLongPress,
      this.onTap,
      this.document,
      this.currentUserId,
      this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        alignment: isReceiver ? Alignment.topLeft : Alignment.topRight,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReceiver)
                if (document!["sender"] != currentUserId)
                  Text(document!['senderName'],
                          style: AppCss.poppinsMedium14
                              .textColor( isReceiver ? appCtrl.appTheme.primary : appCtrl.appTheme.whiteColor))
                      .alignment(Alignment.bottomLeft)
                      .paddingAll(Insets.i5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Image.asset(
                    imageAssets.map,
                    height: Sizes.s150,
                  ).clipRRect(all: AppRadius.r10),
                  const VSpace(Sizes.s10),
                  Text(

                    DateFormat('HH:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document!['timestamp']))),
                    textAlign: TextAlign.end,
                    style: AppCss.poppinsMedium12.textColor(isReceiver
                        ? appCtrl.appTheme.lightBlackColor
                        : appCtrl.appTheme.whiteColor),
                  ),
                ],
              )
            ],
          ).paddingAll(Insets.i5),
          CustomPaint(
              painter: CustomShape(isReceiver
                  ? appCtrl.appTheme.whiteColor
                  : appCtrl.appTheme.primary)),
        ],
      )
          .decorated(
              color: isReceiver
                  ? appCtrl.appTheme.whiteColor
                  : appCtrl.appTheme.primary,
              borderRadius: BorderRadius.only(
                  bottomRight: const Radius.circular(Insets.i8),
                  topRight: isReceiver
                      ? const Radius.circular(Insets.i8)
                      : const Radius.circular(0),
                  topLeft: isReceiver
                      ? const Radius.circular(0)
                      : const Radius.circular(Insets.i8),
                  bottomLeft: const Radius.circular(Insets.i8)))
          .paddingSymmetric(horizontal: Insets.i8),
    );
  }
}
