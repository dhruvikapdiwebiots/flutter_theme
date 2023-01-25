import 'dart:io';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../config.dart';

class BroadcastSenderMessage extends StatefulWidget {
  final dynamic document;
  final int? index;

  const BroadcastSenderMessage({Key? key, this.document, this.index}) : super(key: key);

  @override
  State<BroadcastSenderMessage> createState() => _BroadcastSenderMessage();
}

class _BroadcastSenderMessage extends State<BroadcastSenderMessage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  double progress = 0;

  // Track if the PDF was downloaded here.
  bool didDownloadPDF = false;

  // Show the progress status to the user.
  String progressString = 'File has not been downloaded yet.';

  Future<bool> saveFile(String url, String fileName) async {
    log("djhfgd");
    try {
      PermissionHandlerController.checkAndRequestPermission(
          Platform.isIOS ? Permission.storage : Permission.storage)
          .then((res) async {
        if (res) {
          final storageRef = FirebaseStorage.instance.refFromURL(url);

          final islandRef = storageRef.child(storageRef.name);

          log("islandRef : $islandRef");

          final appDocDir = await getApplicationDocumentsDirectory();
          final filePath =
              "${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}";
          final file = File(filePath);

          final downloadTask = FirebaseStorage.instance
              .ref()
              .child(storageRef.fullPath)
              .writeToFile(file);

          log("downloadTask : $downloadTask");

          downloadTask.snapshotEvents.listen((taskSnapshot) {
            switch (taskSnapshot.state) {
              case TaskState.running:
              // TODO: Handle this case.
                break;
              case TaskState.paused:
              // TODO: Handle this case.
                break;
              case TaskState.success:
              // TODO: Handle this case.
                break;
              case TaskState.canceled:
              // TODO: Handle this case.
                break;
              case TaskState.error:
              // TODO: Handle this case.
                break;
            }
          });
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
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
                        },
                        onPressed: () =>
                            saveFile(widget.document!["content"], "image"),
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
                        pdfViewerKey: _pdfViewerKey,
                      )
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
