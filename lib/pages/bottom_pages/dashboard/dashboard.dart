import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/widgets/no_internet.dart';



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
    dashboardCtrl.connectivitySubscription =
        dashboardCtrl.connectivity.onConnectivityChanged.listen((event) { dashboardCtrl.updateConnectionStatus(event);});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (_) {
      return StreamBuilder(
          stream: Connectivity().onConnectivityChanged,
        builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {
            log("snapshot : ${snapshot.data}");
          return WillPopScope(
            onWillPop: () async {
              SystemNavigator.pop();
              return false;
            },
            child: dashboardCtrl.bottomList.isNotEmpty ? DefaultTabController(
                length: 2,
                child:   snapshot.data == ConnectivityResult.none ? NoInternet(connectionStatus:dashboardCtrl.connectionStatus) : Scaffold(
                    backgroundColor: appCtrl.appTheme.whiteColor,
                    appBar: AppBar(
                      backgroundColor: appCtrl.appTheme.primary,
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      actions: [
                        if (dashboardCtrl.selectedIndex == 0) const PopUpAction(),
                      ],
                      title: Text(fonts.chatter.tr,style: AppCss.poppinsblack16.textColor(appCtrl.appTheme.whiteColor)),

                      bottom: TabBar(
                        controller: dashboardCtrl.controller,
                          labelColor: appCtrl.isTheme?appCtrl.appTheme.secondary : appCtrl.appTheme.primary,
                          unselectedLabelColor: appCtrl.appTheme.white,
                          indicatorSize: TabBarIndicatorSize.label,
                          padding: EdgeInsets.zero,
                          labelStyle: AppCss.poppinsMedium14,
                          indicatorPadding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.zero,
                          indicatorWeight: 0,
                          onTap: (val) {
                            dashboardCtrl.onTapSelect(val);
                          },
                          indicator: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                              color: appCtrl.appTheme.whiteColor),
                          tabs: [
                            ...dashboardCtrl.bottomList
                                .asMap()
                                .entries
                                .map((e) => Tab(
                              iconMargin: EdgeInsets.zero,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                            trans(e.value["title"]).toUpperCase()),
                                      ),
                                    ))
                                .toList()
                          ]),
                    ),
                    body: TabBarView(

                      controller: dashboardCtrl.controller,
                      children: dashboardCtrl.widgetOptions,
                    ))):Container(),
          );
        }
      );
    });
  }
}
