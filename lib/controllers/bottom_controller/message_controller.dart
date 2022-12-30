import 'dart:developer';
import 'dart:io';
import 'package:flutter_theme/config.dart';

class MessageController extends GetxController {
  String? currentUserId;
  GoogleSignIn googleSignIn = GoogleSignIn();
  User? currentUser;
  dynamic storageUser;
  bool isHomePageSelected = true;
  List contactList = [];
  List<Contact> contactUserList = [];
  bool isLoading = false;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String? groupId;
  Image? contactPhoto;
  XFile? imageFile;
  File? image;
  List selectedContact = [];
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());
  final notificationCtrl = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onReady() async {
    // TODO: implement onReady
    final data = appCtrl.storage.read("user");
    if(data != null) {
      currentUserId = data["id"];
      storageUser = data;
    }
    update();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    contactUserList =   await permissionHandelCtrl.getContact();

    currentUser = user;
    update();
    notificationCtrl.configLocalNotification();
    notificationCtrl.registerNotification();
    contactList = await MessageFirebaseApi().getUser();
    update();
    super.onReady();
  }

  // BOTTOM TAB LAYOUT ICON CLICKED
  void onBottomIconPressed(int index) {
    if (index == 0 || index == 1) {
      isHomePageSelected = true;
      update();
    } else {
      isHomePageSelected = false;
      update();
    }
  }

  //on back
  Future<bool> onWillPop() async {
    return (await showDialog(
          context: Get.context!,
          builder: (context) => const AlertBack(),
        )) ??
        false;
  }

  Future getMessage() async {
    List statusData = [];
    try {
      statusData = await MessageFirebaseApi().getContactList(contactUserList);
    } catch (e) {
      log("message list : $e");
    }
    return statusData;
  }

  //pick up contact and check if mobile exist
  saveContactInChat() async {
    // Add your onPressed code here!
    List<Contact> contacts = await permissionHandelCtrl.getContact();
    Get.toNamed(routeName.contactList,arguments: contacts)!.then((value) async {
      MessageFirebaseApi().saveContact(value);
    });
  }
}
