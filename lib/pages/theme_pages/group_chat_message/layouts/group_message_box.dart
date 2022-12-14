import '../../../../config.dart';

class GroupMessageBox extends StatelessWidget {
  const GroupMessageBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return Flexible(
        child:
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  print("sna : ${snapshot.hasData}");
                  if (!snapshot.hasData) {
                    return Container();
                  } else {
                    chatCtrl.message = (snapshot.data!).docs;
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
