import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/common_controller/ad_controller.dart';
import 'package:flutter_theme/models/firebase_contact_model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int selectedPopTap = 0;
  TabController? controller;
  late int iconCount = 0;
  Timer? timer;
  List<Contact> contacts = [];
  List bottomList = [];
  bool isLoading = true;
  bool isSearch = false;
  int counter = 0;

  List<ContactModel> contactList = [];
  List<UserContactModel>? searchContactList = [];
  List<UserContactModel>? registerContactList = [];
  List<UserContactModel>? unRegisterContactList = [];
  List<Contact> storageContact = [];
  List<UserContactModel>? nameList = [];

  TextEditingController searchText = TextEditingController();
  TextEditingController userText = TextEditingController();

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
      debugPrint('Couldn\'t check connectivity status');
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
      /* if (appCtrl.contactList.isEmpty) {
        await checkPermission();
        checkContactList();
      }*/
    }
  }

  Stream onSearch(val) {
    if (selectedIndex == 0) {
      return FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.chats)
          .where("name", isEqualTo: val)
          .limit(15)
          .snapshots();
    } else if (selectedIndex == 1) {
      return FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(messageCtrl.currentUserId)
          .collection(collectionName.chats)
          .where("name", isEqualTo: val)
          .orderBy("updateStamp", descending: true)
          .limit(15)
          .snapshots();
    } else {
      Stream<QuerySnapshot<Map<String, dynamic>>>? snapshots =FirebaseFirestore.instance
          .collection(collectionName.calls)
          .doc(appCtrl.user["id"])
          .collection(collectionName.collectionCallHistory)

          .where("callerName", isEqualTo: val)
          .orderBy("timestamp", descending: true)
          .snapshots();
      return snapshots;
    }
  }

  Stream callData(val){
    Stream<QuerySnapshot<Map<String, dynamic>>>? snapshots =FirebaseFirestore.instance
        .collection(collectionName.calls)
        .doc(appCtrl.user["id"])
        .collection(collectionName.collectionCallHistory)
        .where("callerName", isEqualTo: val)
        .orderBy("timestamp", descending: true)
        .snapshots();
    return snapshots;
  }

  @override
  void onReady() async {
    // TODO: implement onReady

    final addCtrl = Get.isRegistered<AdController>()
        ? Get.find<AdController>()
        : Get.put(AdController());
    addCtrl.onInit();
    await Future.delayed(Durations.ms150);
    bottomList = appArray.bottomList;
    actionList = appArray.actionList;
    statusAction = appArray.statusAction;
    callsAction = appArray.callsAction;
    controller = TabController(length: bottomList.length, vsync: this);
    firebaseCtrl.setIsActive();
    controller!.addListener(() {
      selectedIndex = controller!.index;

    });
    user = appCtrl.storage.read(session.user);
    appCtrl.update();
    //statusCtrl.update();
    update();
    // await Future.delayed(Durations.s3);
    //checkPermission();
    //checkContactList();
    super.onReady();
  }

  checkPermission() async {

appCtrl.contactPermission = appCtrl.storage.read(session.contactPermission) ?? false;
    if (appCtrl.contactPermission == true) {
      contacts = await getAllContacts();

      appCtrl.contactList = contacts;
      appCtrl.storage.write(session.contactList, contacts);
      appCtrl.update();
      debugPrint("PERR : ${appCtrl.contactList.length}");
      await checkContactList();

      if (appCtrl.contactList.isNotEmpty) {
        await addContactInFirebase();
       await getFirebaseContact();


        contactCtrl.update();
        Get.forceAppUpdate();
      }
    }else{
      log("NO PERMISSION");
      appCtrl.contactPermission =
      await statusCtrl.permissionHandelCtrl.permissionGranted();
      appCtrl.storage.write(session.contactPermission,appCtrl.contactPermission);
      if(appCtrl.contactPermission == true){
        appCtrl.contactList = await getAllContacts();

      }
      appCtrl.update();

    }
  }

  addContactInFirebase() async {
    if (appCtrl.contactList.isNotEmpty) {
      List<Map<String, dynamic>> contactsData = [];
      List<Map<String, dynamic>> unRegisterContactData = [];

      appCtrl.contactList.asMap().entries.forEach((contact) async {
        if(phoneNumberExtension(
            contact.value.phones[0].number.toString()) != appCtrl.user["phone"]) {
          if (contact.value.phones.isNotEmpty) {
            bool isRegister = false;
            String id = "";
            await FirebaseFirestore.instance
                .collection(collectionName.users)
                .where("phone",
                isEqualTo: phoneNumberExtension(
                    contact.value.phones[0].number.toString()))
                .get()
                .then((value) {
              if (value.docs.isEmpty) {
                isRegister = false;
              } else {
                isRegister = true;
                id = value.docs[0].id;
              }
            });
            update();
            if (isRegister) {
              var objData = {
                'name': contact.value.displayName,
                'phone': contact.value.phones.isNotEmpty
                    ? phoneNumberExtension(
                    contact.value.phones[0].number.toString())
                    : null,
                "isRegister": true,
                "image": contact.value.photo,
                "id": id
                // Include other necessary contact.value details
              };
              if (!contactsData.contains(objData)) {
                contactsData.add(objData);
              }
            } else {

              var objData = {
                'name': contact.value.displayName,
                'phone': contact.value.phones.isNotEmpty
                    ? phoneNumberExtension(
                    contact.value.phones[0].number.toString())
                    : null,
                "isRegister": false,
                "image": contact.value.photo,
                "id": "0"
                // Include other necessary contact.value details
              };
              if (!unRegisterContactData.contains(objData)) {
                unRegisterContactData.add(objData);
              }
            }
          }
        }
      });

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.registerUser)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {

          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(appCtrl.user["id"])
              .collection(collectionName.registerUser)
              .add({"contact": contactsData});
        } else {

          log("ALREADY COLLECTION");
        }
      });

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.unRegisterUser)
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {

          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(appCtrl.user["id"])
              .collection(collectionName.unRegisterUser)
              .add({"contact": unRegisterContactData});
        } else {
          log("ALREADY COLLECTION");
        }
      });

      contactCtrl.onReady();
      contactCtrl.update();
    }else{
      checkPermission();
    }


  }

  getFirebaseContact() async {

    final contactCtrl = Get.isRegistered<ContactListController>()
        ? Get.find<ContactListController>()
        : Get.put(ContactListController());
    contactCtrl.getAllData();
    contactCtrl.getAllUnRegisterUser();
    contactCtrl.onReady();

  }

  checkContactList() async {
    appCtrl.userContactList = [];
    appCtrl.firebaseContact = [];
    appCtrl.update();


    appCtrl.user = await appCtrl.storage.read(session.user);
    appCtrl.update();
    debugPrint("appCtrl.users : ${appCtrl.user}");
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .get()
        .then((value) async {
      if (appCtrl.contactList.isNotEmpty) {
        value.docs.asMap().entries.forEach((users) {
          if (users.value["phone"] != appCtrl.user["phone"]) {
            appCtrl.contactList.asMap().entries.forEach((element) {
              if (element.value.phones.isNotEmpty) {
                if (users.value.data()["phone"] ==
                    phoneNumberExtension(
                        element.value.phones[0].number.toString())) {
                  appCtrl.userContactList.add(element.value);
                }
              }
            });
          }
          appCtrl.update();
        });
      }
    });

    debugPrint("appCtrl.userContactList : ${appCtrl.userContactList}");
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

    // messageCtrl.onReady();
    // statusCtrl.onReady();
    // statusCtrl.update();

    super.onInit();
  }

  onMenuItemSelected(int value) async {
    debugPrint("value : $value");
    selectedPopTap = value;
    update();

    if (value == 0) {
      debugPrint("CONTACT LIST IS EMPTY : ${appCtrl.contactList.isEmpty}");
      if (appCtrl.contactList.isEmpty) {
        Get.toNamed(routeName.groupChat, arguments: false);
        await checkPermission();
        await checkContactList();
        final groupChatCtrl = Get.isRegistered<CreateGroupController>()
            ? Get.find<CreateGroupController>()
            : Get.put(CreateGroupController());
        groupChatCtrl.isGroup = false;
        groupChatCtrl.isAddUser = false;

        groupChatCtrl.refreshContacts();
        Get.toNamed(routeName.groupChat, arguments: false);
      } else {
        final groupChatCtrl = Get.isRegistered<CreateGroupController>()
            ? Get.find<CreateGroupController>()
            : Get.put(CreateGroupController());
        groupChatCtrl.isGroup = false;
        groupChatCtrl.isAddUser = false;
        if (groupChatCtrl.contactList.isEmpty) {
          groupChatCtrl.getFirebaseContact();
        }
        Get.toNamed(routeName.groupChat, arguments: false);
      }
    } else if (value == 1) {
      if (appCtrl.contactList.isEmpty) {
        await checkPermission();
        await checkContactList();
        final groupChatCtrl = Get.isRegistered<CreateGroupController>()
            ? Get.find<CreateGroupController>()
            : Get.put(CreateGroupController());
        groupChatCtrl.isGroup = false;
        groupChatCtrl.isAddUser = false;

        groupChatCtrl.refreshContacts();

        Get.back();
        Get.toNamed(routeName.groupChat, arguments: true);
      } else {
        final groupChatCtrl = Get.isRegistered<CreateGroupController>()
            ? Get.find<CreateGroupController>()
            : Get.put(CreateGroupController());
        groupChatCtrl.isGroup = false;
        groupChatCtrl.isAddUser = false;
        if (groupChatCtrl.contactList.isEmpty) {
          groupChatCtrl.getFirebaseContact();
        }
        Get.toNamed(routeName.groupChat, arguments: true);
      }
    } else if (value == 3) {
      await FirebaseFirestore.instance
          .collection("calls")
          .doc(user["id"])
          .collection("collectionCallHistory")
          .get()
          .then((value) {
        value.docs.asMap().entries.forEach((element) {
          FirebaseFirestore.instance
              .collection("calls")
              .doc(user["id"])
              .collection("collectionCallHistory")
              .doc(element.value.id)
              .delete();
        });
      });
    } else {
      Get.toNamed(routeName.setting);
    }
  }


}
