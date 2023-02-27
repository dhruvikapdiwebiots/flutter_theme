import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int selectedPopTap = 0;
  TabController? controller;
  late int iconCount = 0;
  List<Contact> contacts = [];
  List bottomList = [];
  dynamic user;

  final settingCtrl = Get.isRegistered<SettingController>()
      ? Get.find<SettingController>()
      : Get.put(SettingController());
  final contactCtrl = Get.isRegistered<ContactListController>()
      ? Get.find<ContactListController>()
      : Get.put(ContactListController());

  final messageCtrl = Get.isRegistered<MessageController>()
      ? Get.find<MessageController>()
      : Get.put(MessageController());

  final statusCtrl = Get.isRegistered<StatusController>()
      ? Get.find<StatusController>()
      : Get.put(StatusController());

  List actionList = [];
  List statusAction = [];
  List callsAction = [];
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

//list of bottommost page
  List<Widget> widgetOptions = <Widget>[
    const Message(),
    const StatusList(),
    CallList()
  ];

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    return updateConnectionStatus(result);
  }

  Future<void> updateConnectionStatus(ConnectivityResult result) async {
    connectionStatus = result;
    update();
  }

  //on tap select
  onTapSelect(val) async {

    selectedIndex = val;

    update();
  }

  onChange(val) async {

    selectedIndex = val;

    update();
  }

  @override
  void onReady() async {
    // TODO: implement onReady

    bottomList = appArray.bottomList;
    actionList = appArray.actionList;
    statusAction = appArray.statusAction;
    callsAction = appArray.callsAction;
    controller = TabController(length: bottomList.length, vsync: this);
    firebaseCtrl.setIsActive();
    controller!.addListener(() {
      selectedIndex = controller!.index;
      update();
    });
    user = appCtrl.storage.read(session.user);

    update();
    super.onReady();
  }

  popupMenuTap(value) {
    if (selectedPopTap == 0) {
      Get.toNamed(routeName.groupChat, arguments: false);
    } else if (selectedPopTap == 1) {
      Get.toNamed(routeName.groupChat, arguments: true);
    } else if (selectedPopTap == 2) {
      Get.toNamed(routeName.setting);
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    contactCtrl.onInit();
    messageCtrl.onReady();
    statusCtrl.onReady();
    super.onInit();
  }
}
