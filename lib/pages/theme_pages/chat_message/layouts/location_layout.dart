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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Insets.i8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  imageAssets.map,
                  height: Sizes.s150,
                ).clipRRect(all: AppRadius.r20),
              ],
            ).paddingAll( Insets.i5)
          ),
          const VSpace(Sizes.s5),
          Text(
            DateFormat('HH:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document!['timestamp']))),
            style: AppCss.poppinsMedium12
                .textColor(appCtrl.appTheme.txtColor),
          ).marginSymmetric(horizontal: Insets.i8)
        ],
      ),
    );
  }
}
