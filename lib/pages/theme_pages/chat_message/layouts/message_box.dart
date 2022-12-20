import 'package:flutter_theme/models/message_model.dart';

import '../../../../config.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
print("objectId : ${chatCtrl.chatId}");
      return Flexible(
        child: chatCtrl.chatId == null
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        appCtrl.appTheme.primary)))
            : StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .doc(chatCtrl.chatId)
              .collection("chat")
              .orderBy('timestamp', descending: true)
              .limit(20).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          appCtrl.appTheme.primary)));
            } else {
              chatCtrl.message = (snapshot.data!);
              return ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemBuilder: (context, index) => chatCtrl.buildItem(
                    index, (snapshot.data!).docs[index]),
                itemCount: (snapshot.data!).docs.length,
                reverse: true,
                controller: chatCtrl.listScrollController,
              );
            }
          },
        ),
      );
    });
  }
}
