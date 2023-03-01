import 'dart:developer';

import '../../../../config.dart';

class ChatCard extends StatefulWidget {
  const ChatCard({Key? key}) : super(key: key);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final messageCtrl = Get.find<MessageController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (messageCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(messageCtrl.currentUserId)
              .collection(collectionName.chats)
              .orderBy("updateStamp", descending: true,).limit(15)
              .snapshots(),
          builder: (context, snapshot) {
            log("has : ${snapshot.hasData}");
            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
              )).height(MediaQuery.of(context).size.height);
            } else {
              List message = MessageFirebaseApi().chatListWidget(snapshot);
              log("message : ${message.length}");
              return !snapshot.hasData
                  ? Center(
                      child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          appCtrl.appTheme.primary),
                    )).height(MediaQuery.of(context).size.height).expanded()
                  : message.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: Insets.i20,horizontal: Insets.i10),
                          itemBuilder: (context, index) {
                            return LoadUser(
                                document: message[index],
                                blockBy: messageCtrl.storageUser["id"],
                                currentUserId: messageCtrl.storageUser["id"]);
                          },
                          itemCount: message.length,
                        )
                      : Center(
                          child: Image.asset(imageAssets.noChat,
                              height: Sizes.s250));
            }
          });
    });
  }
}
