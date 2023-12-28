
import 'package:flutter_theme/models/message_model.dart';

import '../../../../../config.dart';

class ReceiverMessage extends StatefulWidget {
  final MessageModel? document;
  final int? index;
  final String? docId,title;

  const ReceiverMessage({Key? key, this.index, this.document, this.docId,this.title})
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
            ? appCtrl.appTheme.primary.withOpacity(.08)
            : appCtrl.appTheme.transparentColor,
            margin: const EdgeInsets.only(bottom: Insets.i10),
            padding:  EdgeInsets.only(
                bottom: Insets.i10, left: Insets.i20, right: Insets.i20,top: chatCtrl.selectedIndexId.contains(widget.docId) ? Insets
                .i10 : 0),
            child: Row(children: [
              CachedNetworkImage(
                  imageUrl: chatCtrl.userContactModel!.image!,
                  imageBuilder: (context, imageProvider) => Container(
                    height: Sizes.s35,
                    width: Sizes.s35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(

                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill, image: imageProvider)),
                  ),
                  placeholder: (context, url) => Container(
                    height: Sizes.s35,
                    width: Sizes.s35,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0xff3282B8),
                        shape: BoxShape.circle),
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: Sizes.s35,
                    width: Sizes.s35,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Color(0xff3282B8),
                        shape: BoxShape.circle),
                    child: Text(
                      chatCtrl.pName!.length > 2
                          ? chatCtrl.pName!
                          .replaceAll(" ", "")
                          .substring(0, 2)
                          .toUpperCase()
                          : chatCtrl.pName![0],
                      style:
                      AppCss.poppinsblack16.textColor(appCtrl.appTheme.white),
                    ),
                  )),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
                Row(
                  children: <Widget>[
                    // MESSAGE BOX FOR TEXT
                    if (widget.document!.type! == MessageType.text.name)
                      ReceiverContent(
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          document: widget.document,
                          onTap: () => OnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId)),

                    // MESSAGE BOX FOR IMAGE
                    if (widget.document!.type! == MessageType.image.name)
                      ReceiverImage(
                          onTap: () => OnTapFunctionCall().imageTap(
                              chatCtrl, widget.docId, widget.document!),
                          document: widget.document,
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId)),

                    if (widget.document!.type! == MessageType.contact.name)
                      ContactLayout(
                          isReceiver: true,
                          onTap: () => OnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId),
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          document: widget.document),
                    if (widget.document!.type! == MessageType.location.name)
                      LocationLayout(
                          isReceiver: true,
                          document: widget.document,
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          onTap: () => OnTapFunctionCall().locationTap(
                              chatCtrl, widget.docId, widget.document)),
                    if (widget.document!.type! == MessageType.video.name)
                      VideoDoc(
                          document: widget.document,
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId),
                          isReceiver: true,
                          onTap: () => OnTapFunctionCall().locationTap(
                              chatCtrl, widget.docId, widget.document)),
                    if (widget.document!.type! == MessageType.audio.name)
                      AudioDoc(
                          isReceiver: true,
                          document: widget.document,
                          onTap: () => OnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId),
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId)),
                    if (widget.document!.type! == MessageType.doc.name)
                      (decryptMessage(widget.document!.content).contains(".pdf"))
                          ? PdfLayout(
                              isReceiver: true,
                              document: widget.document,
                              onTap: () => OnTapFunctionCall().pdfTap(
                                  chatCtrl, widget.docId, widget.document!),
                              onLongPress: () =>
                                  chatCtrl.onLongPressFunction(widget.docId))
                          : (decryptMessage(widget.document!.content).contains(".doc"))
                              ? DocxLayout(
                                  isReceiver: true,
                                  document: widget.document,
                                  onTap: () => OnTapFunctionCall().docTap(
                                      chatCtrl, widget.docId, widget.document!),
                                  onLongPress: () => chatCtrl
                                      .onLongPressFunction(widget.docId))
                              : (decryptMessage(widget.document!.content).contains(".xlsx"))
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
                                  : (decryptMessage(widget.document!.content)
                                              .contains(".jpg") ||
                                          decryptMessage(widget.document!.content)
                                              .contains(".png") ||
                                          decryptMessage(widget.document!.content)
                                              .contains(".heic") ||
                                          decryptMessage(widget.document!.content)
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
                    if (widget.document!.type! == MessageType.gif.name)
                      GifLayout(
                          onTap: () => OnTapFunctionCall()
                              .contentTap(chatCtrl, widget.docId),
                          document: widget.document,
                          onLongPress: () =>
                              chatCtrl.onLongPressFunction(widget.docId))
                  ],
                ),
                if (widget.document!.type! == MessageType.messageType.name)
                  Align(
                          alignment: Alignment.center,
                          child: Text(decryptMessage(widget.document!.content))
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
              height: Sizes.s48,
              child: ReactionPopup(
                reactionPopupConfig: ReactionPopupConfiguration(
                    shadow:
                        BoxShadow(color: Colors.grey.shade400, blurRadius: 20)),
                onEmojiTap: (val) => OnTapFunctionCall()
                    .onEmojiSelect(chatCtrl, widget.docId, val,widget.title),
                showPopUp: chatCtrl.showPopUp,
              ))
      ]);
    });
  }
}
