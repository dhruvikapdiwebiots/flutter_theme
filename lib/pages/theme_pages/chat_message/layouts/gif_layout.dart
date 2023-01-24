import 'package:intl/intl.dart';

import '../../../../config.dart';

class GifLayout extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  final bool isReceiver,isGroup;
  final String? currentUserId;
  const GifLayout({Key? key,this.document,this.onLongPress, this.isReceiver = false, this.isGroup = false,this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGroup)
              if (isReceiver)
                if (document!["sender"] != currentUserId)
                  Align(
                      alignment: Alignment.topLeft,
                      child: Column(children: [
                        Text(document!['senderName'],
                            style: AppCss.poppinsMedium12
                                .textColor(appCtrl.appTheme.primary)).paddingSymmetric(horizontal: Insets.i10,vertical: Insets.i5).decorated(color:  appCtrl.appTheme.whiteColor ,borderRadius: BorderRadius.circular(AppRadius.r20)),
                      ])),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.network(
                  document!["content"],
                  height: Sizes.s100
                ),
                Text( DateFormat('HH:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document!['timestamp']))),
                    style: AppCss.poppinsMedium12
                        .textColor(appCtrl.appTheme.txt))
                    .paddingOnly(
                    left: Insets.i8,
                    right: Insets.i8,
                    top: Insets.i5,
                    bottom: Insets.i2)
                    .decorated(
                    color:
                    appCtrl.appTheme.grey.withOpacity(.3),
                    borderRadius:
                    BorderRadius.circular(AppRadius.r30)),
              ],
            ),
          ],
        ).marginSymmetric(vertical: Insets.i8,horizontal: Insets.i10));
  }
}
