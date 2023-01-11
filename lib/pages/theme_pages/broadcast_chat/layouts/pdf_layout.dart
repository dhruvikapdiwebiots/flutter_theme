import 'package:flutter_theme/widgets/pdf_viewer_layout.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../config.dart';

class PdfLayout extends StatelessWidget {
  final dynamic document;
  final GlobalKey<SfPdfViewerState>? pdfViewerKey;
  final GestureLongPressCallback? onLongPress;
  const PdfLayout({Key? key,this.document,this.pdfViewerKey,this.onLongPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Stack(alignment: Alignment.bottomRight, children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SfPdfViewer.network(
              document!['content'].split("-BREAK-")[1],
              key: pdfViewerKey,
            ).width(220).clipRRect(all: AppRadius.r8),
            Text(
              document!['content'].split("-BREAK-")[0],
              textAlign: TextAlign.center,
              style:
                  AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor),
            )
                .width(220)
                .paddingSymmetric(horizontal: Insets.i10, vertical: Insets.i15)
                .decorated(color: appCtrl.appTheme.primary.withOpacity(.9)),
          ],
        )
            .height(120)
            .width(220)
            .paddingOnly(
                left: Insets.i5,
                right: Insets.i5,
                top: Insets.i5,
                bottom: Insets.i35)
            .decorated(
                color: appCtrl.appTheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.r10))
            .inkWell(
                onTap: () => Get.to(PdfViewerLayout(
                    url: document!['content'].split("-BREAK-")[1]))),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(Icons.download_outlined, color: appCtrl.appTheme.whiteColor)
              .inkWell(onTap: () {}),
          Text(
            DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                int.parse(document!['timestamp']))),
            style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor),
          ).marginAll(Insets.i10)
        ])
      ]).marginSymmetric(horizontal: Insets.i10, vertical: Insets.i5),
    );
  }
}
