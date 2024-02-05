import 'dart:async';
import 'dart:developer';
import 'package:country_codes/country_codes.dart';
import 'package:timezone/data/latest.dart' as tz;
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
if(appCtrl.cachedModel != null) {
  messageCtrl.message =
      MessageFirebaseApi().chatListWidget(appCtrl.cachedModel!.userData);
  log("message = : ${messageCtrl.message}");
  messageCtrl.update();
}
    final addCtrl = Get.isRegistered<AdController>()
        ? Get.find<AdController>()
        : Get.put(AdController());
    addCtrl.onInit();
    await Future.delayed(DurationClass.ms150);
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
fetchLan();
await CountryCodes.init();
fetch();
    update();
    // await Future.delayed(DurationClass.s3);

    //checkContactList();
    await Future.delayed(DurationClass.s3);
    statusCtrl.getAllStatus();
    super.onReady();
  }

  fetchLan() async {
    final lan = Get.isRegistered<LanguageController>()
        ? Get.find<LanguageController>()
        : Get.put(LanguageController());
    lan.getLanguageList();
  }

  fetch() async {
    final Locale systemLocales =
        WidgetsBinding.instance.platformDispatcher.locale;
    log("LOCAKE : $systemLocales");
    final CountryDetails deviceLocale = CountryCodes.detailsForLocale();
    log("LOCAKE : ${deviceLocale.localizedName}");
    tz.initializeTimeZones();

    /*var detroit = tz.getLocation(deviceLocale.localizedName!);
    var now = tz.TZDateTime.now(detroit);
    var timeZone = detroit.timeZone(now.millisecondsSinceEpoch);
    log("timeZone : $timeZone");
    log("timeZone : $now");*/
  }


  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    super.dispose();
  }

  onMenuItemSelected(int value) async {
    debugPrint("value ss: $value");
    debugPrint("value ss: $pref");
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
      final settingCtrl = Get.isRegistered<SettingController>()
          ? Get.find<SettingController>()
          : Get.put(SettingController());
      Get.toNamed(routeName.setting,arguments: pref);
      settingCtrl.onReady();
    }
  }
}
