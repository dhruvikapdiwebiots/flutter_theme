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
    return GetBuilder<ChatController>(builder: (_) {
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
                    // List of messages
                    const MessageBox(),
                    // Sticker
                    Container(),
                    // Input content
                    const InputBox()
                  ]),
                  // Loading
                  const BuildLoader()
                ])
              ])));
    });
  }
}
