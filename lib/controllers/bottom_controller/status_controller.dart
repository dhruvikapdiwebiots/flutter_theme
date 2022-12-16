import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_theme/pages/bottom_pages/message/layout/group_message_card.dart';
import 'package:flutter_theme/pages/bottom_pages/message/layout/receiver_message_card.dart';
import 'package:permission_handler/permission_handler.dart';
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

    Status status = Status(
        username: user["name"],
        phoneNumber: user["phone"],
        photoUrl: statusImageUrls,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        profilePic: user["image"],
        uid: currentUserId!,isSeenByOwn:false);

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

//get status of user according to contact in firebase
  Future<List<Status>> getStatus() async {
    List<Status> statusData = [];
    try {
      PermissionStatus permissionStatus =
          await permissionHandelCtrl.getContactPermission();
      if (permissionStatus == PermissionStatus.granted) {
        var contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: false));
        contactList = contacts;

        statusData = await getStatusList(contactList!);
      }
    } catch (e) {
      log("message : $e");
    }
    return statusData;
  }

  getStatusList(List<Contact> contacts) async {
    var statusesSnapshot = await FirebaseFirestore.instance
        .collection('status')
        .orderBy('createdAt', descending: true)
        .get();
    List<Status> statusData = [];
    for (int i = 0; i < statusesSnapshot.docs.length; i++) {
      for (int j = 0; j < contacts.length; j++) {
        if (contacts[j].phones!.isNotEmpty) {
          String phone = contacts[j].phones![0].value.toString();
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
          if (phone == statusesSnapshot.docs[i]["phoneNumber"]) {
            final storeUser = appCtrl.storage.read("user");
            if (statusesSnapshot.docs[i]["uid"] != storeUser["id"]) {
              Status tempStatus =
                  Status.fromMap(statusesSnapshot.docs[i].data());
              statusData.add(tempStatus);
            }
          }
        }
      }
    }

    return statusData;
  }
}

class Status {
  final String uid;
  final String username;
  final String phoneNumber;
  final List<String> photoUrl;
  final String createdAt;
  final String profilePic;
  final bool isSeenByOwn;

  Status({
    required this.uid,
    required this.username,
    required this.phoneNumber,
    required this.photoUrl,
    required this.createdAt,
    required this.profilePic,
    required this.isSeenByOwn,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'profilePic': profilePic,
      'isSeenByOwn': isSeenByOwn,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: List<String>.from(map['photoUrl']),
      createdAt: map['createdAt'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isSeenByOwn: map['isSeenByOwn'] ?? false,
    );
  }
}
