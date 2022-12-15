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
    receiverData = Get.arguments;
    setState(() {

    });
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

  makeCall()async{
    var user = appCtrl.storage.read("user");
    await FirebaseFirestore.instance
        .collection('call')
        .doc(user["id"])
        .set(user);
    await FirebaseFirestore.instance
        .collection('call')
        .doc(receiverData["id"])
        .set(receiverData);

   /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          channelId: senderCallData.callId,
          call: senderCallData,
          isGroupChat: false,
        ),
      ),
    );*/
    Get.toNamed(routeName.callScreen,arguments:user );
  }

  @override
  Widget build(BuildContext context) {
    log("use : ${chatCtrl.getPeerStatus()}");
    return GetBuilder<ChatController>(builder: (_) {
      return WillPopScope(
          onWillPop: chatCtrl.onBackPress,
          child: Scaffold(
              appBar: ChatMessageAppBar(name: chatCtrl.pName,callTap: ()=> makeCall()),
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
