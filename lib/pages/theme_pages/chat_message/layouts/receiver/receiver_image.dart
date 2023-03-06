import 'package:intl/intl.dart';

import '../../../../../config.dart';

class ReceiverImage extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;

  const ReceiverImage({Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(

            decoration: ShapeDecoration(
              color: appCtrl.appTheme.chatSecondaryColor,
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
            child:ClipSmoothRect(
                clipBehavior: Clip.hardEdge,
                radius: SmoothBorderRadius(
                  cornerRadius: 20,
                  cornerSmoothing: 1,
                ),
                child: Material(
                  borderRadius: SmoothBorderRadius(cornerRadius: 20,cornerSmoothing: 1),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                        width: Sizes.s160,
                        height: Sizes.s150,
                        decoration: BoxDecoration(
                          color: appCtrl.appTheme.accent,
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                        ),
                        child: Container()),
                    imageUrl: document!['content'],
                    width: Sizes.s160,
                    height: Sizes.s150,
                    fit: BoxFit.cover,
                  ),
                ).paddingSymmetric(horizontal:Insets.i10).paddingOnly(bottom: Insets.i12)
            )
          ),
          Text(
            DateFormat('HH:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document!['timestamp']))),
            style: AppCss.poppinsMedium12
                .textColor(appCtrl.appTheme.txtColor),
          ).marginSymmetric(horizontal: Insets.i5, vertical: Insets.i8)
        ],
      ),
    );
  }
}
