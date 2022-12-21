

import '../../../../config.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({Key? key}) : super(key: key);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {

  final messageCtrl = Get.find<MessageController>();

  List chatListWidget(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
    List message =[];

    for (int j = 0; j < messageCtrl.contactUserList.length; j++) {
      if (messageCtrl.contactUserList[j].phones!.isNotEmpty) {

        String phone =
        phoneNumberExtension(messageCtrl.contactUserList[j].phones![0].value.toString());
        for (int a = 0; a < snapshot.data!.docs.length; a++) {

          if (snapshot.data!.docs[a].data()["isGroup"] == false) {
            if (snapshot.data!.docs[a].data()["senderPhone"] ==
                messageCtrl.storageUser["phone"] ||
                snapshot.data!.docs[a].data()["receiverPhone"] ==
                    phone &&
                    snapshot.data!.docs[a].data()["senderPhone"] ==
                        phone ||
                snapshot.data!.docs[a].data()["receiverPhone"] ==
                    messageCtrl.storageUser["phone"]) {
              message.add(snapshot.data!.docs[a]);
            }
          } else {
            if (snapshot.data!.docs[a].data()["senderPhone"] ==
                messageCtrl.storageUser["phone"]) {
              message.add(snapshot.data!.docs[a]);
            } else {
              List groupReceiver =
              snapshot.data!.docs[a].data()["receiver"];
              if (groupReceiver
                  .where((element) => element["phone"] == phone)
                  .isNotEmpty) {
                message.add(snapshot.data!.docs[a]);
              }
            }
          }
        }
        return message;
      }
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<MessageController>(builder: (messageCtrl) {
      return Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection("contacts").orderBy("updateStamp",descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                  ));
                } else {
                  List message = chatListWidget(snapshot);
                  return message.isNotEmpty ? ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return LoadUser(
                          document: message[index],
                          currentUserId: messageCtrl.storageUser["phone"]);
                    },
                    itemCount: message.length,
                  ): Container();

                }
              }),
        ],
      );
    });
  }
}
