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
  List contactExistList = [];
  int unSeen = 0;
  bool isLoading = false;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String? groupId;
  Image? contactPhoto;
  XFile? imageFile;
  File? image;
  List selectedContact = [];
  final notificationCtrl = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onReady() async {
    // TODO: implement onReady
    final data = appCtrl.storage.read(session.user);
    if(data != null) {
      currentUserId = data["id"];
      storageUser = data;
    }
    update();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser!;
    currentUser = user;
    update();
    contactList = await MessageFirebaseApi().getUser();
    contactExistList = await MessageFirebaseApi().getExistUser();
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

}
