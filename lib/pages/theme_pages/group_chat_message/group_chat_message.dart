import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_build_loader.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_input_box.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_message_box.dart';

class GroupChatMessage extends StatefulWidget {
  const GroupChatMessage({Key? key}) : super(key: key);

  @override
  State<GroupChatMessage> createState() => _GroupChatMessageState();
}

class _GroupChatMessageState extends State<GroupChatMessage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final chatCtrl = Get.put(GroupChatMessageController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appCtrl.firebaseCtrl.setIsActive();
      chatCtrl.setTyping();
      chatCtrl.getPeerStatus();
    } else {
      appCtrl.firebaseCtrl.setLastSeen();
      chatCtrl.getPeerStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    log("use : ${chatCtrl.getPeerStatus()}");
    return GetBuilder<GroupChatMessageController>(builder: (_) {
      return WillPopScope(
          onWillPop: chatCtrl.onBackPress,
          child: Scaffold(
              appBar: ChatMessageAppBar(name: chatCtrl.pName),
              backgroundColor: Colors.white,
              body: Stack(children: [
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(imageAssets.chatBg),
                            fit: BoxFit.cover))),
                Stack(children: <Widget>[
                  Column(children: <Widget>[
                 /*   const VSpace(Sizes.s10),
                    SizedBox(
                      height: Sizes.s20,
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('groups')
                              .where("groupId", isEqualTo: chatCtrl.pId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.data != null) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            appCtrl.appTheme.primary)));
                              } else {
                                return Text(
                                  snapshot.data!.docs[0]["createdBy"]["id"] == chatCtrl.id
                                      ? "You created this group"
                                      : "${snapshot.data!.docs[0]["createdBy"]["name"]} created this group",
                                  textAlign: TextAlign.center,
                                  style: AppCss.poppinsMedium14
                                      .textColor(appCtrl.appTheme.whiteColor),
                                );
                              }
                            } else {
                              return Center(
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          appCtrl.appTheme.primary)));
                            }
                          }),
                    ),*/
                    // List of messages
                    const GroupMessageBox(),
                    // Sticker
                    Container(),
                    // Input content
                    const GroupInputBox()
                  ]),
                  // Loading
                  const GroupBuildLoader()
                ])
              ])));
    });
  }
}
