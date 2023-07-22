import 'dart:developer';

import '../../../../config.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SingleClearDialog extends StatelessWidget {
  const SingleClearDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return GetBuilder<ChatController>(builder: (chatCtrl) {
          return Align(
              alignment: Alignment.center,
              child: Container(
                  height: Sizes.s180,
                  color: appCtrl.appTheme.whiteColor,
                  margin: const EdgeInsets.symmetric(
                      horizontal: Insets.i30, vertical: Insets.i15),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Insets.i20, vertical: Insets.i22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fonts.clearChatId.tr,
                        style: AppCss.poppinsblack20
                            .textColor(appCtrl.appTheme.blackColor),
                      ),
                      const VSpace(Sizes.s12),
                      Text(
                        fonts.deleteOption.tr,
                        style: AppCss.poppinsMedium14
                            .textColor(appCtrl.appTheme.txtColor),
                      ),
                      const VSpace(Sizes.s20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: CommonButton(
                                margin: 0,
                            title: fonts.cancel.tr,
                            onTap: () => Get.back(),
                            style: AppCss.poppinsMedium14
                                .textColor(appCtrl.appTheme.white),
                          )),
                          const HSpace(Sizes.s10),
                          Expanded(
                              child: CommonButton(
                                margin: 0,
                                  onTap: () async {
                                    Get.back();

                                    await FirebaseFirestore.instance
                                        .collection(collectionName.users)
                                        .doc(appCtrl.user["id"])
                                        .collection(collectionName.messages)
                                        .doc(chatCtrl.chatId)
                                        .collection(collectionName.chat)
                                        .get()
                                        .then((value) async {
                                      if (value.docs.isNotEmpty) {
                                        value.docs
                                            .asMap()
                                            .entries
                                            .forEach((element) async {
                                          await FirebaseFirestore.instance
                                              .collection(collectionName.users)
                                              .doc(appCtrl.user["id"])
                                              .collection(
                                                  collectionName.messages)
                                              .doc(chatCtrl.chatId)
                                              .collection(collectionName.chat)
                                              .doc(element.value.id)
                                              .delete();
                                        });
                                      }
                                      await FirebaseFirestore.instance
                                          .collection(collectionName.users)
                                          .doc(appCtrl.user["id"])
                                          .collection(collectionName.chats)
                                          .where("chatId",
                                              isEqualTo: chatCtrl.chatId)
                                          .get()
                                          .then((userGroup) {
                                        if (userGroup.docs.isNotEmpty) {
                                          FirebaseFirestore.instance
                                              .collection(collectionName.users)
                                              .doc(appCtrl.user["id"])
                                              .collection(collectionName.chats)
                                              .doc(userGroup.docs[0].id)
                                              .update({"lastMessage": ""});
                                        }

                                      });
                                      final key = encrypt.Key.fromUtf8('my 32 length key................');
                                      final iv = encrypt.IV.fromLength(16);

                                      final encrypter = encrypt.Encrypter(encrypt.AES(key));

                                      final encrypted = encrypter.encrypt(fonts.noteEncrypt.tr, iv: iv).base64;
                                      await FirebaseFirestore.instance
                                          .collection(collectionName.users)
                                          .doc(appCtrl.user["id"])
                                          .collection(collectionName.messages)
                                          .doc(chatCtrl.chatId)
                                          .collection(collectionName.chat)
                                          .where("type", isEqualTo: MessageType.note.name).limit(1)
                                          .get()
                                          .then((value) async {
                                        if (value.docs.isEmpty) {

                                          await FirebaseFirestore.instance
                                              .collection(collectionName.users)
                                              .doc(appCtrl.user["id"])
                                              .collection(collectionName.messages)
                                              .doc(chatCtrl.chatId)
                                              .collection(collectionName.chat)
                                              .doc(DateTime.now().millisecondsSinceEpoch.toString())
                                              .set({
                                            'sender': chatCtrl.userData["id"],
                                            'receiver': chatCtrl.pId,
                                            'content': encrypted,
                                            "chatId": chatCtrl.chatId,
                                            'type': MessageType.note.name,
                                            'messageType': "sender",
                                            "isBlock": false,
                                            "isSeen": true,
                                            "isBroadcast": false,
                                            "blockBy": "",
                                            "blockUserId": "",
                                            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                                          }, SetOptions(merge: true));
                                        }
                                      });
                                      chatCtrl.message = [];
                                      chatCtrl.update();

                                    });
                                  },
                                  title: fonts.clearChat.tr,
                                  style: AppCss.poppinsMedium14
                                      .textColor(appCtrl.appTheme.white))),
                        ],
                      )
                    ],
                  )));
        });
      }),
    );
  }
}
