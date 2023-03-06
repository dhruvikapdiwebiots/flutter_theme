
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
      return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return false;
        },
        child: Scaffold(
            key: messageCtrl.scaffoldKey,
            backgroundColor: appCtrl.appTheme.bgColor,
            floatingActionButton: FloatingActionButton(
              onPressed: ()async {

                Get.to(
                      () => ContactList(),
                  transition: Transition.downToUp,
                );
              },
              backgroundColor: appCtrl.appTheme.primary,
              child: Container(
                width: Sizes.s52,
                height: Sizes.s52,
                padding: const EdgeInsets.all(Insets.i8),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      appCtrl.appTheme.lightPrimary,
                      appCtrl.appTheme.primary
                    ])),
                child: SvgPicture.asset(svgAssets.add,height: Sizes.s15),
              ),
            ),
            body: const ChatCard()),
      );
    });
  }
}
