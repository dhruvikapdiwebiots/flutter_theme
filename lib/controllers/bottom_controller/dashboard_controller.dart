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
  Timer? timer;
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
    await Future.delayed(Durations.ms150);
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
    appCtrl.update();
    statusCtrl.update();
    update();
    await checkPermission();
    checkContactList();
    super.onReady();
  }

  checkPermission() async {
    bool permissionStatus =
        await statusCtrl.permissionHandelCtrl.permissionGranted();
    if (permissionStatus) {
      contacts = await getAllContacts();
      appCtrl.contactList = contacts;
      appCtrl.storage.write(session.contactList, contacts);
      appCtrl.update();
    }
  }

  checkContactList() async {
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .get()
        .then((value) {
      log("appCtrl.contactList : ${appCtrl.contactList}");

      value.docs.asMap().entries.forEach((user) {
        appCtrl.contactList.asMap().entries.forEach((element) {
          if (element.value.phones.isNotEmpty) {
            if (user.value.data()["phone"] ==
                phoneNumberExtension(
                    element.value.phones[0].number.toString())) {
              appCtrl.userContactList.add(element.value);
            }
          }
          appCtrl.update();
        });
      });
    });
    log("appCtrl.userContactList : ${appCtrl.userContactList}");
    update();
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
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    super.dispose();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    contactCtrl.onInit();
    statusCtrl.onReady();
    messageCtrl.onReady();
    statusCtrl.onReady();

    statusCtrl.update();
    super.onInit();
  }
}
