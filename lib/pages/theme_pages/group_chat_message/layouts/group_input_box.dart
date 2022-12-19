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
        child: Row(
          children: <Widget>[
            const HSpace(Sizes.s15),
            Flexible(
              child: TextField(
                style:
                    TextStyle(color: appCtrl.appTheme.primary, fontSize: 15.0),
                controller: chatCtrl.textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Enter your message',
                  hintStyle: TextStyle(color: appCtrl.appTheme.gray),
                ),
                focusNode: chatCtrl.focusNode,
                onChanged: (val) {
                  chatCtrl.textEditingController.addListener(() {
                    if (chatCtrl.textEditingController.text.isNotEmpty) {

                      chatCtrl.typing = true;
                      appCtrl.firebaseCtrl.groupTypingStatus(chatCtrl.pId,chatCtrl.documentId,chatCtrl.typing);
                    }
                    if (chatCtrl.textEditingController.text.isEmpty && chatCtrl.typing == true) {
                      chatCtrl.typing = false;
                      appCtrl.firebaseCtrl.groupTypingStatus(chatCtrl.pId,chatCtrl.documentId,chatCtrl.typing);
                    }

                  });

                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.attachment_outlined),
              padding: const EdgeInsets.all(0.0),
              onPressed: () {
                chatCtrl.shareMedia(context);
              },
              color: appCtrl.appTheme.primary,
            ),
            Material(
              color: Colors.white,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => chatCtrl.onSendMessage(
                      chatCtrl.textEditingController.text, MessageType.text),
                  color: appCtrl.appTheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
