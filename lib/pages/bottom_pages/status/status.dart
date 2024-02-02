import 'package:flutter_theme/config.dart';



class StatusList extends StatefulWidget {
  const StatusList({Key? key}) : super(key: key);

  @override
  State<StatusList> createState() => _StatusListState();
}

class _StatusListState extends State<StatusList>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final statusCtrl = Get.put(StatusController());

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
    return GetBuilder<StatusController>(builder: (_) {

      return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowIndicator();
            return false;
          },

          child: Scaffold(
              backgroundColor: appCtrl.appTheme.bgColor,
              floatingActionButton: const StatusFloatingButton(),
              body: SafeArea(
                  child: Stack(children: [
                AdCommonLayout(
                    bannerAdIsLoaded: statusCtrl.bannerAdIsLoaded,
                    bannerAd: statusCtrl.bannerAd,
                    currentAd: statusCtrl.currentAd),
                 const   StatusListBodyLayout()
              ]))));
    });
  }
}
