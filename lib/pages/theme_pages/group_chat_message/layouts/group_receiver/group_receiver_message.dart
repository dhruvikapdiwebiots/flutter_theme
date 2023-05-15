import 'package:flutter_theme/pages/theme_pages/chat_message/layouts/receiver_image.dart';
import '../../../../../config.dart';

class GroupReceiverMessage extends StatefulWidget {
  final DocumentSnapshot? document;
final String? docId;
  final int? index;

  const GroupReceiverMessage({Key? key, this.index, this.document,this.docId})
      : super(key: key);

  @override
  State<GroupReceiverMessage> createState() => _GroupReceiverMessageState();
}

class _GroupReceiverMessageState extends State<GroupReceiverMessage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: [
            ReceiverChatImage(
              id: widget.document!["sender"],
            ),
            Column(children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // MESSAGE BOX FOR TEXT
                  if (widget.document!["type"] == MessageType.text.name)
                    GroupReceiverContent(
                        onLongPress: () {
                          showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!));
                        },
                        document: widget.document),

                  // MESSAGE BOX FOR IMAGE
                  if (widget.document!["type"] == MessageType.image.name)
                    GroupReceiverImage(document: widget.document),

                  if (widget.document!["type"] == MessageType.contact.name)
                    GroupContactLayout(
                        isReceiver: true,
                        currentUserId: chatCtrl.user["id"],
                        onLongPress: () {
                          showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!));
                        },
                        document: widget.document),
                  if (widget.document!["type"] == MessageType.location.name)
                    GroupLocationLayout(
                        isReceiver: true,
                        document: widget.document,
                        currentUserId: chatCtrl.user["id"],
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
                    GroupVideoDoc(
                        isReceiver: true,
                        currentUserId: chatCtrl.user["id"],
                        document: widget.document,
                        onLongPress: () {
                          showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) => chatCtrl
                                  .buildPopupDialog(context, widget.document!));
                        }),
                  if (widget.document!["type"] == MessageType.audio.name)
                    GroupAudioDoc(
                        isReceiver: true,
                        currentUserId: chatCtrl.user["id"],
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
                            isReceiver: true,
                            isGroup: true,
                            document: widget.document,
                            onLongPress: () {
                              showDialog(
                                  context: Get.context!,
                                  builder: (BuildContext context) =>
                                      chatCtrl.buildPopupDialog(
                                          context, widget.document!));
                            })
                        : (widget.document!["content"].contains(".doc"))
                            ? DocxLayout(
                                document: widget.document,
                                isReceiver: true,
                                isGroup: true,
                                onLongPress: () {
                                  showDialog(
                                      context: Get.context!,
                                      builder: (BuildContext context) =>
                                          chatCtrl.buildPopupDialog(
                                              context, widget.document!));
                                })
                            : (widget.document!["content"].contains(".xlsx"))
                                ? ExcelLayout(
                                    currentUserId: chatCtrl.user["id"],
                                    isReceiver: true,
                                    isGroup: true,
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
                                        currentUserId: chatCtrl.user["id"],
                                        isGroup: true,
                                        isReceiver: true,
                                        document: widget.document,
                                        onLongPress: () {
                                          showDialog(
                                              context: Get.context!,
                                              builder: (BuildContext context) =>
                                                  chatCtrl.buildPopupDialog(
                                                      context,
                                                      widget.document!));
                                        })
                                    : Container(),

                  if (widget.document!["type"] == MessageType.gif.name)
                    GifLayout(
                        currentUserId: chatCtrl.user["id"],
                        isGroup: true,
                        isReceiver: true,
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
                      .alignment(Alignment.center),
                ).paddingOnly(bottom: Insets.i8)
            ]),
          ],
        ),
      );
    });
  }
}
