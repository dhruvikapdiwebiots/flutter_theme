import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/common_controller/ad_controller.dart';
import 'package:flutter_theme/controllers/recent_chat_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  SharedPreferences? pref;
  List<Contact> storageContact = [];

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

  List<Widget> widgetOptions(prefs) {
    return [Message(sharedPreferences: prefs), const StatusList(), CallList()];
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status : $e');
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

  recentMessageSearch() async {
    if (userText.text.isNotEmpty) {
      appCtrl.isSearch = true;
      appCtrl.update();
    } else {
      appCtrl.isSearch = false;
      appCtrl.update();
    }
    final RecentChatController recentChatController =
        Provider.of<RecentChatController>(Get.context!, listen: false);
    recentChatController.getMessageList(name: userText.text);
  }

  statusSearch() async {
    await statusCtrl.getAllStatus(search: userText.text);
    statusCtrl.update();
  }

  Stream onSearch(val) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? snapshots = FirebaseFirestore
        .instance
        .collection(collectionName.calls)
        .doc(appCtrl.user["id"])
        .collection(collectionName.collectionCallHistory)
        .where("callerName", isEqualTo: val)
        .orderBy("timestamp", descending: true)
        .snapshots();
    return snapshots;
  }

  Stream callData(val) {
    Stream<QuerySnapshot<Map<String, dynamic>>>? snapshots = FirebaseFirestore
        .instance
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

    messageCtrl.message =
        MessageFirebaseApi().chatListWidget(appCtrl.cachedModel!.userData);
    log("message = : ${messageCtrl.message}");
    messageCtrl.update();
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
      if (controller!.index == 1) {
        statusCtrl.getAllStatus();
      }
    });
    user = appCtrl.storage.read(session.user);
    appCtrl.update();
    //statusCtrl.update();
    update();
    // await Future.delayed(Durations.s3);

    //checkContactList();
    await Future.delayed(Durations.s3);
    statusCtrl.getAllStatus();
    super.onReady();
  }

  checkPermission() async {
    Completer<Map<String?, String?>> completer =
        Completer<Map<String?, String?>>();

    appCtrl.contactPermission =
        appCtrl.storage.read(session.contactPermission) ?? false;
    debugPrint("CHECK PERMISSION :: ${appCtrl.contactPermission}");
    if (appCtrl.contactPermission == false) {
      final permissionHandelCtrl =
          Get.isRegistered<PermissionHandlerController>()
              ? Get.find<PermissionHandlerController>()
              : Get.put(PermissionHandlerController());
      bool permissionStatus = await permissionHandelCtrl.permissionGranted();
      appCtrl.contactPermission = permissionStatus;
      appCtrl.storage.write(session.contactPermission, permissionStatus);
      checkPermission();
    } else {
      appCtrl.update();
      debugPrint("appCtrl.contactPermission: ${appCtrl.contactPermission}");
      if (appCtrl.contactPermission == true) {
        await FlutterContacts.getContacts(
                withPhoto: true, withProperties: true, withThumbnail: true)
            .then((contacts) async {
          appCtrl.contactList = contacts;
          appCtrl.update();

          contacts.where((c) => c.phones.isNotEmpty).forEach((Contact p) {
            if (p.displayName.isNotEmpty && p.phones.isNotEmpty) {
              List<String?> numbers = p.phones
                  .map((number) {
                    String? phone =
                        phoneNumberExtension(number.normalizedNumber);

                    return phone;
                  })
                  .toList()
                  .where((s) => s.isNotEmpty)
                  .toList();

              numbers.asMap().entries.forEach((number) {
                appCtrl.cachedContacts[number.value] = p.displayName;
              });
              appCtrl.update();
            }
          });
          completer.complete(appCtrl.cachedContacts);
          update();
          completer.future.then((c) {
            appCtrl.allContacts = c;
          });
          appCtrl.update();
          appCtrl.storage.write(session.contactList, appCtrl.contactList);
          appCtrl.update();
          checkContactList();

          debugPrint("PERR : ${appCtrl.contactList.length}");
          debugPrint("PERR : ${appCtrl.allContacts}");
        });
      }
    }
  }

  addContactInFirebase() async {
    if (appCtrl.contactList.isNotEmpty) {
      List<Map<String, dynamic>> contactsData = [];
      List<Map<String, dynamic>> unRegisterContactData = [];

      appCtrl.contactList.asMap().entries.forEach((contact) async {
        bool isRegister = false;
        String id = "", name = "";
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
            name = value.docs[0].data()["name"];
          }
        });
        update();
        if (isRegister) {
          var objData = {
            'name': name,
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
    }

    /*  if (appCtrl.firebaseContact.isEmpty) {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.registerUser)
          .get()
          .then((value) {
        List allUserList = value.docs[0].data()["contact"];
        allUserList.asMap().entries.forEach((element) {
          if (!appCtrl.firebaseContact.contains(element.value)) {
            appCtrl.firebaseContact
                .add(FirebaseContactModel.fromJson(element.value));
          }
        });
      });
      appCtrl.update();
    }*/
  }

  checkContactList() async {
    appCtrl.availableContact = [];

    debugPrint("FILTERD :: ${appCtrl.allContacts!.length}");
    if (appCtrl.allContacts!.isNotEmpty) {
      appCtrl.allContacts!.forEach((key, value) async {
        await FirebaseFirestore.instance
            .collection(collectionName.users)
            .where("phone", isEqualTo: key)
            .get()
            .then((docs) async {
          if (docs.docs.isNotEmpty) {
            // print('FOUND CONTACT $key');

            appCtrl.availableContact.add(JoinedUserModel(
                phone: docs.docs[0].data()["phone"] ?? '',
                name: value ?? docs.docs[0].data()["name"],
                id: docs.docs[0].id));
            debugPrint("FOUND CONTACY : ${docs.docs.length}");
            appCtrl.update();
          }
        });
      });
      appCtrl.update();
      Get.forceAppUpdate();
    } else {
      checkPermission();
    }
    debugPrint("appCtrl.availableContact : ${appCtrl.availableContact.length}");
/*    appCtrl.userContactList = [];
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
    update();*/
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    super.dispose();
  }

  onMenuItemSelected(int value) async {
    debugPrint("value : $value");
    selectedPopTap = value;
    update();

    if (value == 0) {
      debugPrint("CONTACT LIST IS EMPTY : ${appCtrl.contactList.isEmpty}");
      if (appCtrl.contactList.isEmpty) {
        Get.toNamed(routeName.groupChat, arguments: false);

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
      final groupChatCtrl = Get.isRegistered<CreateGroupController>()
          ? Get.find<CreateGroupController>()
          : Get.put(CreateGroupController());
      groupChatCtrl.isGroup = true;
      groupChatCtrl.isAddUser = false;

      //   groupChatCtrl.refreshContacts();

      Get.back();
      Get.toNamed(routeName.groupChat, arguments: true);
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
