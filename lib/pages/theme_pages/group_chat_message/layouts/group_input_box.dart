import 'dart:developer';

import 'package:giphy_get/giphy_get.dart';

import '../../../../config.dart';

class GroupInputBox extends StatelessWidget {
  const GroupInputBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      /*return Container(
        width: double.infinity,
        height: Sizes.s50,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(color: appCtrl.appTheme.darkGray, width: 0.5)),
            color: appCtrl.appTheme.white),
        child: Row(children: <Widget>[
          const HSpace(Sizes.s15),
          Flexible(
              child: TextFormField(
                  style: TextStyle(color: appCtrl.appTheme.txt, fontSize: 15.0),
                  controller: chatCtrl.textEditingController,
                  maxLines: 5,
                  minLines: 1,
                  onTap: () {
                    log("message :${chatCtrl.textEditingController.text}");
                  },
                  onSaved: (val) {
                    log("message :$val");
                  },

                  decoration: InputDecoration.collapsed(
                    hintText: fonts.enterYourMessage.tr,
                    hintStyle: TextStyle(color: appCtrl.appTheme.gray),
                  ),
                  focusNode: chatCtrl.focusNode,
                  onChanged: (val) {
                    chatCtrl.textEditingController.addListener(() {
                      if (val.contains(".gif")) {
                        chatCtrl.onSendMessage(val, MessageType.gif);
                        chatCtrl.textEditingController.clear();
                      }
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
                  })),
          IconButton(
            icon: const Icon(Icons.attachment_outlined),
            onPressed: () {
              chatCtrl.shareMedia(context);
            },
            color: appCtrl.appTheme.primary,
          ),
          IconButton(
            icon: const Icon(Icons.gif_box_outlined),
            padding: const EdgeInsets.all(0.0),
            onPressed: () async{
              GiphyGif? gif =
              await GiphyGet.getGif(
                tabColor: appCtrl.appTheme.primary,
                context: context,

                apiKey:
                fonts.gifAPI, //YOUR API KEY HERE
                lang:
                GiphyLanguage.english,
              );

              if(gif != null) {
                chatCtrl.onSendMessage(gif.images!.original!
                    .url, MessageType.gif);
              }
            },
            color: appCtrl.appTheme.primary,
          ),
          Material(
              color: appCtrl.appTheme.white,
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: Insets.i8),
                  child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => chatCtrl.onSendMessage(
                          chatCtrl.textEditingController.text,
                          MessageType.text),
                      color: appCtrl.appTheme.primary)))
        ]),
      );*/
      return Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        margin:
        const EdgeInsets.fromLTRB(Insets.i20, 0, Insets.i20, Insets.i20),
        height: Sizes.s50,
        decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                  color: Color.fromRGBO(49, 100, 189, 0.08),
                  blurRadius: 5,
                  offset: Offset(-5, 5)),
            ],
            borderRadius: BorderRadius.circular(AppRadius.r10),
            border: Border.all(
                color: const Color.fromRGBO(49, 100, 189, 0.1), width: 1),
            color: appCtrl.appTheme.whiteColor),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const HSpace(Sizes.s15),
            Flexible(
                child: TextFormField(
                  minLines: 1,
                  maxLines: 5,
                  style: TextStyle(color: appCtrl.appTheme.txt, fontSize: 15.0),
                  controller: chatCtrl.textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: fonts.enterYourMessage.tr,
                    hintStyle: TextStyle(color: appCtrl.appTheme.gray),
                  ),
                  enableInteractiveSelection: false,
                  focusNode: chatCtrl.focusNode,
                  keyboardType: TextInputType.text,
                  onChanged: (val) {
                    chatCtrl.textEditingController.addListener(() {
                      if (val.contains(".gif")) {
                        chatCtrl.onSendMessage(val, MessageType.gif);
                        chatCtrl.textEditingController.clear();
                      }
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
                )),
            SvgPicture.asset(
              svgAssets.audio,
              height: Sizes.s22,
            ).inkWell(
                onTap: () => chatCtrl.audioRecording(context, "audio", 0)),
            SvgPicture.asset(svgAssets.gif)
                .inkWell(onTap: () => chatCtrl.shareMedia(context))
                .marginSymmetric(horizontal: Insets.i20),
            Container(
                margin: EdgeInsets.only(
                    right: appCtrl.isRTL || appCtrl.languageVal == "ar"
                        ? 0
                        : Insets.i6,
                    left: appCtrl.isRTL || appCtrl.languageVal == "ar"
                        ? Insets.i6
                        : 0),
                padding: const EdgeInsets.symmetric(
                    vertical: Insets.i10, horizontal: Insets.i2),
                decoration: ShapeDecoration(
                    gradient: RadialGradient(colors: [
                      appCtrl.appTheme.lightPrimary,
                      appCtrl.appTheme.primary
                    ]),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1),
                    )),
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SvgPicture.asset(svgAssets.send)))
                .inkWell(
                onTap: () => chatCtrl.onSendMessage(
                    chatCtrl.textEditingController.text, MessageType.text))
          ],
        ),
      );
    });
  }
}
