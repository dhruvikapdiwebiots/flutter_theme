import 'dart:developer';

import 'package:giphy_get/giphy_get.dart';

import '../../../../config.dart';

class GroupInputBox extends StatelessWidget {
  const GroupInputBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
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
            InkWell(
              child:
                  Icon(Icons.gif_box_outlined, color: appCtrl.appTheme.primary),
              onTap: () async {
                log("appCtrl.userAppSettingsVal! : ${appCtrl.userAppSettingsVal!.gifAPI}");
                GiphyGif? gif = await GiphyGet.getGif(
                  tabColor: appCtrl.appTheme.primary,
                  context: context,

                  apiKey: appCtrl.userAppSettingsVal!.gifAPI!, //YOUR API KEY HERE
                  lang: GiphyLanguage.english,
                );
                if (gif != null) {
                  chatCtrl.onSendMessage(
                      gif.images!.original!.url, MessageType.gif);
                }
              },
            ).marginOnly(
                right: appCtrl.isRTL || appCtrl.languageVal == "ar"
                    ? 0
                    : Insets.i6,
                left: appCtrl.isRTL || appCtrl.languageVal == "ar"
                    ? Insets.i6
                    : 0),
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
                          appCtrl.isTheme
                              ? appCtrl.appTheme.primary.withOpacity(.8)
                              : appCtrl.appTheme.lightPrimary,
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
