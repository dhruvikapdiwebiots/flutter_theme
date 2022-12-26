
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
      return WillPopScope(
          onWillPop: chatCtrl.onBackPress,
          child: Scaffold(
              appBar: BroadCastAppBar(
                  name: "${chatCtrl.totalUser} recipients",nameList: chatCtrl.nameList,),
              backgroundColor: Colors.white,
              body: chatCtrl.isUserAvailable
                  ? Stack(children: [
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(imageAssets.chatBg),
                            fit: BoxFit.cover))),
                Stack(children: <Widget>[
                  Column(children: <Widget>[
                    // List of messages
                    const BroadcastMessage(),
                    // Sticker
                    Container(),
                    // Input content
                    const BroadcastInputBox()
                  ]),
                  // Loading
                  LoginLoader(isLoading: chatCtrl.isLoading!,)
                ])
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
