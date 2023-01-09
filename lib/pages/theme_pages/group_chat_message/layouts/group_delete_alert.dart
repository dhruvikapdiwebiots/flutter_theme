import '../../../../config.dart';

class GroupDeleteAlert extends StatelessWidget {
  final DocumentSnapshot? documentReference;

  const GroupDeleteAlert({Key? key, this.documentReference}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return AlertDialog(
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
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();

              FirebaseFirestore.instance
                  .collection('groupMessage')
                  .doc(chatCtrl.pId)
                  .collection("chat")
                  .doc(documentReference!.id)
                  .delete();
              await FirebaseFirestore.instance
                  .runTransaction((transaction) async {});
              chatCtrl.listScrollController.animateTo(0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut);

              await FirebaseFirestore.instance
                  .collection('groupMessage')
                  .doc(chatCtrl.pId)
                  .collection("chat")
                  .orderBy("timestamp", descending: true)
                  .limit(1)
                  .get()
                  .then((value) {
                if (value.docs.isEmpty) {
                  List receiver = value.docs[0].data()["receiver"];
                  receiver.asMap().entries.forEach((element) async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(element.value['id'])
                        .delete();
                  });
                } else {
                  List receiver = value.docs[0].data()["receiver"];
                  receiver.asMap().entries.forEach((element) async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(element.value["id"])
                        .collection("chats")
                        .where("groupId")
                        .get()
                        .then((contact) {
                      if (contact.docs.isNotEmpty) {
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(element.value["id"])
                            .collection("chats")
                            .doc(contact.docs[0].id)
                            .update({
                          "updateStamp":
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          "lastMessage": value.docs[0].data()["content"],
                          "senderId": chatCtrl.user["id"],
                          "sender": chatCtrl.user
                        });
                      }
                    });
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
