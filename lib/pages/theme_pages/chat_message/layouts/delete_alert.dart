import 'dart:developer';

import '../../../../config.dart';

class DeleteAlert extends StatelessWidget {
  final DocumentSnapshot? documentReference;

  const DeleteAlert({Key? key, this.documentReference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
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
                    .collection('messages').doc(chatCtrl.chatId).collection("chat")
                    .doc(documentReference!.id)
                    .delete();
                await FirebaseFirestore.instance
                    .runTransaction((transaction) async {});
                chatCtrl.listScrollController.animateTo(0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);

                var snapList = FirebaseFirestore.instance
                    .collection('messages')
                    .doc(chatCtrl.chatId)
                    .collection("chat").snapshots();
                log("snapList : ${snapList.length}");

              await FirebaseFirestore.instance
                  .collection('messages')
                  .doc(chatCtrl.chatId)
                  .collection("chat")
                  .orderBy("timestamp", descending: true)
                  .limit(1)
                  .get()
                  .then((value) {
                if(value.docs.isEmpty){
                  FirebaseFirestore.instance
                      .collection("contacts")
                      .where("chatId", isEqualTo: chatCtrl.chatId)
                      .get()
                      .then((value) {
                    FirebaseFirestore.instance
                        .collection("contacts").doc(value.docs[0].id).delete();
                  });
                }else {
                  FirebaseFirestore.instance
                      .collection("contacts")
                      .where("chatId", isEqualTo: chatCtrl.chatId)
                      .get()
                      .then((snapShot) {
                    if (snapShot.docs.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('contacts')
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
