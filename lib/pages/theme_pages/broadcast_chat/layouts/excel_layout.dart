import 'dart:developer';

import 'package:intl/intl.dart';

import '../../../../config.dart';

class ExcelLayout extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  final bool isReceiver;

  const ExcelLayout(
      {Key? key, this.document, this.onLongPress, this.isReceiver = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: () {
        log("url : ${document!['content'].split("-BREAK-")[1]}");
        launchUrl(Uri.parse(document!['content'].split("-BREAK-")[1]));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Image.asset(imageAssets.xlsx, height: Sizes.s20),
              const HSpace(Sizes.s10),
              Text(
                document!['content'].split("-BREAK-")[0],
                textAlign: TextAlign.center,
                style: AppCss.poppinsMedium12.textColor(isReceiver
                    ? appCtrl.appTheme.lightBlackColor
                    : appCtrl.appTheme.whiteColor),
              ),
            ],
          )
              .width(220)
              .paddingSymmetric(horizontal: Insets.i10, vertical: Insets.i15)
              .decorated(
                  color: isReceiver ? Color(0xFFEBF0F8) : Color(0xFF2958A3),
                  borderRadius: BorderRadius.circular(AppRadius.r8)),
          const VSpace(Sizes.s10),
          Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(document!['timestamp']))),
              style: AppCss.poppinsMedium12.textColor(isReceiver
                  ? appCtrl.appTheme.lightBlackColor
                  : appCtrl.appTheme.whiteColor))
        ],
      )
          .paddingAll(Insets.i8)
          .decorated(
              color: isReceiver
                  ? appCtrl.appTheme.whiteColor
                  : appCtrl.appTheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.r8))
          .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i5),
    );
  }
}
