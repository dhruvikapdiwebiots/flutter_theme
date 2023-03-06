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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: ShapeDecoration(
              color:isReceiver
                  ? appCtrl.appTheme.whiteColor
                  : appCtrl.appTheme.primary,
              shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.only(
                      topLeft: const SmoothRadius(
                        cornerRadius: 20,
                        cornerSmoothing: .5,
                      ),
                      topRight: const SmoothRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 0.4,
                      ),
                      bottomLeft: SmoothRadius(
                        cornerRadius:isReceiver ? 0 : 20,
                        cornerSmoothing: .5,
                      ),
                      bottomRight: SmoothRadius(
                        cornerRadius:isReceiver ? 20 : 0,
                        cornerSmoothing: .5,
                      ))),
            ),
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
                    Image.asset(
                      imageAssets.map,
                      height: Sizes.s150,
                    ).clipRRect(all: AppRadius.r10)
                  ],
                ).paddingAll(Insets.i5).marginSymmetric(vertical: Insets.i10),
              ],
            )

                .paddingSymmetric(horizontal: Insets.i8),
          ),
          const VSpace(Sizes.s10),
          Text(

            DateFormat('HH:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document!['timestamp']))),
            textAlign: TextAlign.end,
            style: AppCss.poppinsMedium12.textColor( appCtrl.appTheme.txtColor),
          ),
        ],
      ).marginSymmetric(horizontal: Insets.i10),
    );
  }
}
