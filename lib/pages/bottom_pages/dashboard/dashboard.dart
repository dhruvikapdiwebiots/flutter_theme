import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final dashboardCtrl = Get.put(DashboardController());

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
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (_) {
      return WillPopScope(
          onWillPop: () async {
            SystemNavigator.pop();
            return false;
          },
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: appCtrl.appTheme.primary,
                  actions: [
                    if (dashboardCtrl.selectedIndex == 1) const PopUpAction(),
                  ],
                  automaticallyImplyLeading: false,
                  title: Text(dashboardCtrl.selectedIndex == 0
                      ? fonts.status.tr
                      : dashboardCtrl.selectedIndex == 1
                          ? fonts.chats.tr
                          : fonts.setting.tr,style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.whiteColor),)),
              body: dashboardCtrl.widgetOptions
                  .elementAt(dashboardCtrl.selectedIndex),
              bottomNavigationBar: dashboardCtrl.bottomList.isNotEmpty
                  ? const BottomNavBar()
                  : Container()));
    });
  }
}
