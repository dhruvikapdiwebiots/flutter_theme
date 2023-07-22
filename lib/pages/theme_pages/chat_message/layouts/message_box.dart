import 'dart:developer';

import 'package:collection/collection.dart';

import '../../../../config.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Flexible(
        child: chatCtrl.clearChatId.contains(chatCtrl.userData["id"])
            ? Container()
            : chatCtrl.chatId == null
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            appCtrl.appTheme.primary)))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(collectionName.users)
                        .doc(appCtrl.user["id"])
                        .collection(collectionName.messages)
                        .doc(chatCtrl.chatId)
                        .collection(collectionName.chat)
                        .orderBy('timestamp', descending: true)
                        .limit(20)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    appCtrl.appTheme.primary)));
                      } else {
                        log("CHATDATE : ${(snapshot.data!).docs.length}");
                        ChatMessageApi().getMessageAsPerDate(snapshot);
                        return ListView.builder(
                            itemBuilder: (context, index) {
                              log("DDDD : ${chatCtrl.chatId}");
                              return chatCtrl
                                  .timeLayout(
                                    chatCtrl.message[index],
                                  )
                                  .marginOnly(bottom: Insets.i18);
                            },
                            itemCount: chatCtrl.message.reversed.length,
                            reverse: true,
                            controller: chatCtrl.listScrollController);
                      }
                    },
                  ),
      );
    });
  }
}
