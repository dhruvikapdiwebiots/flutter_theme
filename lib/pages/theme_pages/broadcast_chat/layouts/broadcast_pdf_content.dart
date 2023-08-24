import 'package:flutter_theme/models/message_model.dart';

import '../../../../config.dart';

class PdfContentLayout extends StatelessWidget {
  final MessageModel? document;
  final bool isReceiver, isGroup, isBroadcast;
  final String? currentUserId;
  final PDFDocument? doc;

  const PdfContentLayout(
      {Key? key,
      this.document,
      this.isReceiver = false,
      this.isGroup = false,
      this.isBroadcast = false,
      this.currentUserId,
      this.doc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(Insets.i15),
        width: Sizes.s210,
        alignment: Alignment.center,
        decoration: BroadcastClass().broadcastDecoration(isReceiver),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isGroup)
                if (isReceiver)
                  if (currentUserId != null)
                    if (document!.sender != currentUserId)
                      Align(
                          alignment: Alignment.topLeft,
                          child: Column(children: [
                            Text(document!.senderName!,
                                style: AppCss.poppinsMedium12
                                    .textColor(appCtrl.appTheme.primary)),
                            const VSpace(Sizes.s8)
                          ])),
              Row(children: [
                SvgPicture.asset(svgAssets.pdf, height: Sizes.s20)
                    .paddingSymmetric(
                        horizontal: Insets.i10, vertical: Insets.i8)
                    .decorated(
                        color: appCtrl.appTheme.white,
                        borderRadius: BorderRadius.circular(AppRadius.r8)),
                const HSpace(Sizes.s10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          decryptMessage(document!.content),
                          textAlign: TextAlign.start,
                          style: AppCss.poppinsMedium12
                              .textColor(isReceiver
                                  ? appCtrl.appTheme.lightBlackColor
                                  : appCtrl.appTheme.white)
                              .textHeight(1.2)),
                      const VSpace(Sizes.s5),
                      if (doc != null)
                        Row(children: [
                          Text("${doc!.count.toString()} Page | PDF",
                              style: AppCss.poppinsMedium12.textColor(isReceiver
                                  ? appCtrl.appTheme.txtColor
                                  : appCtrl.appTheme.white))
                        ])
                    ]))
              ])
            ]));
  }
}
