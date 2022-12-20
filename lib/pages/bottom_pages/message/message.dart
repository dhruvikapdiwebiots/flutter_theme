import 'package:flutter_theme/config.dart';

class Message extends StatefulWidget {
  const Message({Key? key}) : super(key: key);

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final messageCtrl = Get.put(MessageController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    messageCtrl.getMessage();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      firebaseCtrl.setIsActive();
    } else {
      firebaseCtrl.setLastSeen();
    }
    firebaseCtrl.statusDeleteAfter24Hours();
    messageCtrl.getMessage();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (_) {
      return WillPopScope(
        onWillPop: messageCtrl.onWillPop,
        child: Scaffold(
            key: messageCtrl.scaffoldKey,
            floatingActionButton: FloatingActionButton(
              onPressed: () => messageCtrl.saveContactInChat(),
              backgroundColor: appCtrl.appTheme.primary,
              child:  Icon(Icons.message,color: appCtrl.appTheme.whiteColor),
            ),
            body: SafeArea(
                child: Stack(fit: StackFit.expand, children: <Widget>[
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 50,

                  child: const ChatCard()),
            ]))),
      );
    });
  }
}
