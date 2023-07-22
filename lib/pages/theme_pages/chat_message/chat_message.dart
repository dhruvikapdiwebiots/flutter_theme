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
                        onSelected: (result) async {

                          if (result == 0) {

                            await chatCtrl.permissionHandelCtrl
                                .getCameraMicrophonePermissions()
                                .then((value) {
                              if (value == true) {
                                chatCtrl.audioVideoCallTap(false);
                              }
                            });
                          } else if (result == 1) {
                            await chatCtrl.permissionHandelCtrl
                                .getCameraMicrophonePermissions()
                                .then((value) {

                              if (value == true) {

                                chatCtrl.audioVideoCallTap(true);
                              }
                            });
                          }
                        },
                        isBlock: chatCtrl.allData != null
                            ? chatCtrl.allData["isBlock"] == true
                                ? chatCtrl.allData["blockUserId"] ==
                                        chatCtrl.userData["id"]
                                    ? true
                                    : false
                                : false
                            : false,
                      ),
                      backgroundColor: appCtrl.appTheme.bgColor,
                      body: chatCtrl.allData != null
                          ? Stack(children: <Widget>[
                              chatCtrl.allData["backgroundImage"] != null
                                  ? Column(children: <Widget>[
                                      // List of messages
                                      const MessageBox(),
                                      // Sticker
                                      Container(),
                                      // Input content
                                      const InputBox()
                                    ])
                                      .decorated(
                                          color: appCtrl.appTheme.bgColor,
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(chatCtrl
                                                  .allData["backgroundImage"])))
                                      .inkWell(onTap: () {
                                      chatCtrl.enableReactionPopup = false;
                                      chatCtrl.showPopUp = false;
                                      chatCtrl.update();

                                    })
                                  : Column(children: <Widget>[
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
                                    }),
                              // Loading
                              if (chatCtrl.isLoading)
                                CommonLoader(isLoading: chatCtrl.isLoading),
                              GetBuilder<AppController>(builder: (appCtrl) {
                                return CommonLoader(
                                    isLoading: appCtrl.isLoading);
                              })
                            ])
                          : Container())
                  : const Scaffold()),
        ),
      );
    });
  }
}
