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

  makeCall() async {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (_) {
      return WillPopScope(
          onWillPop: chatCtrl.onBackPress,
          child: Scaffold(
              appBar: ChatMessageAppBar(
                  name: chatCtrl.pName,
                  isBlock: chatCtrl.isBlock
                      ? chatCtrl.blockBy == chatCtrl.userData["id"]
                          ? true
                          : false
                      : false,
                  callTap: () {},
                  moreTap: () => chatCtrl.blockUser()),
              backgroundColor: appCtrl.appTheme.whiteColor,
              body: chatCtrl.isUserAvailable
                  ? Stack(children: <Widget>[
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
                  : Center(
                      child: CommonButton(
                        title: fonts.invite.tr,
                        onTap: () {},
                      ),
                    )));
    });
  }
}
