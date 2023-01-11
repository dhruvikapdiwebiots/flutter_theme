import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_theme/widgets/pdf_viewer_layout.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
          Reference reference = FirebaseStorage.instance.ref().child(fileName);

          final appDocDir = await getApplicationDocumentsDirectory();
          final filePath = "${appDocDir.absolute}/images/";
          final file = File(filePath);

          final downloadTask = reference.writeToFile(file);
        /*  Directory appDocDir = await getApplicationDocumentsDirectory();
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
            // e.g, e.code == 'canceled'
            print('Download error: $e');
          }*/
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  showDialogLayout() {
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
              title: const CircularProgressIndicator().height(Sizes.s50),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Column();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
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
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!),
                            );
                          },
                          document: widget.document).paddingSymmetric(vertical: Insets.i8),
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
                          ? Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              SfPdfViewer.network(
                                widget.document!['content']
                                    .split("-BREAK-")[1],
                                key: _pdfViewerKey,
                              ).width(220).clipRRect(all: AppRadius.r8),
                              Text(
                                widget.document!['content']
                                    .split("-BREAK-")[0],
                                textAlign: TextAlign.center,
                                style: AppCss.poppinsMedium12
                                    .textColor(appCtrl.appTheme.whiteColor),
                              )
                                  .width(220)
                                  .paddingSymmetric(
                                  horizontal: Insets.i10,
                                  vertical: Insets.i15)
                                  .decorated(
                                  color: appCtrl.appTheme.primary
                                      .withOpacity(.9)),
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
                              borderRadius:
                              BorderRadius.circular(AppRadius.r10))
                              .inkWell(
                              onTap: () => Get.to(PdfViewerLayout(
                                  url: widget.document!['content']
                                      .split("-BREAK-")[1]))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.download_outlined,
                                  color: appCtrl.appTheme.whiteColor)
                                  .inkWell(
                                  onTap: () => saveFile(
                                      widget.document!['content']
                                          .split("-BREAK-")[1],
                                      widget.document!['content']
                                          .split("-BREAK-")[0])),
                              Text(
                                DateFormat('HH:mm a').format(DateTime
                                    .fromMillisecondsSinceEpoch(int.parse(
                                    widget.document!['timestamp']))),
                                style: AppCss.poppinsMedium12
                                    .textColor(appCtrl.appTheme.whiteColor),
                              ).marginAll(Insets.i10),
                            ],
                          )
                        ],
                      ).marginSymmetric(horizontal: Insets.i10,vertical: Insets.i5)
                          : (widget.document!["content"].contains(".docx"))
                          ? Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: Insets.i8),
                            padding: const EdgeInsets.only(bottom: Insets.i15,),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    AppRadius.r8),
                                color: appCtrl.appTheme.primary),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    margin: const EdgeInsets.symmetric(horizontal: Insets.i8,vertical: Insets.i5),
                                    padding: const EdgeInsets.symmetric(horizontal: Insets.i15,vertical: Insets.i15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r8),
                                        color: appCtrl.appTheme.whiteColor
                                            .withOpacity(.1)),
                                    child: Text(
                                      widget.document!['content']
                                          .split("-BREAK-")[0],
                                      textAlign: TextAlign.center,
                                      style: AppCss.poppinsMedium12.textColor(
                                          appCtrl.appTheme.whiteColor),
                                    )),
                                const VSpace(Sizes.s8),
                                Text(
                                  DateFormat('HH:mm a').format(DateTime
                                      .fromMillisecondsSinceEpoch(int.parse(
                                      widget.document!['timestamp']))),
                                  style: AppCss.poppinsMedium12
                                      .textColor(appCtrl.appTheme.whiteColor),
                                ).marginSymmetric(horizontal: Insets.i10)
                              ],
                            ),
                          )
                        ],
                      ).inkWell(onTap: (){

                        launchUrl(Uri.parse(widget.document!['content']
                            .split("-BREAK-")[1]));
                      })
                          : Container(),
                    if(widget.document!["type"] == MessageType.gif.name)
                      InkWell(onLongPress: () {
                        showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) => chatCtrl
                                .buildPopupDialog(context, widget.document!));
                      } ,child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.document!['senderName'],
                                  style: AppCss.poppinsMedium12
                                      .textColor(appCtrl.appTheme.txt))
                                  .paddingOnly(
                                  left: Insets.i8,
                                  right: Insets.i8,
                                  top: Insets.i5,
                                  bottom: Insets.i2)
                                  .decorated(
                                  color: appCtrl.appTheme.grey.withOpacity(.3),
                                  borderRadius:
                                  BorderRadius.circular(AppRadius.r30)),
                              const VSpace(Sizes.s2),
                              Image.network(
                                widget.document!["content"],
                                height: Sizes.s100,
                              ),
                            ],
                          ),
                          Text(widget.document!['senderName'],
                              style: AppCss.poppinsMedium12
                                  .textColor(appCtrl.appTheme.txt))
                              .paddingOnly(
                              left: Insets.i8,
                              right: Insets.i8,
                              top: Insets.i5,
                              bottom: Insets.i2)
                              .decorated(
                              color: appCtrl.appTheme.grey.withOpacity(.3),
                              borderRadius: BorderRadius.circular(AppRadius.r30)),
                        ],
                      ).marginOnly(bottom: Insets.i8))
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
