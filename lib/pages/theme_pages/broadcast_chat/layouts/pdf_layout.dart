import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_theme/widgets/pdf_viewer_layout.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../config.dart';

class PdfLayout extends StatelessWidget {
  final dynamic document;
  final GlobalKey<SfPdfViewerState>? pdfViewerKey;
  final GestureLongPressCallback? onLongPress;
  final bool isReceiver, isGroup;
  final String? currentUserId;

  const PdfLayout(
      {Key? key,
      this.document,
      this.pdfViewerKey,
      this.onLongPress,
      this.isReceiver = false,
      this.isGroup = false,
      this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: isReceiver ? Alignment.topLeft : Alignment.topRight,
      children: [
        Stack(alignment: Alignment.bottomRight, children: [
          if (isGroup)
            if (isReceiver)
              if (currentUserId != null)
                if (document!["sender"] != currentUserId)
                  Align(
                      alignment: Alignment.topLeft,
                      child: Column(children: [
                        Text(document!['senderName'],
                            style: AppCss.poppinsMedium12
                                .textColor(appCtrl.appTheme.primary)),
                        const VSpace(Sizes.s8)
                      ])),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SfPdfViewer.network(
                document!['content'].split("-BREAK-")[1],
                key: pdfViewerKey,
              ).width(220).clipRRect(all: AppRadius.r8),
              Row(
                children: [
                  Image.asset(imageAssets.pdf, height: Sizes.s20),
                  const HSpace(Sizes.s10),
                  Expanded(
                    child: Text(
                      document!['content'].split("-BREAK-")[0],
                      textAlign: TextAlign.start,
                      style: AppCss.poppinsMedium12
                          .textColor(isReceiver
                              ? appCtrl.appTheme.lightBlackColor
                              : appCtrl.appTheme.whiteColor)
                          .textHeight(1.2),
                    ),
                  ),
                ],
              )
                  .width(220)
                  .paddingSymmetric(
                      horizontal: Insets.i10, vertical: Insets.i15)
                  .decorated(
                      color: isReceiver
                          ? appCtrl.appTheme.lightGreyColor
                          : appCtrl.appTheme.primary.withOpacity(.9))
            ],
          )
              .height(Sizes.s120)
              .width(Sizes.s220)
              .paddingOnly(
                  left: Insets.i5,
                  right: Insets.i5,
                  top: Insets.i5,
                  bottom: Insets.i35)
              .decorated(
                  color: isReceiver
                      ? appCtrl.appTheme.whiteColor
                      : appCtrl.appTheme.primary,
                  borderRadius: BorderRadius.only(
                      bottomRight: const Radius.circular(Insets.i8),
                      topRight: isReceiver
                          ? const Radius.circular(Insets.i8)
                          : const Radius.circular(0),
                      topLeft: isReceiver
                          ? const Radius.circular(0)
                          : const Radius.circular(Insets.i8),
                      bottomLeft: const Radius.circular(Insets.i8)))
              .inkWell(onTap: () {
            Get.to(() => PdfViewerLayout(
                url: document!['content'].split("-BREAK-")[1]));
          }),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (isReceiver)
              Icon(Icons.download_outlined,
                      color: appCtrl.appTheme.lightBlackColor)
                  .inkWell(onTap: () async{
                var openResult = 'Unknown';
                var dio = Dio();
                var tempDir = await getExternalStorageDirectory();

                var filePath = tempDir!.path + document!['content'].split("-BREAK-")[0];
                final response = await dio.download(
                    document!['content'].split("-BREAK-")[1], filePath);
                log("response : ${response.statusCode}");

                final result = await OpenFilex.open(filePath);

                openResult = "type=${result.type}  message=${result.message}";
                log("openResult : $openResult");
                OpenFilex.open(filePath);
              }),
            Text(
              DateFormat('HH:mm a').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      int.parse(document!['timestamp']))),
              style: AppCss.poppinsMedium12.textColor(isReceiver
                  ? appCtrl.appTheme.lightBlackColor
                  : appCtrl.appTheme.whiteColor),
            ).marginAll(Insets.i10)
          ])
        ]),
        CustomPaint(
            painter: CustomShape(isReceiver
                ? appCtrl.appTheme.whiteColor
                : appCtrl.appTheme.primary)),
      ],
    ).marginSymmetric(horizontal: Insets.i10, vertical: Insets.i5);
  }
}
