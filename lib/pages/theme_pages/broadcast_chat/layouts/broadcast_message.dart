
import '../../../../config.dart';

class BroadcastMessage extends StatelessWidget {
  const BroadcastMessage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return Flexible(
        child:  StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(collectionName.broadcastMessage)
              .doc(chatCtrl.pId)
              .collection(collectionName.chat)
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
