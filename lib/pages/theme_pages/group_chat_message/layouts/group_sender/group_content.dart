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
      child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: Insets.i15, vertical: Insets.i10),
          width: Sizes.s220,
          decoration: BoxDecoration(
              color: appCtrl.isTheme ?appCtrl.appTheme.white : appCtrl.appTheme.primary,
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(Insets.i20),
                  topLeft: Radius.circular(Insets.i20),
                  bottomLeft: Radius.circular(Insets.i20))),
          margin: const EdgeInsets.only(
              bottom:  Insets.i10,
              right: Insets.i10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(document!['content'],
                    style: AppCss.poppinsMedium14
                        .textColor(appCtrl.appTheme.whiteColor).letterSpace(.2)
                        .textHeight(1.2)),
              ),
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
