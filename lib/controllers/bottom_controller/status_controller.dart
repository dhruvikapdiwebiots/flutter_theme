import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_theme/config.dart';

final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
    ? Get.find<PermissionHandlerController>()
    : Get.put(PermissionHandlerController());

class StatusController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  List<Contact>? contactList;
  String? groupId, currentUserId, imageUrl;
  Image? contactPhoto;
  dynamic user;
  XFile? imageFile;
  File? image;
  List selectedContact = [];
  Stream<QuerySnapshot>? stream;
  final notificationCtrl = Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());

  @override
  void onReady() {
    // TODO: implement onReady
    final data = appCtrl.storage.read("user");
    currentUserId = data["id"];
    user = data;
    update();

    notificationCtrl.configLocalNotification();
    notificationCtrl.registerNotification();
    update();
    super.onReady();
  }

  //add status
  addStatus(File file) async {
    imageUrl = await pickerCtrl.uploadImage(file);
    await StatusFirebaseApi().addStatus(imageUrl);
  }

//get status of user according to contact in firebase
  Future getStatus() async {
    List<Status> statusData = [];
    try {
      await permissionHandelCtrl.getContact();
      contactList = appCtrl.storage.read(session.contactList);
      statusData = await getStatusList(contactList!);
      log("new : $statusData");
    } catch (e) {
      log("message : $e");
    }
    return statusData;
  }

  //get status list
  getStatusList(List<Contact> contacts) async {
    List<Status> statusData = [];
    statusData = await StatusFirebaseApi().getStatusUserList(contacts);
    log("statusData : $statusData");
    return statusData;
  }
}
