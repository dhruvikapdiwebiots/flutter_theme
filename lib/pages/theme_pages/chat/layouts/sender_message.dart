
import 'package:intl/intl.dart';

import '../../../../config.dart';

class SenderMessage extends StatelessWidget {
  final DocumentSnapshot? document;
  final int? index;

  const SenderMessage({Key? key, this.document, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Container(
          margin: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  document!['type'] == 0
                      // Text
                      ? Content(
                          onLongPress: () {
                            showDialog(
                              context: Get.context!,
                              builder: (BuildContext context) =>
                                  chatCtrl.buildPopupDialog(context, document!),
                            );
                          },
                          document: document,
                          isLastMessageRight:
                              chatCtrl.isLastMessageRight(index!),
                        )
                      : SenderImage(url: document!['content'])
                ],
              ),
              // STORE TIME ZONE FOR BACKAND DATABASE
              chatCtrl.isLastMessageRight(index!)
                  ? Container(
                      margin: const EdgeInsets.only(
                          right: 10.0, top: 5.0, bottom: 5.0),
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document!['timestamp']))),
                        style: AppCss.poppinsMedium12
                            .style(FontStyle.italic)
                            .textColor(appCtrl.appTheme.primary),
                      ))
                  : Container()
            ],
          ));
    });
  }
}
