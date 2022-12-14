
import 'package:http/http.dart' as http;
import '../../../../../config.dart';

class GroupSenderMessage extends StatelessWidget {
  final DocumentSnapshot? document;
  final int? index;
  final String? currentUserId;

  const GroupSenderMessage({Key? key, this.document, this.index,this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {

      return Container(
          margin: const EdgeInsets.only(bottom: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[

              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                if (document!["type"] == MessageType.text.name)
                  // Text
                  GroupContent(
                    onLongPress: () {
                      showDialog(
                        context: Get.context!,
                        builder: (BuildContext context) =>
                            chatCtrl.buildPopupDialog(context, document!),
                      );
                    },
                    document: document
                  ),
                if (document!["type"] == MessageType.image.name)
                  GroupSenderImage(
                      document: document,
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
                  GroupVideoDoc(document: document),
                if (document!["type"] == MessageType.audio.name)
                  GroupAudioDoc(
                      document: document,
                      onLongPress: () {
                        showDialog(
                            context: Get.context!,
                            builder: (BuildContext context) =>
                                chatCtrl.buildPopupDialog(context, document!));
                      })
              ]),
            ],
          ));
    });
  }
}