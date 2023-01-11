
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../config.dart';

class GroupSenderMessage extends StatefulWidget {
  final DocumentSnapshot? document;
  final int? index;
  final String? currentUserId;

  const GroupSenderMessage(
      {Key? key, this.document, this.index, this.currentUserId})
      : super(key: key);

  @override
  State<GroupSenderMessage> createState() => _GroupSenderMessageState();
}

class _GroupSenderMessageState extends State<GroupSenderMessage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return Container(
          margin: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                if (widget.document!["type"] == MessageType.text.name)
                  // Text
                  GroupContent(
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      },
                      document: widget.document),
                if (widget.document!["type"] == MessageType.image.name)
                  GroupSenderImage(
                      document: widget.document,
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      }),
                if (widget.document!["type"] == MessageType.contact.name)
                  GroupContactLayout(
                      currentUserId: widget.currentUserId,
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      },
                      document: widget.document),
                if (widget.document!["type"] == MessageType.location.name)
                  GroupLocationLayout(
                      document: widget.document,
                      currentUserId: chatCtrl.id,
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
                  GroupVideoDoc(
                      document: widget.document,
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) => chatCtrl
                              .buildPopupDialog(context, widget.document!),
                        );
                      }),
                if (widget.document!["type"] == MessageType.audio.name)
                  GroupAudioDoc(
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
                                builder: (BuildContext context) =>
                                    chatCtrl.buildPopupDialog(
                                        context, widget.document!));
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
          ));
    });
  }
}
