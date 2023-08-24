import 'dart:developer';

import 'package:flutter_theme/pages/theme_pages/group_chat_message/group_message_api.dart';
import 'package:flutter_theme/widgets/common_note_encrypt.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../config.dart';

class GroupMessageBox extends StatelessWidget {
  const GroupMessageBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return Flexible(
              child: chatCtrl.pId == null
                      ? Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  appCtrl.appTheme.primary)))
                      :ListView(
                controller: chatCtrl.listScrollController,
                reverse: true,
                children: [

                  ...chatCtrl.localMessage.asMap().entries.map((e) => chatCtrl
                      .timeLayout(
                    e.value,
                  )
                      .marginOnly(bottom: Insets.i18)).toList(),
                  Container(
                      margin: const EdgeInsets.only(bottom: 2.0),
                      padding: const EdgeInsets.only(
                          left: Insets.i10, right: Insets.i10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          const Align(
                            alignment: Alignment.center,
                            child: CommonNoteEncrypt(),
                          ).paddingOnly(bottom: Insets.i8)
                        ],
                      )),
                  /*ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return chatCtrl
                            .timeLayout(
                              chatCtrl.message[index],
                            )
                            .marginOnly(bottom: Insets.i18);
                      },
                      itemCount: chatCtrl.message.reversed.length,
                      reverse: true,
                      controller: chatCtrl.listScrollController),*/
                ],
              )  /*StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(collectionName.users)
                              .doc(appCtrl.user["id"])
                              .collection(collectionName.groupMessage)
                              .doc(chatCtrl.pId)
                              .collection(collectionName.chat)
                              .orderBy('timestamp', descending: true)
                              .limit(chatCtrl.pageSize)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            } else {
                              GroupMessageApi().getMessageAsPerDate(snapshot);

                              return ListView.builder(
                                itemBuilder: (context, index) {
                                  return chatCtrl
                                      .timeLayout(

                                      chatCtrl.message[index])
                                      .marginOnly(bottom: Insets.i18);
                                },
                                itemCount:chatCtrl.message.reversed.length,
                                reverse: true,
                                controller: chatCtrl.listScrollController,
                              );
                            }
                          },
                        )*/);
    });
  }
}
