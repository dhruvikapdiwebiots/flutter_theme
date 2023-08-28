import 'package:flutter_theme/models/message_model.dart';

import '../../../../../config.dart';
import '../broad_cast_on_tap_class.dart';

class BroadcastSenderMessage extends StatefulWidget {
  final MessageModel? document;
  final int? index;
  final String? docId,title;

  const BroadcastSenderMessage(
      {Key? key, this.document, this.index, this.docId,this.title})
      : super(key: key);

  @override
  State<BroadcastSenderMessage> createState() => _BroadcastSenderMessage();
}

class _BroadcastSenderMessage extends State<BroadcastSenderMessage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return Stack(children: [
        Container(
            color: chatCtrl.selectedIndexId.contains(widget.docId)
                ? appCtrl.appTheme.primary.withOpacity(.08)
                : appCtrl.appTheme.transparentColor,
            margin: const EdgeInsets.only(bottom: 2.0),
            padding: const EdgeInsets.only(left: Insets.i10, right: Insets.i10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: <
                    Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                if (widget.document!.type == MessageType.text.name)
                  // Text
                  Content(
                    isBroadcast: true,
                      onTap: () => BroadcastOnTapFunctionCall()
                          .contentTap(chatCtrl, widget.docId),
                      onLongPress: () =>
                          chatCtrl.onLongPressFunction(widget.docId),
                      document: widget.document),
                if (widget.document!.type == MessageType.image.name)
                  SenderImage(
                    isBroadcast: true,
                    document: widget.document,
                    onPressed: () => BroadcastOnTapFunctionCall()
                        .imageTap(chatCtrl, widget.docId, widget.document),
                    onLongPress: () =>
                        chatCtrl.onLongPressFunction(widget.docId),
                  ),
                if (widget.document!.type == MessageType.contact.name)
                  ContactLayout(
                      isBroadcast: true,
                          onTap: () => BroadcastOnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId),
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          document: widget.document)
                      .paddingSymmetric(vertical: Insets.i8),
                if (widget.document!.type == MessageType.location.name)
                  LocationLayout(
                      isBroadcast: true,
                      document: widget.document,
                      onTap: () => BroadcastOnTapFunctionCall()
                          .locationTap(chatCtrl, widget.docId, widget.document),
                      onLongPress: () =>
                          chatCtrl.onLongPressFunction(widget.docId)),
                if (widget.document!.type == MessageType.video.name)
                  VideoDoc(
                      document: widget.document,
                      isBroadcast: true,
                      onTap: () => BroadcastOnTapFunctionCall()
                          .locationTap(chatCtrl, widget.docId, widget.document),
                      onLongPress: () =>
                          chatCtrl.onLongPressFunction(widget.docId)),
                if (widget.document!.type == MessageType.audio.name)
                  AudioDoc(
                      isBroadcast: true,
                      document: widget.document,
                      onTap: () => BroadcastOnTapFunctionCall()
                          .locationTap(chatCtrl, widget.docId, widget.document),
                      onLongPress: () =>
                          chatCtrl.onLongPressFunction(widget.docId)),
                if (widget.document!.type == MessageType.doc.name)
                  (widget.document!.content!.contains(".pdf"))
                      ? PdfLayout(
                          isBroadcast: true,
                          document: widget.document,
                          onTap: () => BroadcastOnTapFunctionCall()
                              .pdfTap(chatCtrl, widget.docId, widget.document),
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId))
                      : (widget.document!.content!.contains(".doc"))
                          ? DocxLayout(
                              isBroadcast: true,
                              document: widget.document,
                              onTap: () => BroadcastOnTapFunctionCall().docTap(
                                  chatCtrl, widget.docId, widget.document),
                              onLongPress: () =>
                                  chatCtrl.onLongPressFunction(widget.docId))
                          : (widget.document!.content!.contains(".xlsx"))
                              ? ExcelLayout(
                                  isBroadcast: true,
                                  onTap: () => BroadcastOnTapFunctionCall()
                                      .excelTap(chatCtrl, widget.docId,
                                          widget.document),
                                  onLongPress: () => chatCtrl
                                      .onLongPressFunction(widget.docId),
                                  document: widget.document,
                                )
                              : (widget.document!.content!.contains(".jpg") ||
                                      widget.document!.content!
                                          .contains(".png") ||
                                      widget.document!.content!
                                          .contains(".heic") ||
                                      widget.document!.content!
                                          .contains(".jpeg"))
                                  ? DocImageLayout(
                                      document: widget.document,
                                      onTap: () => BroadcastOnTapFunctionCall()
                                          .docImageTap(chatCtrl, widget.docId,
                                              widget.document),
                                      onLongPress: () => chatCtrl
                                          .onLongPressFunction(widget.docId))
                                  : Container(),
                if (widget.document!.type == MessageType.gif.name)
                  GifLayout(
                      onTap: () => BroadcastOnTapFunctionCall()
                          .contentTap(chatCtrl, widget.docId),
                      onLongPress: () =>
                          chatCtrl.onLongPressFunction(widget.docId),
                      document: widget.document)
              ]),
              if (widget.document!.type == MessageType.messageType.name)
                Align(
                        alignment: Alignment.center,
                        child: Text(decryptMessage(widget.document!.content))
                            .paddingSymmetric(
                                horizontal: Insets.i8, vertical: Insets.i10)
                            .decorated(
                                color: appCtrl.appTheme.primary.withOpacity(.2),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r8))
                            .alignment(Alignment.center))
                    .paddingOnly(bottom: Insets.i8)
            ])),
        if (chatCtrl.enableReactionPopup &&
            chatCtrl.selectedIndexId.contains(widget.docId))
          SizedBox(

              height: Sizes.s48,
              child: ReactionPopup(
                reactionPopupConfig: ReactionPopupConfiguration(
                    shadow:
                    BoxShadow(color: Colors.grey.shade400, blurRadius: 20)),
                onEmojiTap: (val) =>
                    OnTapFunctionCall()
                        .onEmojiSelectBroadcast(chatCtrl, widget.docId, val,widget.title),
                showPopUp: chatCtrl.showPopUp,
              ))
      ]);
    });
  }
}
