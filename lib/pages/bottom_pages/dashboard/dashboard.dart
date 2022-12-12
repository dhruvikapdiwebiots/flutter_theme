import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with
        WidgetsBindingObserver,
        TickerProviderStateMixin {
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
      setIsActive();
    } else {
      setLastSeen();
    }
  }

  void setIsActive() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(userId).update(
      {"status": "Online","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
    );
  }

  void setLastSeen() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(userId).update(
      {"status": "Offline","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
    );
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
              body: dashboardCtrl.widgetOptions
                  .elementAt(dashboardCtrl.selectedIndex),
              bottomNavigationBar: dashboardCtrl.bottomList.isNotEmpty
                  ? const BottomNavBar()
                  : Container()));
    });
  }

}
