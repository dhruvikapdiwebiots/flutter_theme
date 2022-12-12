import 'package:intl/intl.dart';

import '../../../../../config.dart';

class Content extends StatelessWidget {
  final DocumentSnapshot? document;
  final GestureLongPressCallback? onLongPress;
  final bool? isLastMessageRight;

  const Content(
      {Key? key, this.document, this.onLongPress, this.isLastMessageRight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Insets.i15, vertical: Insets.i10),
          width: Sizes.s220,
          decoration: BoxDecoration(
              color: appCtrl.appTheme.primary,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(Insets.i20),
                  topLeft: Radius.circular(Insets.i20),
                  bottomLeft: Radius.circular(Insets.i20))),
          margin: EdgeInsets.only(
              bottom: isLastMessageRight! ? Insets.i10 : Insets.i10,
              right: Insets.i10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(document!['content'],
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.accent)),
              Text(
                DateFormat('HH:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document!['timestamp']))),
                style: AppCss.poppinsMedium12
                    .textColor(appCtrl.appTheme.whiteColor),
              )
            ],
          )),
    );
  }
}
