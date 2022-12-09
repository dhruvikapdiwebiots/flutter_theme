import 'package:http/http.dart' as http;
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
                    isLastMessageRight: chatCtrl.isLastMessageRight(index!),
                  ),
                if (document!["type"] == MessageType.image.name)
                  SenderImage(
                      url: document!['content'],
                      onLongPress: () {
                        showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) =>
                              chatCtrl.buildPopupDialog(context, document!),
                        );
                      }),
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
                  LocationLayout(onLongPress: () {
                    launchUrl(Uri.parse(document!["content"]));
                  }, onTap: () {
                    showDialog(
                      context: Get.context!,
                      builder: (BuildContext context) =>
                          chatCtrl.buildPopupDialog(context, document!),
                    );
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
              ]),
              // STORE TIME ZONE FOR BACKAND DATABASE
              chatCtrl.isLastMessageRight(index!)
                  ? LastSeen(
                      document: document,
                    )
                  : Container()
            ],
          ));
    });
  }
}
