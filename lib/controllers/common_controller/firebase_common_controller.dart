
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_theme/config.dart';

class FirebaseCommonController extends GetxController {
  List<PhotoUrl> newPhotoList = [];

  //online status update
  void setIsActive() async {
    var user = appCtrl.storage.read(session.user) ?? "";
    if(user != "") {
      await FirebaseFirestore.instance.collection("users")
          .doc(user["id"])
          .update(
        {
          "status": "Online",
          "isSeen":true,
          "lastSeen": DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()
        },
      );
    }
  }

  //last seen update
  void setLastSeen() async {
    var user = appCtrl.storage.read(session.user) ?? "";
    if(user != "") {
      await FirebaseFirestore.instance.collection("users")
          .doc(user["id"])
          .update(
        {
          "status": "Offline",
          "lastSeen": DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()
        },
      );
    }
  }

  //last seen update
  void groupTypingStatus(pId, documentId, isTyping) async {
    var user = appCtrl.storage.read(session.user);
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(pId)
        .update(
      {"status": isTyping ? "${user["name"]} is typing" : ""},
    );
  }

  //typing update
  void setTyping() async {
    var user = appCtrl.storage.read(session.user);
    await FirebaseFirestore.instance.collection("users").doc(user["id"]).update(
      {
        "status": "typing...",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  statusDeleteAfter24Hours() async {
    var user = appCtrl.storage.read(session.user) ?? "";
    if(user != "") {
      FirebaseFirestore.instance
          .collection('status')
          .where("uid", isEqualTo: user["id"])
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          Status status = Status.fromJson(value.docs[0].data());
          await getPhotoUrl(status.photoUrl!).then((list) async {
            List<PhotoUrl> photoUrl = list;

            if (photoUrl.isEmpty) {
              FirebaseFirestore.instance
                  .collection('status')
                  .doc(value.docs[0].id)
                  .delete();
            } else {
              var statusesSnapshot = await FirebaseFirestore.instance
                  .collection('status')
                  .where(
                'uid',
                isEqualTo: user["id"],
              )
                  .get();
              await FirebaseFirestore.instance
                  .collection('status')
                  .doc(statusesSnapshot.docs[0].id)
                  .update(
                  {'photoUrl': photoUrl.map((e) => e.toJson()).toList()});
            }
          });
        }
      });
    }
  }

  Future<List<PhotoUrl>> getPhotoUrl(List<PhotoUrl> photoUrl) async {
    for (int i = 0; i < photoUrl.length; i++) {
      var millis = int.parse(photoUrl[i].timestamp.toString());
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
      var date = DateTime.now();
      Duration diff = date.difference(dt);

      if (diff.inHours >= 24) {
        newPhotoList.remove(photoUrl[i]);
      } else {
        newPhotoList.add(photoUrl[i]);
      }
      update();
    }
    update();
    return newPhotoList;
  }

  //send notification
  Future<void> sendNotification({title, msg,token,image,dataTitle}) async {

    log('token : $token');

    final data = {
      "notification": {
        "body": msg,
        "title": title,
        "imageUrl":image
      },
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "alertMessage": 'true',
        "title":dataTitle
      },
      "to": "$token"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
      'key=AAAAgR3DDRg:APA91bHsQChfBTYROhYDv5mGtTRQ1GsEodC6Qx3sfu3wHzJkMW3eAkX061omjkiM3qRZOMqp32O0xIjOcbgPD72aRL6kbxr_KuvYNdefRyYFUFVPABUG5l8EyY6Zx3gxC1TaIsEmmhRt'
    };

    BaseOptions options = BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
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
