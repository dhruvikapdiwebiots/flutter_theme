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
          return Stack(
            children: [
              Container(

                padding: const EdgeInsets.fromLTRB(Insets.i15, 10.0, Insets.i15, 10.0),
                width: 220.0,
                decoration:  BoxDecoration(
                    color: appCtrl.appTheme.whiteColor,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(Insets.i8),
                        bottomLeft: Radius.circular(Insets.i8),
                        bottomRight: Radius.circular(Insets.i8))),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(document!['senderName'],
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.blackColor)),
                    const VSpace(Sizes.s10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(document!['content'],
                              style: AppCss.poppinsMedium14
                                  .textColor(const Color(0xFF586780))
                                  .letterSpace(.2)
                                  .textHeight(1.2)),
                        ),
                        Text(
                          DateFormat('HH:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(document!['timestamp']))),
                          style: AppCss.poppinsMedium12
                              .textColor(const Color(0xFF7C7C7C)),
                        )
                      ]
                    )
                  ],
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: CustomPaint(
                  painter: CustomShape(appCtrl.appTheme.whiteColor),
                ),
              )
            ],
          ).marginSymmetric(vertical: Insets.i5,horizontal: Insets.i5);
        });
  }
}
