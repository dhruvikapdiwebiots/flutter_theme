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
      return Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("contacts")
                  .orderBy("updateStamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                      )).height(MediaQuery.of(context).size.height).expanded();
                } else {
                  List message = MessageFirebaseApi().chatListWidget(snapshot);
                  return !snapshot.hasData ? Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(appCtrl.appTheme.primary),
                      )).height(MediaQuery.of(context).size.height).expanded(): message.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return LoadUser(
                          document: message[index],
                          blockBy:messageCtrl.storageUser["id"],
                          currentUserId:
                          messageCtrl.storageUser["phone"]);
                    },
                    itemCount: message.length,
                  )
                      : Center(child: Image.asset(imageAssets.noChat)).height(MediaQuery.of(context).size.height).expanded();
                }
              }),
        ],
      );
    });
  }
}
