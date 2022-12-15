import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupLocationLayout extends StatelessWidget {
  final GestureTapCallback? onTap;
  final VoidCallback? onLongPress;
  final DocumentSnapshot? document;
  final String? currentUserId;

  const GroupLocationLayout(
      {Key? key,
      this.onLongPress,
      this.onTap,
      this.document,
      this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (document!["sender"] != currentUserId)
                Text(document!['senderName'],
                        style: AppCss.poppinsMedium14
                            .textColor(appCtrl.appTheme.whiteColor))
                    .alignment(Alignment.bottomLeft)
                    .paddingAll(Insets.i15),
              Image.asset(
                imageAssets.map,
                height: Sizes.s150,
              ).clipRRect(all: AppRadius.r10),
              const VSpace(Sizes.s10),
            ],
          ),
          Text(
            DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                int.parse(document!['timestamp']))),
            style:
                AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor),
          ).alignment(Alignment.bottomRight)
        ],
      )
          .paddingOnly(
              top: Insets.i6,
              left: Insets.i6,
              right: Insets.i6,
              bottom: Insets.i10)
          .decorated(
              color: appCtrl.appTheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.r10))
          .paddingSymmetric(vertical: Insets.i10),
    );
  }
}
