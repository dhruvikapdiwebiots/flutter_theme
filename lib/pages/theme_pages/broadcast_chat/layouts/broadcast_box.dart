import '../../../../config.dart';

class BroadcastInputBox extends StatelessWidget {
  const BroadcastInputBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return Container(
          width: double.infinity,
          height: Sizes.s50,
          decoration: BoxDecoration(
              border: Border(
                  top:
                      BorderSide(color: appCtrl.appTheme.darkGray, width: 0.5)),
              color: appCtrl.appTheme.whiteColor),
          child: Row(children: <Widget>[
            const HSpace(Sizes.s15),
            Flexible(
              child: TextField(
                style:
                    TextStyle(color: appCtrl.appTheme.blackColor, fontSize: 15.0),
                controller: chatCtrl.textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: fonts.enterYourMessage.tr,
                  hintStyle: TextStyle(color: appCtrl.appTheme.gray),
                ),
                focusNode: chatCtrl.focusNode,
                onChanged: (val) {
                  chatCtrl.setTyping();
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
                color: appCtrl.appTheme.whiteColor,
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => chatCtrl.onSendMessage(
                          chatCtrl.textEditingController.text,
                          MessageType.text),
                      color: appCtrl.appTheme.primary,
                    )))
          ]));
    });
  }
}
