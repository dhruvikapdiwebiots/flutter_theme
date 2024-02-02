import 'package:flutter_theme/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message extends StatefulWidget {
  final SharedPreferences? sharedPreferences;
  const Message({Key? key,this.sharedPreferences}) : super(key: key);

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
    firebaseCtrl.deleteForAllUsers();

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MessageController>(builder: (_) {
      return GetBuilder<AppController>(builder: (appCtrl) {
        return Stack(children: [
          NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowIndicator();
                return false;
              },
              child: Scaffold(
                  key: messageCtrl.scaffoldKey,
                  backgroundColor: appCtrl.appTheme.bgColor,
                  floatingActionButton:  MessageFloatingButton(prefs: widget.sharedPreferences!,),
                  body:const ChatCard())),
        ]);
      });
    });
  }
}
