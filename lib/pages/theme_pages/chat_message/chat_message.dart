import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/call_screen/layouts/call_utility.dart';

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
    /*var user = appCtrl.storage.read("user");
    await FirebaseFirestore.instance
        .collection('call')
        .doc(user["id"])
        .set(user);
    await FirebaseFirestore.instance
        .collection('call')
        .doc(receiverData["id"])
        .set(receiverData);

    Get.toNamed(routeName.callScreen,arguments:user );*/
  }

  call( bool isVideoCall) async {
    var data = appCtrl.storage.read("user");
    var myNickName = data["name"];

    var myphotoUrl = data["image"];

    CallUtils.dial(
        currentuseruid: chatCtrl.pId,
        fromDp: myphotoUrl,
        toDp: data["image"],
        fromUID: data["id"],
        fromFullname: data["name"],
        toUID: chatCtrl.pId,
        toFullname: chatCtrl.pName,
        context: context,
        isVideoCall: isVideoCall);
  }

  @override
  Widget build(BuildContext context) {
    log("use : ${chatCtrl.getPeerStatus()}");
    return GetBuilder<ChatController>(builder: (_) {
      return WillPopScope(
          onWillPop: chatCtrl.onBackPress,
          child: Scaffold(
              appBar: ChatMessageAppBar(name: chatCtrl.pName,callTap:()=> call(false)),
              backgroundColor: Colors.white,

              body: chatCtrl.isUserAvailable ?  Stack(children: [
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
              ]): Center(
                child: CommonButton(title: "Invite",onTap: (){},),
              )));
    });
  }
}
