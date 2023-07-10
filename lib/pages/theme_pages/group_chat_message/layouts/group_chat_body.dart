import '../../../../config.dart';

class GroupChatBody extends StatelessWidget {
  const GroupChatBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return chatCtrl.backgroundImage != null &&
              chatCtrl.backgroundImage != ""
          ? Column(children: <Widget>[
              // List of messages
              const GroupMessageBox(),
              // Sticker
              Container(),
              // Input content
              const GroupInputBox()
            ])
              .decorated(
                  color: appCtrl.appTheme.bgColor,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(chatCtrl.backgroundImage!)))
              .inkWell(onTap: () {
              chatCtrl.enableReactionPopup = false;
              chatCtrl.showPopUp = false;
              chatCtrl.update();
            })
          : Column(children: <Widget>[
              // List of messages
              const GroupMessageBox(),
              // Sticker
              Container(),
              // Input content
              const GroupInputBox()
            ]).inkWell(onTap: () {
              chatCtrl.enableReactionPopup = false;
              chatCtrl.showPopUp = false;
              chatCtrl.isChatSearch = false;
              chatCtrl.update();

            });
    });
  }
}
