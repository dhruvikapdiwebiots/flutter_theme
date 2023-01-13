import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
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

    log("cccccc");
    log("index : ${dashboardCtrl.controller!.index}");
    dashboardCtrl.connectivitySubscription =
        dashboardCtrl.connectivity.onConnectivityChanged.listen((event) {
      dashboardCtrl.updateConnectionStatus(event);
    });

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (_) {
      dashboardCtrl.onChange(dashboardCtrl.controller!.index);
      log("index : ${dashboardCtrl.selectedIndex}");
      return StreamBuilder(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {
            log("snapshot : ${snapshot.data}");


            return WillPopScope(
              onWillPop: () async {
                SystemNavigator.pop();
                return false;
              },
              child: dashboardCtrl.bottomList.isNotEmpty
                  ? DashboardBody(snapshot: snapshot,)
                  : Container(),
            );
          });
    });
  }
}
