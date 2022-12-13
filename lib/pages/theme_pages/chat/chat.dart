
import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {

  Chat({Key? key}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat>  with
    WidgetsBindingObserver,
    TickerProviderStateMixin{
  final chatCtrl = Get.put(ChatController());
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("state : ${AppLifecycleState.resumed}");
    log("chatCtrl : ${chatCtrl.pId}");
    log("chatCtrl : ${chatCtrl.id}");
    if (state == AppLifecycleState.resumed) {
      setIsActive();
      setTyping();

      chatCtrl.getPeerStatus();
    }else {
      setLastSeen();
      chatCtrl.getPeerStatus();
      log("message : ${chatCtrl.status}");
    }

  }

  void setIsActive() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(chatCtrl.id).update(
      {"status": "Online","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
    );
  }

  setTyping()async {
    log("use : ${chatCtrl.pId}");
    log("use : ${chatCtrl.id}");
    chatCtrl.textEditingController.addListener(() {
      if (chatCtrl.textEditingController.text.isNotEmpty) {
        FirebaseFirestore.instance.collection("users").doc(chatCtrl.id).update(
          {"status": "typing...","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
        );
        chatCtrl.typing = true;
      }
      if (chatCtrl.textEditingController.text.isEmpty && chatCtrl.typing == true) {
        FirebaseFirestore.instance.collection("users").doc(chatCtrl.id).update(
          {"status": "Online","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
        );
        chatCtrl.typing = false;
      }
    });
  }

  void setLastSeen() async {
    await FirebaseFirestore.instance.collection("users").doc(chatCtrl.id).update(
      {"status": "Offline","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
    );
  }
  @override
  Widget build(BuildContext context) {

    log("use : ${chatCtrl.getPeerStatus()}");
    return GetBuilder<ChatController>(builder: (_) {
      return WillPopScope(
        onWillPop: chatCtrl.onBackPress,
        child: Scaffold(
          appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatCtrl.pName!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: appCtrl.appTheme.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const VSpace(Sizes.s10),
                 /* Text(
                      chatCtrl.getPeerStatus() =="Offline" ? DateFormat('HH:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(chatCtrl.statusLastSeen.toString()))): chatCtrl.getPeerStatus(),
                    textAlign: TextAlign.center,
                    style:AppCss.poppinsMedium14.textColor(appCtrl.appTheme.whiteColor),
                  ),*/

                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users').where("id", isEqualTo: chatCtrl.pId).snapshots(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    appCtrl.appTheme.primary)));
                      } else {
                        chatCtrl.  message = (snapshot.data!).docs;
                        return Text(
                          snapshot.data!.docs[0]["status"] == "Offline" ? DateFormat('HH:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(snapshot.data!.docs[0]['lastSeen']))): snapshot.data!.docs[0]["status"],
                          textAlign: TextAlign.center,
                          style:AppCss.poppinsMedium14.textColor(appCtrl.appTheme.whiteColor),
                        );
                      }
                    },
                  )
                ],
              )),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(imageAssets.chatBg),
                          fit: BoxFit.cover))),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      // List of messages
                      const MessageBox(),
                      // Sticker
                      Container(),
                      // Input content
                      const InputBox(),
                    ],
                  ),
                  // Loading
                  const BuildLoader()
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
