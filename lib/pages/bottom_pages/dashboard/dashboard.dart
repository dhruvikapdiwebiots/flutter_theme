import 'dart:developer';

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
    firebaseCtrl.syncContact();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (_) {
      if (dashboardCtrl.controller != null) {
        dashboardCtrl.onChange(dashboardCtrl.controller!.index);
      }

      return OverlaySupport.global(
        child: AgoraToken(
          scaffold: PickupLayout(
            scaffold: StreamBuilder(
                stream: Connectivity().onConnectivityChanged,
                builder: (context, AsyncSnapshot<ConnectivityResult> snapshot) {
                  return appCtrl.user != null ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection(collectionName.users)
                          .doc(appCtrl.user["id"])
                          .snapshots(),
                      builder: (context, snapShot) {
                        if (snapShot.hasData) {
                          if (snapShot.data!.exists) {
                            bool isWebLogin =
                                snapShot.data!.data()!["isWebLogin"] ?? false;
                            if (isWebLogin == true) {
                              if (appCtrl.contactList.isNotEmpty) {
                                List<Map<String, dynamic>> contactsData =
                                    appCtrl.contactList.map((contact) {
                                  return {
                                    'name': contact.displayName,
                                    'phoneNumber': contact.phones.isNotEmpty
                                        ? phoneNumberExtension(
                                            contact.phones[0].number.toString())
                                        : null,
                                    // Include other necessary contact details
                                  };
                                }).toList();
                                FirebaseFirestore.instance
                                    .collection(collectionName.users)
                                    .doc(FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.uid : appCtrl.user["id"])
                                    .collection(collectionName.userContact)
                                    .add({'contacts': contactsData});
                              }else{
                                dashboardCtrl.checkPermission();
                                if (appCtrl.contactList.isNotEmpty) {
                                  List<Map<String, dynamic>> contactsData =
                                  appCtrl.contactList.map((contact) {
                                    return {
                                      'name': contact.displayName,
                                      'phoneNumber': contact.phones.isNotEmpty
                                          ? phoneNumberExtension(
                                          contact.phones[0].number.toString())
                                          : null,
                                      // Include other necessary contact details
                                    };
                                  }).toList();
                                  FirebaseFirestore.instance
                                      .collection(collectionName.users)
                                      .doc(appCtrl.user["id"])
                                      .collection(collectionName.userContact)
                                      .add({'contacts': contactsData});
                                }
                              }
                            }
                          }
                        }
                        return WillPopScope(
                          onWillPop: () async {
                            if(dashboardCtrl.selectedIndex != 0){
                              dashboardCtrl.onChange(0);
                              dashboardCtrl.controller!.index =0;
                              dashboardCtrl.update();
                              return false;
                            }else if(dashboardCtrl.isSearch == true){
                              dashboardCtrl.isSearch = false;
                              dashboardCtrl.userText.text = "";

                              dashboardCtrl.update();
                              return false;
                            }else{
                              SystemNavigator.pop();
                              return true;
                            }

                          },
                          child: dashboardCtrl.bottomList.isNotEmpty
                              ? DashboardBody(
                                  snapshot: snapshot,
                                )
                              : Container(),
                        );
                      }):Container();
                }),
          ),
        ),
      );
    });
  }
}
