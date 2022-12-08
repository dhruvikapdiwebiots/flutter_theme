import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';

class Dashboard extends StatefulWidget {

 const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>  with
    WidgetsBindingObserver,
    AutomaticKeepAliveClientMixin,TickerProviderStateMixin {
  final dashboardCtrl = Get.put(DashboardController());

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("message : $state");
    if (state == AppLifecycleState.resumed) {
      setIsActive();
    } else {
      setLastSeen();
    }
  }

  void setIsActive() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(userId).update(
      {"status": "Online"},
    );
  }

  void setLastSeen() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update(
      {"status": DateTime.now().millisecondsSinceEpoch,"isLastSeen": true},
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              ? BottomNavigationBar(
                  selectedItemColor: appCtrl.appTheme.secondary,
                  backgroundColor: appCtrl.appTheme.primary,
                  selectedLabelStyle: AppCss.poppinsBold14
                      .textColor(appCtrl.appTheme.whiteColor),
                  unselectedItemColor: appCtrl.appTheme.accent,
                  selectedIconTheme:
                      IconThemeData(color: appCtrl.appTheme.secondary),
                  unselectedLabelStyle: AppCss.poppinsMedium16
                      .textColor(appCtrl.appTheme.primary),
                  items: <BottomNavigationBarItem>[
                    ...dashboardCtrl.bottomList
                        .asMap()
                        .entries
                        .map((e) => BottomNavigationBarItem(
                            icon: Icon(e.value["icon"])
                                .paddingOnly(bottom: Insets.i5),
                            label: e.value["title"]))
                        .toList()
                  ],
                  currentIndex: dashboardCtrl.selectedIndex,
                  onTap: (index) => dashboardCtrl.onTapSelect(index),
                )
              : Container(),
        ),
      );
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
