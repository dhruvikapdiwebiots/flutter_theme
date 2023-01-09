import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_theme/config.dart';


class StatusController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  List<Contact> contactList = [];
  String? groupId, currentUserId, imageUrl;
  Image? contactPhoto;
  dynamic user;
  XFile? imageFile;
  File? image;
  bool isLoading = false;
  List selectedContact = [];
  Stream<QuerySnapshot>? stream;
  final notificationCtrl = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());

  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  @override
  void onReady() async{
    // TODO: implement onReady
    final data = appCtrl.storage.read(session.user) ?? "";
    if(data != "") {
      currentUserId = data["id"];
      user = data;
    }
    update();
    contactList =   await permissionHandelCtrl.getContact();
    update();
    super.onReady();
  }

// Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //add status
  addStatus(File file,StatusType statusType) async {
    isLoading = true;
    update();
    imageUrl = await pickerCtrl.uploadImage(file);
    update();
    log("imageUrl : $imageUrl");
    await StatusFirebaseApi().addStatus(imageUrl,statusType.name);
    isLoading = false;
    update();
  }

//get status of user according to contact in firebase
  Future getStatus() async {
    log("us : ${appCtrl.storage.read(session.user)}");
    List<Status> statusData = [];
    try {
      statusData = await getStatusList(contactList);

    } catch (e) {
      log("message : $e");
    }
    return statusData;
  }

  //get status list
  Future<List<Status>>  getStatusList(List<Contact> contacts) async {
    List<Status> statusData = [];
    statusData = await StatusFirebaseApi().getStatusUserList(contacts);
    return statusData;
  }
}
