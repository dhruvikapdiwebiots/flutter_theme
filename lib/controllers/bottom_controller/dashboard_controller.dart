import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/common_controller/ad_controller.dart';
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

 Stream onSearch(val)  {

    return FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(messageCtrl.currentUserId)
        .collection(collectionName.chats).where("name",isEqualTo: val)
        .orderBy("updateStamp", descending: true)
        .limit(15)
        .snapshots() ;

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
      update();
    });
    user = appCtrl.storage.read(session.user);
    appCtrl.update();
    //statusCtrl.update();
    update();
   // await Future.delayed(Durations.s3);
    checkPermission();
    //checkContactList();
    super.onReady();
  }

  checkPermission() async {
    bool permissionStatus =
        await statusCtrl.permissionHandelCtrl.permissionGranted();
    debugPrint("permissionStatus 1: $permissionStatus");
    if (permissionStatus == true) {
      contacts = await getAllContacts();

      appCtrl.contactList = contacts;
      appCtrl.storage.write(session.contactList, contacts);
      appCtrl.update();
      debugPrint("PERR : ${appCtrl.contactList.length}");
     await checkContactList();

      if (appCtrl.contactList.isNotEmpty) {
        final contactCtrl = Get.isRegistered<ContactListController>()
            ? Get.find<ContactListController>()
            : Get.put(ContactListController());
        contactCtrl.onReady();
        contactCtrl.update();
        Get.forceAppUpdate();

      }
    }
  }

  checkContactList() async {
    appCtrl.userContactList = [];
    appCtrl.firebaseContact = [];
    appCtrl.update();

    debugPrint("appCtrl.user : ${appCtrl.user}");
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
                  appCtrl.firebaseContact.add(users.value);
                }
              }
            });
          }
          appCtrl.update();
        });
      }
    });
    await addDataInList(0);
    if (appCtrl.contactList.isNotEmpty) {
      contactCtrl.onReady();
      contactCtrl.update();
    }
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

    messageCtrl.onReady();
    statusCtrl.onReady();
    statusCtrl.update();
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
    }else if(value ==3) {

      await FirebaseFirestore.instance
          .collection("calls")
          .doc(user["id"])
          .collection("collectionCallHistory")
          .get()
          .then((value) {
        value.docs
            .asMap()
            .entries
            .forEach((element) {
          FirebaseFirestore.instance
              .collection("calls")
              .doc(user["id"])
              .collection("collectionCallHistory")
              .doc(element.value.id)
              .delete();
        });
      });

    }else {
      Get.toNamed(routeName.setting);
    }
  }

  addDataInList(pageKey)async{
    var user = appCtrl.storage.read(session.user);

    if (appCtrl.contactList.isNotEmpty) {
      appCtrl.contactList
          .where((c) => c.phones.isNotEmpty)
          .forEach((Contact p) async {
        if (p.phones.isNotEmpty) {
          nameList = [];

          String phone = phoneNumberExtension(p.phones[0].number);

          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .where("phone", isEqualTo: phone)
              .limit(1)
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              nameList = [];

              update();
              UserContactModel userContactModel = UserContactModel(
                isRegister: true,
                phoneNumber: phone,
                uid: value.docs[0].data()["id"],
                image: value.docs[0].data()["image"],
                username: value.docs[0].data()["name"],
                description: value.docs[0].data()["statusDesc"],
              );

              registerContactList!
                  .removeWhere((element) => element.phoneNumber == phone);
              update();
              if (phone != user["phone"]) {
                if (!registerContactList!.contains(userContactModel)) {
                  registerContactList!.add(userContactModel);
                }
              }
              update();

              nameList!.add(userContactModel);

            } else {
              UserContactModel userContactModel = UserContactModel(
                  isRegister: false,
                  phoneNumber: phone,
                  contactImage: p.photo,
                  uid: "0",
                  username: p.displayName);
              unRegisterContactList!
                  .removeWhere((element) => element.phoneNumber == phone);
              if (!unRegisterContactList!.contains(userContactModel)) {
                unRegisterContactList!.add(userContactModel);
              }
              nameList!.add(userContactModel);
            }
          });
          update();
        }
      });
    }


    contactList = [];
    counter++;
    ContactModel contactModel = ContactModel(
        title: fonts.registerUser.tr, userTitle: registerContactList);
    if (!contactList.contains(contactModel)) {
      contactList.add(contactModel);
    }

    ContactModel unRegisterContactModel = ContactModel(
        title: fonts.inviteUser.tr, userTitle: unRegisterContactList);
    if (!contactList.contains(unRegisterContactModel)) {
      contactList.add(unRegisterContactModel);
    }

  }


/*  //search contact list
  searchList(pageKey, search) async {
    if (search != "" && search != null) {
      try {
        searchContactList = [];
        update();
        debugPrint("nameList : ${nameList!.length}");
        List<ContactModel> filter = [];
        contactList.asMap().entries.forEach((element) {


          element.value.userTitle!.asMap().entries.forEach((contact) {
            if (contact.value.username!.toLowerCase().contains(search)) {
              if (!searchContactList!.contains(contact.value)) {
                searchContactList!.add(contact.value);
                update();
              }

            }
          });

          update();
        });

        ContactModel unRegisterContactModel = ContactModel(
            title: "Invite User for use Chatter", userTitle: searchContactList);
        filter.add(unRegisterContactModel);
        final isLastPage = filter.length < pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(filter);
        } else {
          final nextPageKey = pageKey + filter.length;
          pagingController.appendPage(filter, nextPageKey);
        }
      } catch (error) {
        pagingController.error = error;
      }
      update();
      debugPrint("pagingController : ${pagingController.itemList!.length}");
    } else {
      fetchPage(0);
    }
  }*/
}
