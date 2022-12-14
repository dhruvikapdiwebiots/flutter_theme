import '../../../../../config.dart';

class BroadcastSender extends StatelessWidget {
  final dynamic document;
  final int? index;

  const BroadcastSender({Key? key, this.document, this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return Container(
          margin: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                if (document!["type"] == MessageType.text.name)
                  // Text
                  Content(
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) =>
                              chatCtrl.buildPopupDialog(context, document!),
                        );
                      },
                      document: document,
                      isBroadcast: true),
                if (document!["type"] == MessageType.image.name)
                  SenderImage(
                      document: document,
                      onLongPress: () {
                        showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                chatCtrl.buildPopupDialog(context, document!));
                      }),
                if (document!["type"] == MessageType.contact.name)
                  ContactLayout(
                      onLongPress: () {
                        showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                chatCtrl.buildPopupDialog(context, document!));
                      },
                      document: document),
                if (document!["type"] == MessageType.location.name)
                  LocationLayout(
                      document: document,
                      onLongPress: () {
                        showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                chatCtrl.buildPopupDialog(context, document!));
                      },
                      onTap: () {
                        launchUrl(Uri.parse(document!["content"]));
                      }),
                if (document!["type"] == MessageType.video.name)
                  VideoDoc(document: document),
                if (document!["type"] == MessageType.audio.name)
                  AudioDoc(
                      document: document,
                      onLongPress: () {
                        showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                chatCtrl.buildPopupDialog(context, document!));
                      }),
                if (document!["type"] == MessageType.doc.name)
                  (document!["content"].contains(".pdf"))
                      ? PdfLayout(
                          document: document,
                          pdfViewerKey: chatCtrl.pdfViewerKey,
                          onLongPress: () {
                            showDialog(
                                context: Get.context!,
                                builder: (BuildContext context) => chatCtrl
                                    .buildPopupDialog(context, document!));
                          })
                      : (document!["content"].contains(".docx"))
                          ? DocxLayout(
                              document: document,
                              onLongPress: () {
                                showDialog(
                                    context: Get.context!,
                                    builder: (BuildContext context) => chatCtrl
                                        .buildPopupDialog(context, document!));
                              })
                          : Container(),
              ]),
              if (document!["type"] == MessageType.messageType.name)
                Align(
                  alignment: Alignment.center,
                  child: Text(document!["content"])
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
