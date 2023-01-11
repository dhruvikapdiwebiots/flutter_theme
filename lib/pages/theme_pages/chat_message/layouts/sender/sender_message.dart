import 'dart:io';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../config.dart';

class SenderMessage extends StatefulWidget {
  final dynamic document;
  final int? index;

  const SenderMessage({Key? key, this.document, this.index}) : super(key: key);

  @override
  State<SenderMessage> createState() => _SenderMessageState();
}

class _SenderMessageState extends State<SenderMessage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  double progress = 0;

  // Track if the PDF was downloaded here.
  bool didDownloadPDF = false;

  // Show the progress status to the user.
  String progressString = 'File has not been downloaded yet.';

  Future<bool> saveFile(String url, String fileName) async {
    try {
      PermissionHandlerController.checkAndRequestPermission(
              Platform.isIOS ? Permission.storage : Permission.storage)
          .then((res) async {
        if (res) {

          final appDocDir = await getApplicationDocumentsDirectory();

          //Here you'll specify the file it should be saved as
          File downloadToFile = File('${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}');
          //Here you'll specify the file it should download from Cloud Storage
          String fileToDownload =url;

          //Now you can try to download the specified file, and write it to the downloadToFile.
          try {
            await FirebaseStorage.instance
                .ref(fileToDownload)
                .writeToFile(downloadToFile);
          } on FirebaseException catch (e) {
            log("e : $e");
            // e.g, e.code == 'canceled'

          }
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      log("hdgfjhdsg : ${widget.document!["timestamp"]}");
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
                          onLongPress: () {
                            showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!),
                            );
                          },
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
                          }),
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
                          ? PdfLayout(document: widget.document,pdfViewerKey: _pdfViewerKey,)
                          : (widget.document!["content"].contains(".docx"))
                              ? DocxLayout(document: widget.document,)
                              : Container(),
                    if (widget.document!["type"] == MessageType.gif.name)
                      GifLayout(onLongPress: () {
                        showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                chatCtrl.buildPopupDialog(
                                    context, widget.document!));
                      },document: widget.document,)
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
