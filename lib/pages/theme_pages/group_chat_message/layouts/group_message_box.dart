import 'dart:developer';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../config.dart';

class GroupMessageBox extends StatelessWidget {
  const GroupMessageBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return chatCtrl.user != null
          ? Flexible(
              child: chatCtrl.clearChatId.contains(chatCtrl.user["id"])
                  ? Container()
                  : chatCtrl.pId == null
                      ? Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  appCtrl.appTheme.primary)))
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(collectionName.groupMessage)
                              .doc(chatCtrl.pId)
                              .collection(collectionName.chat)
                              .orderBy('timestamp', descending: true)
                              .limit(chatCtrl.pageSize)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            } else {
                              chatCtrl.message = (snapshot.data!).docs;

                              return ListView.builder(
                                itemBuilder: (context, index){
                                  return chatCtrl.buildItem(
                                      index, (snapshot.data!).docs[index],snapshot.data!.docs[index].id).marginOnly(bottom: Insets.i18);
                                },
                                itemCount: (snapshot.data!).docs.length,
                                reverse: true,
                                controller: chatCtrl.listScrollController,
                              );
                            }
                          },
                        )

              )
          : Container();
    });
  }
}
