
import '../../../../../config.dart';

class ReceiverMessage extends StatefulWidget {
  final dynamic document;
  final int? index;
  final String? docId;

  const ReceiverMessage({Key? key, this.index, this.document, this.docId})
      : super(key: key);

  @override
  State<ReceiverMessage> createState() => _ReceiverMessageState();
}

class _ReceiverMessageState extends State<ReceiverMessage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Stack(children: [
        Container(
            color: chatCtrl.selectedIndexId.contains(widget.docId)
                ? appCtrl.appTheme.lightGray
                : appCtrl.appTheme.bgColor,
            margin: const EdgeInsets.only(bottom: Insets.i10),
            padding: const EdgeInsets.only(
                bottom: Insets.i10, left: Insets.i20, right: Insets.i20),
            child: Row(children: [
              ReceiverChatImage(id: chatCtrl.pId),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
                Row(
                  children: <Widget>[
                    // MESSAGE BOX FOR TEXT
                    if (widget.document!["type"] == MessageType.text.name)
                      ReceiverContent(
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          document: widget.document,
                          onTap: () => OnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId)),

                    // MESSAGE BOX FOR IMAGE
                    if (widget.document!["type"] == MessageType.image.name)
                      ReceiverImage(
                          onTap: () => OnTapFunctionCall().imageTap(
                              chatCtrl, widget.docId, widget.document),
                          document: widget.document,
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId)),

                    if (widget.document!["type"] == MessageType.contact.name)
                      ContactLayout(
                          isReceiver: true,
                          onTap: () => OnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId),
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          document: widget.document),
                    if (widget.document!["type"] == MessageType.location.name)
                      LocationLayout(
                          isReceiver: true,
                          document: widget.document,
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          onTap: () => OnTapFunctionCall().locationTap(
                              chatCtrl, widget.docId, widget.document)),
                    if (widget.document!["type"] == MessageType.video.name)
                      VideoDoc(
                          document: widget.document,
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          isReceiver: true,
                          onTap: () => OnTapFunctionCall().locationTap(
                              chatCtrl, widget.docId, widget.document)),
                    if (widget.document!["type"] == MessageType.audio.name)
                      AudioDoc(
                          isReceiver: true,
                          document: widget.document,
                          onTap: () => OnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId),
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId)),
                    if (widget.document!["type"] == MessageType.doc.name)
                      (widget.document!["content"].contains(".pdf"))
                          ? PdfLayout(
                              isReceiver: true,
                              document: widget.document,
                              onTap: () => OnTapFunctionCall().pdfTap(
                                  chatCtrl, widget.docId, widget.document),
                              onLongPress: () =>
                                  chatCtrl.onLongPressFunction(widget.docId))
                          : (widget.document!["content"].contains(".doc"))
                              ? DocxLayout(
                                  isReceiver: true,
                                  document: widget.document,
                                  onTap: () => OnTapFunctionCall().docTap(
                                      chatCtrl, widget.docId, widget.document),
                                  onLongPress: () => chatCtrl
                                      .onLongPressFunction(widget.docId))
                              : (widget.document!["content"].contains(".xlsx"))
                                  ? ExcelLayout(
                                      isReceiver: true,
                                      onTap: () => OnTapFunctionCall().excelTap(
                                          chatCtrl,
                                          widget.docId,
                                          widget.document),
                                      onLongPress: () => chatCtrl
                                          .onLongPressFunction(widget.docId),
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
                                          isReceiver: true,
                                          onTap: () => OnTapFunctionCall()
                                              .docImageTap(
                                                  chatCtrl,
                                                  widget.docId,
                                                  widget.document),
                                          document: widget.document,
                                          onLongPress: () => chatCtrl
                                              .onLongPressFunction(widget.docId))
                                      : Container(),
                    if (widget.document!["type"] == MessageType.gif.name)
                      GifLayout(
                          onTap: () => OnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId),
                          document: widget.document,
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId))
                  ],
                ),
                if (widget.document!["type"] == MessageType.messageType.name)
                  Align(
                          alignment: Alignment.center,
                          child: Text(widget.document!["content"])
                              .paddingSymmetric(
                                  horizontal: Insets.i8, vertical: Insets.i10)
                              .decorated(
                                  color:
                                      appCtrl.appTheme.primary.withOpacity(.2),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r8))
                              .alignment(Alignment.center))
                      .paddingOnly(bottom: Insets.i8)
              ])
            ])),
        if (chatCtrl.enableReactionPopup &&
            chatCtrl.selectedIndexId.contains(widget.docId))
          SizedBox(
              width: MediaQuery.of(Get.context!).size.width,
              height: Sizes.s35,
              child: ReactionPopup(
                reactionPopupConfig: ReactionPopupConfiguration(
                    shadow:
                        BoxShadow(color: Colors.grey.shade400, blurRadius: 20)),
                onEmojiTap: (val) => OnTapFunctionCall()
                    .onEmojiSelect(chatCtrl, widget.docId, val),
                showPopUp: chatCtrl.showPopUp,
              ))
      ]);
    });
  }
}
