import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_contact_layout.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_location_layout.dart';

import '../../../../../config.dart';

class GroupReceiverMessage extends StatelessWidget {
  final DocumentSnapshot? document;
  final int? index;

  const GroupReceiverMessage({Key? key, this.index, this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          Row(
            children: <Widget>[
              // MESSAGE BOX FOR TEXT
              if (document!["type"] == MessageType.text.name)
                GroupReceiverContent(
                    onLongPress: () {
                      showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) =>
                              chatCtrl.buildPopupDialog(context, document!));
                    },
                    document: document),

              // MESSAGE BOX FOR IMAGE
              if (document!["type"] == MessageType.image.name)
                GroupReceiverImage(document: document),

              if (document!["type"] == MessageType.contact.name)
                GroupContactLayout(
                    currentUserId: chatCtrl.id,
                    onLongPress: () {
                      showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) =>
                              chatCtrl.buildPopupDialog(context, document!));
                    },
                    document: document),
              if (document!["type"] == MessageType.location.name)
                GroupLocationLayout(
                    document: document,
                    currentUserId: chatCtrl.id,
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
                GroupVideoDoc(
                  document: document,
                  onLongPress: () {
                    showDialog(
                        context: Get.context!,
                        builder: (BuildContext context) =>
                            chatCtrl.buildPopupDialog(context, document!));
                  },
                ),
              if (document!["type"] == MessageType.audio.name)
                GroupAudioDoc(
                    document: document,
                    onLongPress: () {
                      showDialog(
                          context: Get.context!,
                          builder: (BuildContext context) =>
                              chatCtrl.buildPopupDialog(context, document!));
                    }),
              if (document!["type"] == MessageType.messageType.name)
                Align(
                  alignment: Alignment.center,
                  child: Text(document!["content"])
                      .paddingSymmetric(
                      horizontal: Insets.i8, vertical: Insets.i10)
                      .decorated(
                      color: appCtrl.appTheme.primary.withOpacity(.2),
                      borderRadius: BorderRadius.circular(AppRadius.r8)).alignment(Alignment.center),
                ).paddingOnly(bottom: Insets.i8)
            ],
          ),
        ]),
      );
    });
  }
}
