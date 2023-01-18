import 'package:intl/intl.dart';

import '../../../../config.dart';

class LocationLayout extends StatelessWidget {
  final GestureTapCallback? onTap;
  final VoidCallback? onLongPress;
  final dynamic document;
  final bool isReceiver;

  const LocationLayout(
      {Key? key,
      this.onLongPress,
      this.onTap,
      this.document,
      this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        alignment: isReceiver ? Alignment.topLeft: Alignment.topRight,
        children: [
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
                style: AppCss.poppinsMedium12
                    .textColor(appCtrl.appTheme.whiteColor),
              )
            ],
          ).paddingAll( Insets.i5),
          CustomPaint(painter: CustomShape(appCtrl.appTheme.primary)),
        ],
      )
          .decorated(
              color: isReceiver ? appCtrl.appTheme.whiteColor  :appCtrl.appTheme.primary,
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
