import '../../../../config.dart';

class GroupMessageBox extends StatelessWidget {
  const GroupMessageBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return Flexible(
        child:
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(collectionName.groupMessage)
                    .doc(chatCtrl.pId)
                    .collection(collectionName.chat)
                    .orderBy('timestamp',descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    chatCtrl.message = (snapshot.data!).docs;
                    return  ListView.builder(

                      itemBuilder: (context, index) => chatCtrl.buildItem(
                          index, (snapshot.data!).docs[index],(snapshot.data!).docs[index].id).marginOnly(bottom: Insets.i18),
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
