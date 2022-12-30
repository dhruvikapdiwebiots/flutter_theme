import '../../../../config.dart';

class GroupInputBox extends StatelessWidget {
  const GroupInputBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return Container(
        width: double.infinity,
        height: Sizes.s50,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: appCtrl.appTheme.darkGray, width: 0.5)),
            color: Colors.white),
        child: Row(children: <Widget>[
          const HSpace(Sizes.s15),
          Flexible(
            child: TextField(
              style: TextStyle(color: appCtrl.appTheme.primary, fontSize: 15.0),
              controller: chatCtrl.textEditingController,
              decoration: InputDecoration.collapsed(
                hintText: fonts.enterYourMessage.tr,
                hintStyle: TextStyle(color: appCtrl.appTheme.gray),
              ),
              focusNode: chatCtrl.focusNode,
              onChanged: (val) {
                chatCtrl.textEditingController.addListener(() {
                  if (chatCtrl.textEditingController.text.isNotEmpty) {
                    chatCtrl.typing = true;
                    firebaseCtrl.groupTypingStatus(
                        chatCtrl.pId, chatCtrl.documentId, true);
                  }
                  if (chatCtrl.textEditingController.text.isEmpty &&
                      chatCtrl.typing == true) {
                    chatCtrl.typing = false;
                    firebaseCtrl.groupTypingStatus(
                        chatCtrl.pId, chatCtrl.documentId, false);
                  }
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attachment_outlined),
            onPressed: () {
              chatCtrl.shareMedia(context);
            },
            color: appCtrl.appTheme.primary,
          ),
          Material(
              color: Colors.white,
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Insets.i8),
                  child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => chatCtrl.onSendMessage(
                          chatCtrl.textEditingController.text,
                          MessageType.text),
                      color: appCtrl.appTheme.primary)))
        ]),
      );
    });
  }
}
