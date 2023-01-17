import 'package:intl/intl.dart';

import '../../../../../config.dart';

class GroupReceiverImage extends StatelessWidget {
  final DocumentSnapshot? document;
  final GestureLongPressCallback? onLongPress;

  const GroupReceiverImage({Key? key, this.document, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(document!['senderName'],
                style:
                    AppCss.poppinsMedium14.textColor(appCtrl.appTheme.primary)),
            const VSpace(Sizes.s10),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                        width: Sizes.s220,
                        height: Sizes.s200,
                        padding: const EdgeInsets.all(70.0),
                        decoration: BoxDecoration(
                          color: appCtrl.appTheme.accent,
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(Insets.i20),
                              bottomLeft: Radius.circular(Insets.i20),
                              bottomRight: Radius.circular(Insets.i20)),
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
                  style: AppCss.poppinsBold12
                      .textColor(appCtrl.appTheme.whiteColor),
                ).marginSymmetric(horizontal: Insets.i10, vertical: Insets.i10).boxShadow( blurRadius: 15.0,
                    color: appCtrl.appTheme.blackColor.withOpacity(.25),offset:const Offset(-2, 2))
              ],
            ),
          ],
        ));
  }
}
