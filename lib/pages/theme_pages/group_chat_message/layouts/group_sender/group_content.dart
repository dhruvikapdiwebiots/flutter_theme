import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupContent extends StatelessWidget {
  final DocumentSnapshot? document;
  final GestureLongPressCallback? onLongPress;

  const GroupContent(
      {Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,

        child:Column(
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
                          bottomLeft: SmoothRadius(
                            cornerRadius: 20,
                            cornerSmoothing: .5,
                          ))),
                ),
                child: Text(document!['content'],
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.whiteColor)
                        .letterSpace(.2)
                        .textHeight(1.2))),
            const VSpace(Sizes.s3),

            Text(
              DateFormat('HH:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(document!['timestamp']))),
              style: AppCss.poppinsMedium12
                  .textColor(appCtrl.appTheme.txtColor),
            )
          ],
        ).marginSymmetric(vertical: Insets.i10, horizontal: Insets.i15)
    );
  }
}
