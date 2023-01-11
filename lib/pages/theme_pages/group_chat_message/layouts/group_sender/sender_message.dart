import 'package:flutter_theme/widgets/pdf_viewer_layout.dart';
import 'package:intl/intl.dart';
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
                  GroupVideoDoc(document: widget.document,onLongPress: () {
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
                      ? Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          SfPdfViewer.network(
                            widget.document!['content'].split("-BREAK-")[1],
                            key: _pdfViewerKey,
                          ).width(220).clipRRect(all: AppRadius.r8),
                          Text(
                            widget.document!['content'].split("-BREAK-")[0],
                            textAlign: TextAlign.center,
                            style: AppCss.poppinsMedium12
                                .textColor(appCtrl.appTheme.whiteColor),
                          )
                              .width(220)
                              .paddingSymmetric(
                              horizontal: Insets.i10,
                              vertical: Insets.i15)
                              .decorated(
                              color:appCtrl.isTheme ?appCtrl.appTheme.white :  appCtrl.appTheme.primary
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
                              .inkWell(onTap: () {}),
                          Text(
                            DateFormat('HH:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(
                                        widget.document!['timestamp']))),
                            style: AppCss.poppinsMedium12
                                .textColor(appCtrl.appTheme.whiteColor),
                          ).marginAll(Insets.i10),
                        ],
                      )
                    ],
                  ).marginSymmetric(
                      horizontal: Insets.i10, vertical: Insets.i5)
                      : (widget.document!["content"].contains(".docx"))
                      ? Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: Insets.i8),
                        padding: const EdgeInsets.only(
                          bottom: Insets.i15,
                        ),
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(AppRadius.r8),
                            color: appCtrl.appTheme.primary),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: Insets.i8,
                                    vertical: Insets.i5),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Insets.i15,
                                    vertical: Insets.i15),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.r8),
                                    color: appCtrl.appTheme.whiteColor
                                        .withOpacity(.1)),
                                child: Text(
                                  widget.document!['content']
                                      .split("-BREAK-")[0],
                                  textAlign: TextAlign.center,
                                  style: AppCss.poppinsMedium12
                                      .textColor(
                                      appCtrl.appTheme.whiteColor),
                                )),
                            const VSpace(Sizes.s8),
                            Text(
                              DateFormat('HH:mm a').format(DateTime
                                  .fromMillisecondsSinceEpoch(int.parse(
                                  widget.document!['timestamp']))),
                              style: AppCss.poppinsMedium12.textColor(
                                  appCtrl.appTheme.whiteColor),
                            ).marginSymmetric(horizontal: Insets.i10)
                          ],
                        ),
                      )
                    ],
                  ).inkWell(onTap: () {
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
          ));
    });
  }
}
