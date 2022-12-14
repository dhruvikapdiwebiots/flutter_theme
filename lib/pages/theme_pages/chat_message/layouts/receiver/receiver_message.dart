import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../config.dart';

class ReceiverMessage extends StatefulWidget {
  final dynamic document;
  final int? index;

  const ReceiverMessage({Key? key, this.index, this.document})
      : super(key: key);

  @override
  State<ReceiverMessage> createState() => _ReceiverMessageState();
}

class _ReceiverMessageState extends State<ReceiverMessage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Row(
            children: <Widget>[
              // MESSAGE BOX FOR TEXT
              if (widget.document!["type"] == MessageType.text.name)
                ReceiverContent(
                  onLongPress: () {
                    showDialog(
                      context: Get.context!,
                      builder: (BuildContext context) =>
                          chatCtrl.buildPopupDialog(context, widget.document!),
                    );
                  },
                  document: widget.document,
                ),

              // MESSAGE BOX FOR IMAGE
              if (widget.document!["type"] == MessageType.image.name)
                ReceiverImage(
                  document: widget.document,
                  onLongPress: () {
                    showDialog(
                      context: Get.context!,
                      builder: (BuildContext context) =>
                          chatCtrl.buildPopupDialog(context, widget.document!),
                    );
                  },
                ),

              if (widget.document!["type"] == MessageType.contact.name)
                ContactLayout(
                    onLongPress: () {
                      showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!));
                    },
                    document: widget.document),
              if (widget.document!["type"] == MessageType.location.name)
                LocationLayout(
                    document: widget.document,
                    onLongPress: () {
                      showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!));
                    },
                    onTap: () {
                      launchUrl(Uri.parse(widget.document!["content"]));
                    }),
              if (widget.document!["type"] == MessageType.video.name)
                VideoDoc(document: widget.document),
              if (widget.document!["type"] == MessageType.audio.name)
                AudioDoc(
                    document: widget.document,
                    onLongPress: () {
                      showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!));
                    }),
              if (widget.document!["type"] == MessageType.doc.name)
                (widget.document!["content"].contains(".pdf"))
                    ? PdfLayout(
                        document: widget.document,
                        pdfViewerKey: _pdfViewerKey,
                        onLongPress: () {
                          showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!));
                        })
                    : (widget.document!["content"].contains(".docx"))
                        ? DocxLayout(
                            document: widget.document,
                            onLongPress: () {
                              showDialog(
                                  context: Get.context!,
                                  builder: (BuildContext context) =>
                                      chatCtrl.buildPopupDialog(
                                          context, widget.document!));
                            })
                        : Container(),
              if (widget.document!["type"] == MessageType.gif.name)
                GifLayout(
                    document: widget.document,
                    onLongPress: () {
                      showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!));
                    })
            ],
          ),
          if (widget.document!["type"] == MessageType.messageType.name)
            Align(
                    alignment: Alignment.center,
                    child: Text(widget.document!["content"])
                        .paddingSymmetric(
                            horizontal: Insets.i8, vertical: Insets.i10)
                        .decorated(
                            color: appCtrl.appTheme.primary.withOpacity(.2),
                            borderRadius: BorderRadius.circular(AppRadius.r8))
                        .alignment(Alignment.center))
                .paddingOnly(bottom: Insets.i8)
        ]),
      );
    });
  }
}
