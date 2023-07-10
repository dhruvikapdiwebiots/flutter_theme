import 'package:flutter_theme/config.dart';

class BroadcastChat extends StatefulWidget {
  const BroadcastChat({Key? key}) : super(key: key);

  @override
  State<BroadcastChat> createState() => _BroadcastChatState();
}

class _BroadcastChatState extends State<BroadcastChat>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final chatCtrl = Get.put(BroadcastChatController());
  dynamic receiverData;

  @override
  void initState() {
    // TODO: implement initState
    receiverData = Get.arguments;
    WidgetsBinding.instance.addObserver(this);
    setState(() {});
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      firebaseCtrl.setIsActive();
    } else {
      firebaseCtrl.setLastSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (_) {
      return AgoraToken(
          scaffold: PickupLayout(
              scaffold: WillPopScope(
                  onWillPop: chatCtrl.onBackPress,
                  child: Scaffold(
                      appBar: BroadCastAppBar(
                          name: chatCtrl.broadData["users"] != null
                              ? "${chatCtrl.broadData["users"].length} recipients"
                              : "0",
                          nameList: chatCtrl.nameList),
                      backgroundColor: appCtrl.appTheme.bgColor,
                      body: Stack(children: <Widget>[
                        chatCtrl.broadData != null &&
                                chatCtrl.broadData["backgroundImage"] != null &&
                                chatCtrl.broadData["backgroundImage"] != ""
                            ? const BroadcastBody().decorated(
                                color: appCtrl.appTheme.bgColor,
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        chatCtrl.broadData["backgroundImage"])))
                            : const BroadcastBody(),
                        // Loading
                        if (chatCtrl.isLoading!)
                          CommonLoader(isLoading: chatCtrl.isLoading!)
                      ])))));
    });
  }
}
