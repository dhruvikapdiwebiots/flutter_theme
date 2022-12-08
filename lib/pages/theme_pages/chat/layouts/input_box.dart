import '../../../../config.dart';

class InputBox extends StatelessWidget {
  const InputBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return Container(
        width: double.infinity,
        height: Sizes.s50,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: appCtrl.appTheme.darkGray, width: 0.5)),
            color: Colors.white),
        child: Row(
          children: <Widget>[
            Material(
              color: Colors.white,
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: chatCtrl.getImage,
                      color: appCtrl.appTheme.primary)),
            ),
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
              ),
            ),
            Material(
              color: Colors.white,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => chatCtrl.onSendMessage(
                      chatCtrl.textEditingController.text, 0),
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
