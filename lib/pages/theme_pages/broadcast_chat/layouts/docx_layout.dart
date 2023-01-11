import 'package:intl/intl.dart';

import '../../../../config.dart';

class DocxLayout extends StatelessWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  const DocxLayout({Key? key, this.document,this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress:onLongPress ,
      child: Stack(
        children: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: Insets.i8),
              padding: const EdgeInsets.only(
                bottom: Insets.i15,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  color: appCtrl.appTheme.primary),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: Insets.i8, vertical: Insets.i5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Insets.i15, vertical: Insets.i15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                        color: appCtrl.appTheme.whiteColor.withOpacity(.1)),
                    child: Text(
                      document!['content'].split("-BREAK-")[0],
                      textAlign: TextAlign.center,
                      style: AppCss.poppinsMedium12
                          .textColor(appCtrl.appTheme.whiteColor),
                    )),
                const VSpace(Sizes.s8),
                Text(
                  DateFormat('HH:mm a').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document!['timestamp']))),
                  style: AppCss.poppinsMedium12
                      .textColor(appCtrl.appTheme.whiteColor),
                ).marginSymmetric(horizontal: Insets.i10)
              ]))
        ],
      ).inkWell(onTap: () {
        launchUrl(Uri.parse(document!['content'].split("-BREAK-")[1]));
      }),
    );
  }
}
