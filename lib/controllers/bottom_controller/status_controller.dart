import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_theme/pages/bottom_pages/message/layout/group_message_card.dart';
import 'package:flutter_theme/pages/bottom_pages/message/layout/receiver_message_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_theme/config.dart';

class StatusController extends GetxController {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  String? groupId, currentUserId, imageUrl;
  Image? contactPhoto;
  dynamic user;
  XFile? imageFile;
  File? image;
  List selectedContact = [];
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());
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

    update();
    notificationCtrl.configLocalNotification();
    notificationCtrl.registerNotification();
    update();
    super.onReady();
  }

  addStatus(File file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    imageUrl = downloadUrl;

    List<String> statusImageUrls = [];
    var statusesSnapshot = await FirebaseFirestore.instance
        .collection('status')
        .where(
          'uid',
          isEqualTo: currentUserId,
        )
        .get();

  print("object : ${statusesSnapshot.docs.isNotEmpty}");
    if (statusesSnapshot.docs.isNotEmpty) {
      Status status = Status.fromMap(statusesSnapshot.docs[0].data());
      statusImageUrls = status.photoUrl;
      statusImageUrls.add(imageUrl!);
      await FirebaseFirestore.instance
          .collection('status')
          .doc(statusesSnapshot.docs[0].id)
          .update({
        'photoUrl': statusImageUrls,
      });
      return;
    } else {
      statusImageUrls = [imageUrl!];
    }
    print("statusImageUrls : $statusImageUrls");
    Status status = Status(
        username: user["name"],
        phoneNumber: user["phone"],
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: user["image"],
        uid: currentUserId!);

    await FirebaseFirestore.instance.collection('status').add(status.toMap());
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    var file = File(imageFile!.path);
    image = File(imageFile!.path);
    UploadTask uploadTask = reference.putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    imageUrl = downloadUrl;
    update();
  }

  getStatus() async {
    dynamic snapShot;
    try {
      PermissionStatus permissionStatus =
          await permissionHandelCtrl.getContactPermission();
      if (permissionStatus == PermissionStatus.granted) {
        List<Contact> contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: false));
        for (int i = 0; i < contacts.length; i++) {
          String phone = contacts[i].phones![0].value.toString();
          if (phone.length > 10) {
            if (phone.contains(" ")) {
              phone = phone.replaceAll(" ", "");
            }
            if (phone.contains("-")) {
              phone = phone.replaceAll("-", "");
            }
            if (phone.contains("+")) {
              phone = phone.replaceAll("+91", "");
            }
          }
          snapShot = FirebaseFirestore.instance
              .collection('status')
              .where("phone", isEqualTo: phone)
              .orderBy("timestamp", descending: true)
              .get();
          print(snapShot);
        }
      }
    } catch (e) {
      log("message : $e");
    }
    return snapShot;
  }
}




class Status {
  final String uid;
  final String username;
  final String phoneNumber;
  final List<String> photoUrl;
  final DateTime createdAt;
  final String profilePic;

  Status({
    required this.uid,
    required this.username,
    required this.phoneNumber,
    required this.photoUrl,
    required this.createdAt,
    required this.profilePic,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'profilePic': profilePic,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: List<String>.from(map['photoUrl']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      profilePic: map['profilePic'] ?? '',
    );
  }
}
