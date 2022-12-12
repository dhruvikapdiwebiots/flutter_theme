import 'package:intl/intl.dart';

import '../../../../config.dart';

class ReceiverMessage extends StatelessWidget {
  final DocumentSnapshot? document;
  final int? index;

  const ReceiverMessage({Key? key, this.index, this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // MESSAGE BOX FOR TEXT
                  if (document!["type"] == MessageType.text.name)
                    ReceiverContent( onLongPress: () {
                      showDialog(
                        context: Get.context!,
                        builder: (BuildContext context) =>
                            chatCtrl.buildPopupDialog(context, document!),
                      );
                    },
                      document: document,
                      isLastMessageRight: chatCtrl.isLastMessageRight(index!),),

                  // MESSAGE BOX FOR IMAGE
                  if (document!["type"] == MessageType.image.name)
                    ReceiverImage(image: document!['content']),

                  if (document!["type"] == MessageType.contact.name)
                    ContactLayout(
                        onLongPress: () {
                          showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                chatCtrl.buildPopupDialog(context, document!),
                          );
                        },
                        document: document),
                  if (document!["type"] == MessageType.location.name)
                    LocationLayout(
                        document: document,
                        onLongPress: () {
                          showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                chatCtrl.buildPopupDialog(context, document!),
                          );
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
                        })
                ],
              ),

              // STORE TIME ZONE FOR BACKAND DATABASE
              chatCtrl.isLastMessageLeft(index!)
                  ? Container(
                      margin: const EdgeInsets.only(
                          left: 10.0, top: 5.0, bottom: 5.0),
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document!['timestamp']))),
                        style: TextStyle(
                            color: appCtrl.appTheme.primary,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  : Container()
            ]),
      );
    });
  }
}
