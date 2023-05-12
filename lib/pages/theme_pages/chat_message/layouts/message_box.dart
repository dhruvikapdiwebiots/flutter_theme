import 'package:flutter_theme/widgets/reaction_pop_up/reaction_config.dart';
import 'package:flutter_theme/widgets/reaction_pop_up/reaction_pop_up.dart';

import '../../../../config.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Flexible(
        child: chatCtrl.chatId == null
            ? Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        appCtrl.appTheme.primary)))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
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
                    chatCtrl.message = (snapshot.data!);
                    return ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemBuilder: (context, index){
                          return chatCtrl.buildItem(
                              index, (snapshot.data!).docs[index],snapshot.data!.docs[index].id);
                        },
                        itemCount: (snapshot.data!).docs.length,
                        reverse: true,
                        controller: chatCtrl.listScrollController);
                  }
                },
              ),
      );
    });
  }
}
