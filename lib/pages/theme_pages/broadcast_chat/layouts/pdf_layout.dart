import 'dart:developer';
import 'dart:math' as math;
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:dio/dio.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_theme/widgets/pdf_viewer_layout.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../config.dart';

class PdfLayout extends StatefulWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  final bool isReceiver, isGroup;
  final String? currentUserId;

  const PdfLayout(
      {Key? key,
      this.document,
      this.onLongPress,
      this.isReceiver = false,
      this.isGroup = false,
      this.currentUserId})
      : super(key: key);

  @override
  State<PdfLayout> createState() => _PdfLayoutState();
}

class _PdfLayoutState extends State<PdfLayout> {
  PDFDocument? doc;
  bool downloading = false;
  var progressString = "";
  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  getData() async {
    log("LINK : ${widget.document!['content'].split("-BREAK-")[1]}");
    doc = await PDFDocument.fromURL(
        widget.document!['content'].split("-BREAK-")[1].toString());
    setState(() {});
    log("DOC : $doc");
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(
          padding: const EdgeInsets.all(Insets.i15),
          width: Sizes.s210,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: widget.isReceiver
                ? const Color.fromRGBO(153, 158, 166, 0.1)
                : appCtrl.appTheme.primary,
            shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                    topLeft: const SmoothRadius(
                      cornerRadius: 20,
                      cornerSmoothing: .5,
                    ),
                    topRight: const SmoothRadius(
                      cornerRadius: 20,
                      cornerSmoothing: 0.4,
                    ),
                    bottomLeft: SmoothRadius(
                      cornerRadius: widget.isReceiver ? 0 : 20,
                      cornerSmoothing: .5,
                    ),
                    bottomRight: SmoothRadius(
                      cornerRadius: widget.isReceiver ? 20 : 0,
                      cornerSmoothing: .5,
                    ))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isGroup)
                if (widget.isReceiver)
                  if (widget.currentUserId != null)
                    if (widget.document!["sender"] != widget.currentUserId)
                      Align(
                          alignment: Alignment.topLeft,
                          child: Column(children: [
                            Text(widget.document!['senderName'],
                                style: AppCss.poppinsMedium12
                                    .textColor(appCtrl.appTheme.primary)),
                            const VSpace(Sizes.s8)
                          ])),
              Row(children: [
                SvgPicture.asset(svgAssets.pdf, height: Sizes.s20)
                    .paddingSymmetric(
                        horizontal: Insets.i12, vertical: Insets.i8)
                    .decorated(
                        color: appCtrl.appTheme.white,
                        borderRadius: BorderRadius.circular(AppRadius.r8)),
                const HSpace(Sizes.s10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(widget.document!['content'].split("-BREAK-")[0],
                          textAlign: TextAlign.start,
                          style: AppCss.poppinsMedium12
                              .textColor(widget.isReceiver
                                  ? appCtrl.appTheme.lightBlackColor
                                  : appCtrl.appTheme.whiteColor)
                              .textHeight(1.2)),
                      const VSpace(Sizes.s5),
                      if(doc != null)
                      Row(children: [
                        Text(
                          "${doc!.count.toString()} Page",
                          style: AppCss.poppinsMedium12.textColor(
                              widget.isReceiver
                                  ? appCtrl.appTheme.txtColor
                                  : appCtrl.appTheme.white),
                        )
                      ])
                    ]))
              ])
            ],
          )),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isGroup)
              if (!widget.isReceiver)
                Icon(Icons.done_all_outlined,
                    size: Sizes.s15,
                    color: widget.document!['isSeen'] == true
                        ? appCtrl.appTheme.primary
                        : appCtrl.appTheme.whiteColor),
            const HSpace(Sizes.s5),
            Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(widget.document!['timestamp']))),
              style:
                  AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor),
            )
          ],
        ).marginSymmetric(vertical: Insets.i3),
      )
    ]).marginSymmetric(horizontal: Insets.i10, vertical: Insets.i5).inkWell(
        onTap: () async {
      var openResult = 'Unknown';
      var dio = Dio();
      var tempDir = await getExternalStorageDirectory();

      var filePath =
          tempDir!.path + widget.document!['content'].split("-BREAK-")[0];

      final response = await dio.download(
          widget.document!['content'].split("-BREAK-")[1], filePath);
      log("response : ${response.statusCode}");

      final result = await OpenFilex.open(filePath);

      openResult = "type=${result.type}  message=${result.message}";
      log("openResult : $openResult");
      OpenFilex.open(filePath);
    });
  }
}
