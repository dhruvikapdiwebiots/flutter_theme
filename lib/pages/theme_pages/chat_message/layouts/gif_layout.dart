import 'package:intl/intl.dart';

import '../../../../config.dart';

class GifLayout extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  const GifLayout({Key? key,this.document,this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onLongPress: onLongPress,
        child: Column(
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
        ).marginSymmetric(vertical: Insets.i8,horizontal: Insets.i10));
  }
}
