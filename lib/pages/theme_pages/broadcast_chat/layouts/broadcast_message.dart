
import 'dart:developer';

import '../../../../config.dart';

class BroadcastMessage extends StatelessWidget {
  const BroadcastMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return Flexible(
        child:  StreamBuilder<QuerySnapshot>(
          stream:  FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(appCtrl.user["id"])
            .collection(collectionName.broadcastMessage)
            .doc(chatCtrl.pId)
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
              log("SNAP : ${snapshot.data!.docs.length}");
              ChatMessageApi().getBroadcastMessageAsPerDate(snapshot);
              return chatCtrl.message != null ? ListView.builder(
                itemBuilder: (context, index) => chatCtrl.timeLayout(
                chatCtrl.message[index],
              ),
                itemCount: chatCtrl.message.length,
                reverse: true,
                controller: chatCtrl.listScrollController,
              ) : Container();
            }
          },
        ),
      );
    });
  }
}
