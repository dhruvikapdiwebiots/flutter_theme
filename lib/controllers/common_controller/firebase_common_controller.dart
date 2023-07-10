import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_theme/config.dart';

class FirebaseCommonController extends GetxController {
  List<PhotoUrl> newPhotoList = [];

  //online status update
  void setIsActive() async {
    var user = appCtrl.storage.read(session.user) ?? "";
    log("user : z4$user");
    if (user != "") {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .update(
        {
          "status": "Online",
          "isSeen": true,
          "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
        },
      );
    }
  }

  //last seen update
  void setLastSeen() async {
    var user = appCtrl.storage.read(session.user) ?? "";
    if (user != "") {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .update(
        {
          "status": "Offline",
          "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
        },
      );
    }
  }

  //last seen update
  void groupTypingStatus(pId, documentId, isTyping) async {
    var user = appCtrl.storage.read(session.user);
    await FirebaseFirestore.instance.collection("groups").doc(pId).update(
      {"status": isTyping ? "${user["name"]} is typing" : ""},
    );
  }

  //typing update
  void setTyping() async {
    var user = appCtrl.storage.read(session.user);
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(user["id"])
        .update(
      {
        "status": "typing...",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  //status delete after 24 hours
  //status delete after 24 hours
  statusDeleteAfter24Hours() async {
    var user = appCtrl.storage.read(session.user) ?? "";
    if (user != "") {
      FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .collection(collectionName.status)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          Status status = Status.fromJson(value.docs[0].data());
          List<PhotoUrl> photoUrl = status.photoUrl!;
          await getPhotoUrl(status.photoUrl!).then((list) async {
            photoUrl = [];
            List<PhotoUrl> photoUrls = list;
            log("photoUrls : ${photoUrls.length}");
            if (photoUrls.isEmpty) {
              FirebaseFirestore.instance
                  .collection(collectionName.users)
                  .doc(user["id"])
                  .collection(collectionName.status)
                  .doc(value.docs[0].id)
                  .delete();
            } else {

              if (photoUrls.length <= status.photoUrl!.length) {
                log("URL : ${photoUrls.length <= status.photoUrl!.length}");
                var statusesSnapshot = await FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(user["id"])
                    .collection(collectionName.status)
                    .get();
                await FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(user["id"])
                    .collection(collectionName.status)
                    .doc(statusesSnapshot.docs[0].id)
                    .update(
                    {'photoUrl': photoUrl.map((e) => e.toJson()).toList()});
              }
            }
          });
        }
      });
    }
  }

  syncContact() async {
    await Firebase.initializeApp();
    dynamic user = appCtrl.storage.read(session.user);
    if(user != null) {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(user["id"])
          .get()
          .then((value) async {
        if (value.exists) {
          log("value : ${value.exists}");
          bool isWebLogin = value.data()!["isWebLogin"] ?? false;
          if (isWebLogin == true) {
            log("appCtrl.contactList.isNotEmpty: ${appCtrl.contactList
                .isNotEmpty}");
            if (appCtrl.contactList.isNotEmpty) {
              List<Map<String, dynamic>> contactsData =
              appCtrl.contactList.map((contact) {
                return {
                  'name': contact.displayName,
                  'phoneNumber': contact.phones.isNotEmpty
                      ? phoneNumberExtension(contact.phones[0].number
                      .toString())
                      : null,
                  // Include other necessary contact details
                };
              }).toList();
              await FirebaseFirestore.instance
                  .collection(collectionName.users)
                  .doc(FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.uid : user["id"])
                  .collection(collectionName.userContact)
                  .get()
                  .then((allContact) {
                    log("CHECK EMPTY : ${allContact.docs.length}");
                if (allContact.docs.isEmpty) {
                  FirebaseFirestore.instance
                      .collection(collectionName.users)
                      .doc(FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.uid : user["id"])
                      .collection(collectionName.userContact)
                      .add({'contacts': contactsData});
                }
              });
              log("CHECK EMPTY1 :");
            } else {
              log("CHECK CONTACT");
              final dashboardCtrl = Get.isRegistered<DashboardController>()
                  ? Get.find<DashboardController>()
                  : Get.put(DashboardController());
              dashboardCtrl.checkPermission();
              if (appCtrl.contactList.isNotEmpty) {
                List<Map<String, dynamic>> contactsData =
                appCtrl.contactList.map((contact) {
                  return {
                    'name': contact.displayName,
                    'phoneNumber': contact.phones.isNotEmpty
                        ? phoneNumberExtension(
                        contact.phones[0].number.toString())
                        : null,
                    // Include other necessary contact details
                  };
                }).toList();
                await FirebaseFirestore.instance
                    .collection(collectionName.users)
                    .doc(appCtrl.user["id"])
                    .collection(collectionName.userContact)
                    .get()
                    .then((allContact) {
                  log("CHECK EMPTY2: ${allContact.docs.length}");
                  if (allContact.docs.isEmpty) {
                    FirebaseFirestore.instance
                        .collection(collectionName.users)
                        .doc(appCtrl.user["id"])
                        .collection(collectionName.userContact)
                        .add({'contacts': contactsData});
                  }
                });
              }
            }
          }
        }
      });
    }
  }

  Future<List<PhotoUrl>> getPhotoUrl(List<PhotoUrl> photoUrl) async {
    for (int i = 0; i < photoUrl.length; i++) {
      var millis = int.parse(photoUrl[i].timestamp.toString());
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
      var date = DateTime.now();

      log("diff : ${dt.hour <= date.hour}");
      if (appCtrl.usageControlsVal!.statusDeleteTime!.contains(" hrs")) {
        if (dt.hour <= date.hour) {
          newPhotoList.add(photoUrl[i]);
        }
      } else if (appCtrl.usageControlsVal!.statusDeleteTime!.contains(" min")) {
        if (dt.minute <= date.minute) {
          newPhotoList.add(photoUrl[i]);
        }
      }
      update();
    }
    update();
    return newPhotoList;
  }

  //send notification
  Future<void> sendNotification(
      {title,
      msg,
      token,
      image,
      dataTitle,
      chatId,
      groupId,
      userContactModel,
      pId,
      pName}) async {
    log('token : $token');

    final data = {
      "notification": {
        "body": msg,
        "title": dataTitle,
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "alertMessage": 'true',
        "title": title,
        "chatId": chatId,
        "groupId": groupId,
        "userContactModel": userContactModel,
        "pId": pId,
        "pName": pName,
        "imageUrl": image,
        "isGroup": false
      },
      "to": "$token"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=${appCtrl.userAppSettingsVal!.firebaseServerToken}'
    };

    BaseOptions options = BaseOptions(
      connectTimeout:const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: headers,
    );

    try {
      final response = await Dio(options)
          .post('https://fcm.googleapis.com/fcm/send', data: data);

      if (response.statusCode == 200) {
        log('Alert push notification send');
      } else {
        log('notification sending failed');
        // on failure do sth
      }
    } catch (e) {
      log('exception $e');
    }
  }
}
