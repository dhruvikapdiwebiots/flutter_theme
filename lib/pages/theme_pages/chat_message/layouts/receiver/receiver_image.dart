import 'package:intl/intl.dart';

import '../../../../../config.dart';

class ReceiverImage extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;

  const ReceiverImage({Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.r10),

      ),
      child: InkWell(
          onLongPress: onLongPress,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Material(
                borderRadius: BorderRadius.circular(AppRadius.r8),
                clipBehavior: Clip.hardEdge,
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                      width: Sizes.s220,
                      height: Sizes.s200,
                      decoration: BoxDecoration(
                        color: appCtrl.appTheme.accent,
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      child: Container()),
                  imageUrl: document!['content'],
                  width: Sizes.s200,
                  height: Sizes.s200,
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                DateFormat('HH:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document!['timestamp']))),
                style:
                    AppCss.poppinsBold12.textColor(appCtrl.appTheme.whiteColor),
              )
                  .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10)
                  .boxShadow(
                      blurRadius: 15.0,
                      color: appCtrl.appTheme.blackColor.withOpacity(.25),
                      offset: const Offset(-2, 2))
            ],
          ).paddingAll(Insets.i5).decorated(color: appCtrl.appTheme.whiteColor,borderRadius: BorderRadius.circular(AppRadius.r8)).marginSymmetric(vertical: Insets.i10)),
    );
  }
}
