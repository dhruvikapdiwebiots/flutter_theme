

import 'dart:developer';

import '../../../../../config.dart';

class SenderMessage extends StatefulWidget {
  final dynamic document;
  final int? index;

  const SenderMessage({Key? key, this.document, this.index}) : super(key: key);

  @override
  State<SenderMessage> createState() => _SenderMessageState();
}

class _SenderMessageState extends State<SenderMessage> {

  double progress = 0;

  // Track if the PDF was downloaded here.
  bool didDownloadPDF = false;

  // Show the progress status to the user.
  String progressString = 'File has not been downloaded yet.';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      log("CONTENT : ${widget.document!["content"] }");
      return Stack(
        children: [
          Container(
              margin: const EdgeInsets.only(bottom: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: <
                      Widget>[
                    if (widget.document!["type"] == MessageType.text.name)
                      // Text
                      Content(

                          document: widget.document),
                    if (widget.document!["type"] == MessageType.image.name)
                      SenderImage(
                        document: widget.document,
                        onLongPress: () {
                          showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) => chatCtrl
                                .buildPopupDialog(context, widget.document!),
                          );
                        }
                      ),
                    if (widget.document!["type"] == MessageType.contact.name)
                      ContactLayout(
                              onLongPress: () {
                                showDialog(
                                  context: Get.context!,
                                  builder: (BuildContext context) =>
                                      chatCtrl.buildPopupDialog(
                                          context, widget.document!),
                                );
                              },
                              document: widget.document)
                          .paddingSymmetric(vertical: Insets.i8),
                    if (widget.document!["type"] == MessageType.location.name)
                      LocationLayout(
                          document: widget.document,
                          onLongPress: () {
                            showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!),
                            );
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
                                builder: (BuildContext context) =>
                                    chatCtrl.buildPopupDialog(
                                        context, widget.document!));
                          }),
                    if (widget.document!["type"] == MessageType.doc.name)
                      (widget.document!["content"].contains(".pdf"))
                          ? PdfLayout(
                              document: widget.document,
                              onLongPress: () {
                                showDialog(
                                    context: Get.context!,
                                    builder: (BuildContext context) =>
                                        chatCtrl.buildPopupDialog(
                                            context, widget.document!));
                              },

                            )
                          : (widget.document!["content"].contains(".doc"))
                              ? DocxLayout(
                                  document: widget.document,
                                  onLongPress: () {
                                    showDialog(
                                        context: Get.context!,
                                        builder: (BuildContext context) =>
                                            chatCtrl.buildPopupDialog(
                                                context, widget.document!));
                                  })
                              : (widget.document!["content"].contains(".xlsx"))
                                  ? ExcelLayout(
                                      onLongPress: () {
                                        showDialog(
                                            context: Get.context!,
                                            builder: (BuildContext context) =>
                                                chatCtrl.buildPopupDialog(
                                                    context, widget.document!));
                                      },
                                      document: widget.document,
                                    )
                                  : (widget.document!["content"]
                                              .contains(".jpg") ||
                                          widget.document!["content"]
                                              .contains(".png") ||
                                          widget.document!["content"]
                                              .contains(".heic") ||
                                          widget.document!["content"]
                                              .contains(".jpeg"))
                                      ? DocImageLayout(
                                          document: widget.document,
                                          onLongPress: () {
                                            showDialog(
                                                context: Get.context!,
                                                builder: (BuildContext
                                                        context) =>
                                                    chatCtrl.buildPopupDialog(
                                                        context,
                                                        widget.document!));
                                          })
                                      : Container(),
                    if (widget.document!["type"] == MessageType.gif.name)
                      GifLayout(
                        onLongPress: () {
                          showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!));
                        },
                        document: widget.document,
                      )
                  ]),
                  if (widget.document!["type"] == MessageType.messageType.name)
                    Align(
                      alignment: Alignment.center,
                      child: Text(widget.document!["content"])
                          .paddingSymmetric(
                              horizontal: Insets.i8, vertical: Insets.i10)
                          .decorated(
                              color: appCtrl.appTheme.primary.withOpacity(.2),
                              borderRadius: BorderRadius.circular(AppRadius.r8))
                          .alignment(Alignment.center),
                    ).paddingOnly(bottom: Insets.i8)
                ],
              )),
        ],
      );
    });
  }
}
