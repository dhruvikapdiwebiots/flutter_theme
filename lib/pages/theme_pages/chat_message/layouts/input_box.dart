import 'dart:developer';

import 'package:giphy_get/giphy_get.dart';

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
            const HSpace(Sizes.s15),
            Flexible(
              child: TextFormField(
                style: TextStyle(color: appCtrl.appTheme.txt, fontSize: 15.0),
                controller: chatCtrl.textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: fonts.enterYourMessage.tr,
                  hintStyle: TextStyle(color: appCtrl.appTheme.gray),
                ),
                focusNode: chatCtrl.focusNode,
                onChanged: (val) {
                  if (val.contains(".gif")) {
                    chatCtrl.onSendMessage(val, MessageType.gif);
                    chatCtrl.textEditingController.clear();
                  }
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
            IconButton(
                icon: const Icon(Icons.gif_box_outlined),
                padding: const EdgeInsets.all(0.0),
                onPressed: () async {
                  GiphyGif? gif = await GiphyGet.getGif(
                    tabColor: appCtrl.appTheme.primary,
                    context: context,

                    apiKey: fonts.gifAPI, //YOUR API KEY HERE
                    lang: GiphyLanguage.english,
                  );
                  if (gif != null) {
                    chatCtrl.onSendMessage(
                        gif.images!.original!.url, MessageType.gif);
                  }
                },
                color: appCtrl.appTheme.primary),
            Material(
                color: Colors.white,
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => chatCtrl.onSendMessage(
                            chatCtrl.textEditingController.text,
                            MessageType.text),
                        color: appCtrl.appTheme.primary)))
          ],
        ),
      );
    });
  }
}
