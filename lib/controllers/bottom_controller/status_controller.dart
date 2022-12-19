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

    List<PhotoUrl> statusImageUrls = [];
    var statusesSnapshot = await FirebaseFirestore.instance
        .collection('status')
        .where(
          'uid',
          isEqualTo: currentUserId,
        )
        .get();

    if (statusesSnapshot.docs.isNotEmpty) {
      Status status = Status.fromJson(statusesSnapshot.docs[0].data());
      statusImageUrls = status.photoUrl!;
      var data = {
        "image": imageUrl!,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "isExpired": false
      };
      statusImageUrls.add(PhotoUrl.fromJson(data));
      await FirebaseFirestore.instance
          .collection('status')
          .doc(statusesSnapshot.docs[0].id)
          .update({'photoUrl': statusImageUrls});
      return;
    } else {
      var data = {
        "image": imageUrl!,
        "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
        "isExpired": false
      };
      statusImageUrls = [PhotoUrl.fromJson(data)];
    }

    Status status = Status(
        username: user["name"],
        phoneNumber: user["phone"],
        photoUrl: statusImageUrls,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        profilePic: user["image"],
        uid: currentUserId!,
        isSeenByOwn: false);

    await FirebaseFirestore.instance.collection('status').add(status.toJson());
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
              print(
                  "object :${Status.fromJson(statusesSnapshot.docs[i].data())}");
              Status tempStatus =
                  Status.fromJson(statusesSnapshot.docs[i].data());
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
  String? uid;
  String? username;
  String? phoneNumber;
  List<PhotoUrl>? photoUrl;
  String? createdAt;
  String? profilePic;
  bool? isSeenByOwn;

  Status(
      {this.uid,
      this.username,
      this.phoneNumber,
      this.photoUrl,
      this.createdAt,
      this.profilePic,
      this.isSeenByOwn});

  Status.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    username = json['username'];
    phoneNumber = json['phoneNumber'];
    createdAt = json['createdAt'];
    profilePic = json['profilePic'];
    isSeenByOwn = json['isSeenByOwn'];
    if (json['photoUrl'] != null) {
      photoUrl = <PhotoUrl>[];
      json['photoUrl'].forEach((v) {
        photoUrl!.add(PhotoUrl.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['username'] = username;
    data['phoneNumber'] = phoneNumber;
    data['createdAt'] = createdAt;
    data['profilePic'] = profilePic;
    data['isSeenByOwn'] = isSeenByOwn;
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PhotoUrl {
  String? image;
  String? timestamp;
  bool? isExpired;

  PhotoUrl({this.image, this.timestamp, this.isExpired});

  PhotoUrl.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    timestamp = json['timestamp'];
    isExpired = json['isExpired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['timestamp'] = timestamp;
    data['isExpired'] = isExpired;
    return data;
  }
}
