import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../../../config.dart';

class GroupReceiverContent extends StatelessWidget {
  final DocumentSnapshot? document;
  final GestureLongPressCallback? onLongPress;

  const GroupReceiverContent({Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(document!['sender'])
            .snapshots(),
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal:Insets.i12,vertical: Insets.i12),
                  width: Sizes.s230,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ Text("${document!['senderName']}",
                        style: AppCss.poppinsSemiBold12
                            .textColor(appCtrl.appTheme.primary)),
                      const VSpace(Sizes.s6),
                      Text(document!['content'],
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.blackColor)
                              .letterSpace(.2)
                              .textHeight(1.2)).alignment(Alignment.centerLeft),
                    ],
                  )),
              const VSpace(Sizes.s5),
              Text(
                DateFormat('HH:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document!['timestamp']))),
                style: AppCss.poppinsMedium12
                    .textColor(appCtrl.appTheme.txtColor),
              ).marginSymmetric(horizontal: Insets.i2)
            ],
          ).marginSymmetric(vertical: Insets.i5, horizontal: Insets.i10);
        });
  }
}
