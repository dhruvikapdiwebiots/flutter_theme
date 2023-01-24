

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:overlay_support/overlay_support.dart';


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
    dashboardCtrl.initConnectivity();
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
    dashboardCtrl.connectivitySubscription =
        dashboardCtrl.connectivity.onConnectivityChanged.listen((event) {
      dashboardCtrl.updateConnectionStatus(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (_) {
      if (dashboardCtrl.controller != null) {
        dashboardCtrl.onChange(dashboardCtrl.controller!.index);
      }

      return OverlaySupport.global(
        child: PickupLayout(
          scaffold: StreamBuilder(
              stream: Connectivity().onConnectivityChanged,
              builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {

                return WillPopScope(
                  onWillPop: () async {
                    SystemNavigator.pop();
                    return false;
                  },
                  child: dashboardCtrl.bottomList.isNotEmpty
                      ? DashboardBody(
                          snapshot: snapshot,
                        )
                      : Container(),
                );
              }),
        ),
      );
    });
  }
}
