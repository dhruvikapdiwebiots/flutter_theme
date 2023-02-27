import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_theme/config.dart';

class StatusController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  List<Contact> contactList = [];
  List<Contact> userContactList = [];
  List<Status> status = [];
  String? groupId, currentUserId, imageUrl;
  Image? contactPhoto;
  dynamic user;
  XFile? imageFile;
  File? image;
  bool isLoading = false;
  List selectedContact = [];
  Stream<QuerySnapshot>? stream;
  List<Status> statusListData = [];
  List<Status> statusData = [];
  DateTime date = DateTime.now();
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());

  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  @override
  void onReady() async {
    // TODO: implement onReady
    final data = appCtrl.storage.read(session.user) ?? "";
    if (data != "") {
      currentUserId = data["id"];
      user = data;
    }
    update();

    contactList = await permissionHandelCtrl.getContact();
    FirebaseFirestore.instance.collection(collectionName.users).get().then((value) {
      debugPrint("coooo : ${value.docs.length}" );
      value.docs.asMap().entries.forEach((user) {
        contactList.asMap().entries.forEach((element) {
          if(user.value.data()["phone"] == phoneNumberExtension(element.value.phones[0].number.toString())){
            userContactList.add(element.value);
          }
          update();
        });
      });
    });
    debugPrint("contactList : $userContactList");
    update();
    super.onReady();
  }

// Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  //add status
  addStatus(File file, StatusType statusType) async {
    isLoading = true;
    update();
    imageUrl = await pickerCtrl.uploadImage(file);
    update();
    log("imageUrl : $imageUrl");
    await StatusFirebaseApi().addStatus(imageUrl, statusType.name);
    isLoading = false;
    update();
  }

}
