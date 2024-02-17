import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/data_model.dart';

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
    dashboardCtrl.pref = Get.arguments;
    dashboardCtrl.update();

    WidgetsBinding.instance.addObserver(this);
    dashboardCtrl.initConnectivity();

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    log("state ; $state");
    if (state == AppLifecycleState.resumed) {
      firebaseCtrl.setIsActive();

      // dashboardCtrl.addContactInFirebase();

      dashboardCtrl.update();
      Get.forceAppUpdate();
    } else {
      firebaseCtrl.setLastSeen();
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {}

    firebaseCtrl.statusDeleteAfter24Hours();
    firebaseCtrl.deleteForAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactModel>(
        model: appCtrl.getModel()!,
        child: ScopedModelDescendant<ContactModel>(
            builder: (context, child, model) {
          appCtrl.cachedModel = model;
          return Consumer<RecentChatController>(
              builder: (context, recentChat, child) {
            return GetBuilder<DashboardController>(builder: (_) {
              return Consumer<FetchContactController>(
                  builder: (context1, contactCtrl, child) {
                return OverlaySupport.global(
                    child: AgoraToken(
                  scaffold: PickupLayout(
                    scaffold: StreamBuilder(
                        stream: Connectivity().onConnectivityChanged,
                        builder: (context,
                            AsyncSnapshot<ConnectivityResult> snapshot) {
                          return appCtrl.user != null
                              ? StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection(collectionName.users)
                                      .doc(appCtrl.user["id"])
                                      .snapshots(),
                                  builder: (context, snapShot) {
                                    if (snapShot.hasData) {
                                      if (snapShot.data!.exists) {
                                        bool isWebLogin = snapShot.data!
                                                .data()!["isWebLogin"] ??
                                            false;
                                        if (isWebLogin == true) {
                                          log("appCtrl.isCallStream : ${appCtrl.isCallStream}");
                                          if (appCtrl.isCallStream == false) {
                                            appCtrl.isCallStream = true;

                                            FirebaseFirestore.instance
                                                .collection(
                                                    collectionName.users)
                                                .doc(appCtrl.user["id"])
                                                .collection(
                                                    collectionName.userContact)
                                                .get()
                                                .then((value) {
                                              log("value.docs : ${value.docs.length}");
                                              if (value.docs.isEmpty) {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        collectionName.users)
                                                    .doc(FirebaseAuth.instance
                                                                .currentUser !=
                                                            null
                                                        ? FirebaseAuth.instance
                                                            .currentUser!.uid
                                                        : appCtrl.user["id"])
                                                    .collection(collectionName
                                                        .userContact)
                                                    .add({
                                                  'contacts': RegisterContactDetail
                                                      .encode(contactCtrl
                                                          .registerContactUser)
                                                });
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        collectionName.users)
                                                    .doc(FirebaseAuth.instance
                                                                .currentUser !=
                                                            null
                                                        ? FirebaseAuth.instance
                                                            .currentUser!.uid
                                                        : appCtrl.user["id"])
                                                    .update(
                                                        {'isWebLogin': false});
                                                appCtrl.isCallStream = false;
                                              } else {
                                                log("UPPPP");
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        collectionName.users)
                                                    .doc(FirebaseAuth.instance
                                                                .currentUser !=
                                                            null
                                                        ? FirebaseAuth.instance
                                                            .currentUser!.uid
                                                        : appCtrl.user["id"])
                                                    .collection(collectionName
                                                        .userContact)
                                                    .doc(value.docs[0].id)
                                                    .update({
                                                  'contacts': RegisterContactDetail
                                                      .encode(contactCtrl
                                                          .registerContactUser)
                                                });
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        collectionName.users)
                                                    .doc(FirebaseAuth.instance
                                                                .currentUser !=
                                                            null
                                                        ? FirebaseAuth.instance
                                                            .currentUser!.uid
                                                        : appCtrl.user["id"])
                                                    .update(
                                                        {'isWebLogin': false});
                                              }
                                            });
                                          }
                                        }
                                      }
                                    }
                                    return PopScope(
                                      canPop: false,
                                      onPopInvoked: (did) async {
                                        log("did :$did");
                                     if(did) return;
                                        if (dashboardCtrl.selectedIndex != 0) {
                                          dashboardCtrl.onChange(0);
                                          dashboardCtrl.controller!.index = 0;
                                          dashboardCtrl.update();

                                        } else if (dashboardCtrl.isSearch ==
                                            true) {
                                          dashboardCtrl.isSearch = false;
                                          dashboardCtrl.userText.text = "";

                                          dashboardCtrl.update();

                                        } else {
                                          SystemNavigator.pop();

                                        }
                                      },
                                      child: dashboardCtrl.bottomList.isNotEmpty
                                          ? DashboardBody(
                                              snapshot: snapshot,
                                              pref: dashboardCtrl.pref,
                                            )
                                          :Scaffold(
                                          backgroundColor: appCtrl.appTheme.primary,
                                          body: Center(
                                              child: Image.asset(
                                                imageAssets.splashIcon, // replace your Splashscreen icon
                                                width: Sizes.s210,
                                              )))
                                    );
                                  })
                              :Scaffold(
                              backgroundColor: appCtrl.appTheme.primary,
                              body: Center(
                                  child: Image.asset(
                                    imageAssets.splashIcon, // replace your Splashscreen icon
                                    width: Sizes.s210,
                                  )));
                        }),
                  ),
                ));
              });
            });
          });
        }));
  }
}
