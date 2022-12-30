import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/config.dart';

final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
    ? Get.find<PermissionHandlerController>()
    : Get.put(PermissionHandlerController());

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

  @override
  void onReady() async{
    // TODO: implement onReady
    final data = appCtrl.storage.read("user");
    currentUserId = data["id"];
    user = data;
    update();
    contactList =   await permissionHandelCtrl.getContact();
    notificationCtrl.configLocalNotification();
    notificationCtrl.registerNotification();
    update();
    super.onReady();
  }

  //add status
  addStatus(File file) async {
    isLoading = true;
    update();
    imageUrl = await pickerCtrl.uploadImage(file);
    update();
    await StatusFirebaseApi().addStatus(imageUrl);
    isLoading = false;
    update();
  }

//get status of user according to contact in firebase
  Future getStatus() async {
    List<Status> statusData = [];
    try {
      statusData = await getStatusList(contactList);
      log("new : $statusData");
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
