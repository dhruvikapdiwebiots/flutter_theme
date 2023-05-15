import 'dart:developer';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:intl/intl.dart';
import '../../../../config.dart';

class PdfLayout extends StatefulWidget {
  final dynamic document;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onTap;
  final bool isReceiver, isGroup, isBroadcast;
  final String? currentUserId;

  const PdfLayout(
      {Key? key,
      this.document,
      this.onLongPress,
      this.onTap,
      this.isReceiver = false,
      this.isGroup = false,
      this.isBroadcast = false,
      this.currentUserId})
      : super(key: key);

  @override
  State<PdfLayout> createState() => _PdfLayoutState();
}

class _PdfLayoutState extends State<PdfLayout> {
  PDFDocument? doc;
  bool downloading = false,isSeen = false;
  var progressString = "";

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  getData() async {
    isSeen = widget.document!['isSeen'] ?? false;
    log("LINK : ${widget.document!['content'].split("-BREAK-")[1]}");
    doc = await PDFDocument.fromURL(
        widget.document!['content'].split("-BREAK-")[1].toString());
    setState(() {});
    log("DOC : $doc");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
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
                                cornerRadius: 20, cornerSmoothing: 1),
                            topRight: const SmoothRadius(
                                cornerRadius: 20, cornerSmoothing: 1),
                            bottomLeft: SmoothRadius(
                                cornerRadius: widget.isReceiver ? 0 : 20,
                                cornerSmoothing: 1),
                            bottomRight: SmoothRadius(
                                cornerRadius: widget.isReceiver ? 20 : 0,
                                cornerSmoothing: 1)))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isGroup)
                        if (widget.isReceiver)
                          if (widget.currentUserId != null)
                            if (widget.document!["sender"] !=
                                widget.currentUserId)
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
                                horizontal: Insets.i10, vertical: Insets.i8)
                            .decorated(
                                color: appCtrl.appTheme.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r8)),
                        const HSpace(Sizes.s10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  widget.document!['content'].split("-BREAK-")[0],
                                  textAlign: TextAlign.start,
                                  style: AppCss.poppinsMedium12
                                      .textColor(widget.isReceiver
                                          ? appCtrl.appTheme.lightBlackColor
                                          : appCtrl.appTheme.white)
                                      .textHeight(1.2)),
                              const VSpace(Sizes.s5),
                              if (doc != null)
                                Row(children: [
                                  Text("${doc!.count.toString()} Page | PDF",
                                      style: AppCss.poppinsMedium12.textColor(
                                          widget.isReceiver
                                              ? appCtrl.appTheme.txtColor
                                              : appCtrl.appTheme.white))
                                ])
                            ]))
                      ])
                    ])),
            if (widget.document!.data().toString().contains('emoji'))
              EmojiLayout(emoji: widget.document!["emoji"]),
          ],
        ),
        IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (!widget.isGroup)
            if (!widget.isReceiver || !widget.isBroadcast)
              Icon(Icons.done_all_outlined,
                  size: Sizes.s15,
                  color:isSeen == true
                      ? appCtrl.appTheme.primary
                      : appCtrl.appTheme.gray),
          const HSpace(Sizes.s5),
          Text(
              DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                  int.parse(widget.document!['timestamp']))),
                style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.white))
        ]).marginSymmetric(vertical: Insets.i3))
      ])
          .marginSymmetric(horizontal: Insets.i10, vertical: Insets.i5),
    );
  }
}
