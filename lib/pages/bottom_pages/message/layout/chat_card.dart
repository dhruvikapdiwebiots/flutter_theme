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
      return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
        return StreamBuilder(
            stream: dashboardCtrl.userText.text.isNotEmpty && dashboardCtrl.selectedIndex ==0
                ? dashboardCtrl.onSearch(dashboardCtrl.userText.text)
                : FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(messageCtrl.currentUserId)
                    .collection(collectionName.chats)
                    .orderBy("updateStamp", descending: true)
                    .limit(15)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return dashboardCtrl.userText.text.isNotEmpty ?Center(
                  child: Text("NO RESULT FOUND" ,style: AppCss.poppinsSemiBold16.textColor(appCtrl.appTheme.blackColor),),
                ) : CommonEmptyLayout(
                    gif: gifAssets.message,
                    title: fonts.emptyMessageTitle.tr,
                    desc: fonts.emptyMessageDesc.tr);
              } else if (!snapshot.hasData) {
                return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                appCtrl.appTheme.primary)))
                    .height(MediaQuery.of(context).size.height);
              } else {
                List message = MessageFirebaseApi().chatListWidget(snapshot);

                return !snapshot.hasData
                    ? Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    appCtrl.appTheme.primary)))
                        .height(MediaQuery.of(context).size.height)
                        .expanded()
                    : message.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                                vertical: Insets.i20, horizontal: Insets.i10),
                            itemBuilder: (context, index) {
                              return LoadUser(
                                  document: message[index],
                                  blockBy: messageCtrl.storageUser["id"],
                                  currentUserId: messageCtrl.storageUser["id"]);
                            },
                            itemCount: message.length,
                          )
                        : dashboardCtrl.userText.text.isNotEmpty ?Center(
                  child: Text("NO RESULT FOUND" ,style: AppCss.poppinsSemiBold16.textColor(appCtrl.appTheme.blackColor),),
                ) : CommonEmptyLayout(
                            gif: gifAssets.message,
                            title: fonts.emptyMessageTitle.tr,
                            desc: fonts.emptyMessageDesc.tr);
              }
            });
      });
    });
  }
}
