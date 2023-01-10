import 'dart:developer';

import '../../../../config.dart';

class BroadCastDeleteAlert extends StatelessWidget {
  final DocumentSnapshot? documentReference;

  const BroadCastDeleteAlert({Key? key, this.documentReference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return AlertDialog(
        backgroundColor: appCtrl.appTheme.whiteColor,
        title: const Text('Alert!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text("Are you sure you want to delete this message?"),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
               Get.back();
                FirebaseFirestore.instance
                    .collection('broadcastMessage').doc(chatCtrl.pId).collection("chat")
                    .doc(documentReference!.id)
                    .delete();
                await FirebaseFirestore.instance
                    .runTransaction((transaction) async {});
                chatCtrl.listScrollController.animateTo(0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);

              await FirebaseFirestore.instance
                  .collection('broadcastMessage')
                  .doc(chatCtrl.pId)
                  .collection("chats")
                  .orderBy("timestamp", descending: true)
                  .limit(1)
                  .get()
                  .then((value) {
                if(value.docs.isEmpty){
                  FirebaseFirestore.instance
                      .collection("users").doc(chatCtrl.userData["id"]).collection("chats")
                      .where("chatId", isEqualTo: chatCtrl.chatId)
                      .get()
                      .then((value) {
                    FirebaseFirestore.instance
                        .collection("contacts").doc(value.docs[0].id).delete();
                  });
                }else {
                  FirebaseFirestore.instance
                      .collection("users").doc(chatCtrl.userData["id"]).collection("chats")
                      .where("chatId", isEqualTo: chatCtrl.chatId)
                      .get()
                      .then((snapShot) {
                    if (snapShot.docs.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection("users").doc(chatCtrl.userData["id"]).collection("chats")
                          .doc(snapShot.docs[0].id)
                          .update({
                        "updateStamp":
                        DateTime
                            .now()
                            .millisecondsSinceEpoch
                            .toString(),
                        "lastMessage": value.docs[0].data()["content"],
                        "senderId": value.docs[0].data()["senderId"],
                        'sender': {
                          "id": value.docs[0].data()["sender"]['id'],
                          "name": value.docs[0].data()["sender"]['name'],
                          "image": value.docs[0].data()["sender"]["image"]
                        },
                        "receiverId": value.docs[0].data()["receiverId"],
                        "receiver": {
                          "id": value.docs[0].data()["receiver"]["id"],
                          "name": value.docs[0].data()["receiver"]["name"],
                          "image": value.docs[0].data()["receiver"]["image"]
                        }
                      });
                    }
                  });
                }
              });
            },
            child: const Text('Yes'),
          ),
        ],
      );
    });
  }
}
