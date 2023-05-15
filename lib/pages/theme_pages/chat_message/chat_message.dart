import 'dart:developer';

import 'package:flutter_theme/config.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final chatCtrl = Get.put(ChatController());
  dynamic receiverData;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      chatCtrl.setTyping();
    });
    receiverData = Get.arguments;
    setState(() {});
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      firebaseCtrl.setIsActive();
      chatCtrl.setTyping();
    } else {
      firebaseCtrl.setLastSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (_) {
      return AgoraToken(
        scaffold: PickupLayout(
          scaffold: WillPopScope(
              onWillPop: chatCtrl.onBackPress,
              child: chatCtrl.userData != null
                  ? Scaffold(
                      appBar: ChatMessageAppBar(
                          userId: chatCtrl.pId,
                          name: chatCtrl.pName,
                          isBlock: chatCtrl.allData != null
                              ? chatCtrl.allData["isBlock"]
                                  ? chatCtrl.allData["blockUserId"] ==
                                          chatCtrl.userData["id"]
                                      ? true
                                      : false
                                  : false
                              : false,
                          callTap: () async {
                            await chatCtrl.permissionHandelCtrl
                                .getCameraMicrophonePermissions()
                                .then((value) {
                              if (value == true) {
                                chatCtrl.audioVideoCallTap(false);
                              }
                            });
                          },
                          videoTap: () async {
                            await chatCtrl.permissionHandelCtrl
                                .getCameraMicrophonePermissions()
                                .then((value) {
                              log("value : $value");
                              if (value == true) {
                                log("message");
                                chatCtrl.audioVideoCallTap(true);
                              }
                            });
                          },
                          moreTap: () => chatCtrl.blockUser()),
                      backgroundColor: appCtrl.appTheme.bgColor,
                      body: Stack(children: <Widget>[
                        Column(children: <Widget>[
                          // List of messages
                          const MessageBox(),
                          // Sticker
                          Container(),
                          // Input content
                          const InputBox()
                        ]).inkWell(onTap: () {
                          chatCtrl.enableReactionPopup = false;
                          chatCtrl.showPopUp = false;
                          chatCtrl.update();
                          log("chatCtrl.enableReactionPopup : ${chatCtrl.enableReactionPopup}");
                        }),
                        // Loading
                        if (chatCtrl.isLoading)
                          CommonLoader(isLoading: chatCtrl.isLoading),
                        GetBuilder<AppController>(builder: (appCtrl) {
                          return CommonLoader(isLoading: appCtrl.isLoading);
                        })
                      ]))
                  : const Scaffold()),
        ),
      );
    });
  }
}
