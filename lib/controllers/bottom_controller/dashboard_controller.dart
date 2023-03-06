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
    if (val == 1) {
      if (appCtrl.contactList.isEmpty) {
        await checkPermission();
        checkContactList();
      }
    }
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
    await Future.delayed(Durations.s3);
    checkPermission();
    //checkContactList();
    super.onReady();
  }

  checkPermission() async {
    bool permissionStatus =
        await statusCtrl.permissionHandelCtrl.permissionGranted();
    log("permissionStatus 1: $permissionStatus");
    if (permissionStatus) {
      contacts = await getAllContacts();
      appCtrl.contactList = contacts;
      appCtrl.storage.write(session.contactList, contacts);
      appCtrl.update();
      log("PERR : ${appCtrl.contactList.length}");
    }
  }

  checkContactList() async {
    appCtrl.userContactList = [];
    appCtrl.firebaseContact = [];
    appCtrl.update();
    log("appCtrl.contactList : ${appCtrl.firebaseContact}");
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .get()
        .then((value) async {
      log("appCtrl.contactList : ${appCtrl.contactList}");
      if (appCtrl.contactList.isNotEmpty) {
        value.docs.asMap().entries.forEach((users) {
          if (users.value["phone"] != user["phone"]) {
            appCtrl.contactList.asMap().entries.forEach((element) {
              if (element.value.phones.isNotEmpty) {
                if (users.value.data()["phone"] ==
                    phoneNumberExtension(
                        element.value.phones[0].number.toString())) {
                  appCtrl.userContactList.add(element.value);
                  appCtrl.firebaseContact.add(users.value);
                }
              }
            });
          }
          appCtrl.update();
        });
      }
    });

    log("appCtrl.userContactList : ${appCtrl.userContactList}");
    update();
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

  onMenuItemSelected(int value) async {
    log("value : $value");
    selectedPopTap = value;
    update();


    if (value == 0) {
    log("CONTACT LIST IS EMPTY : ${appCtrl.contactList.isEmpty}");
      if (appCtrl.contactList.isEmpty) {
        Get.toNamed(routeName.groupChat, arguments: false);
        await checkPermission();
        await checkContactList();
        final groupChatCtrl =
        Get.isRegistered<CreateGroupController>()
            ? Get.find<CreateGroupController>()
            : Get.put(CreateGroupController());
        groupChatCtrl.isGroup = false;

        groupChatCtrl.refreshContacts();
        Get.toNamed(routeName.groupChat, arguments: false);
      }else{
        final groupChatCtrl =  Get.isRegistered<CreateGroupController>()
            ? Get.find<CreateGroupController>()
            : Get.put(CreateGroupController());
        groupChatCtrl.isGroup = false;
        if(groupChatCtrl.contactList.isEmpty){
          groupChatCtrl.getFirebaseContact();
        }
        Get.toNamed(routeName.groupChat, arguments: false);

      }
    }else if(value ==1){
      if (appCtrl.contactList.isEmpty) {
        await checkPermission();
        await checkContactList();
        final groupChatCtrl =
        Get.isRegistered<CreateGroupController>()
            ? Get.find<CreateGroupController>()
            : Get.put(CreateGroupController());
        groupChatCtrl.isGroup = false;

        groupChatCtrl.refreshContacts();

        Get.back();
        Get.toNamed(routeName.groupChat, arguments: true);
      }else{
        Get.toNamed(routeName.groupChat, arguments: true);
      }
    }else{
      Get.toNamed(routeName.setting);
    }
  }
}
