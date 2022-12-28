import 'dart:developer';

import 'package:flutter_theme/config.dart';

class FirebaseCommonController extends GetxController {
  List<PhotoUrl> newPhotoList = [];

  //online status update
  void setIsActive() async {
    var user = appCtrl.storage.read("user");
    await FirebaseFirestore.instance.collection("users").doc(user["id"]).update(
      {
        "status": "Online",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }

  //last seen update
  void setLastSeen() async {
    var user = appCtrl.storage.read("user");

    await FirebaseFirestore.instance.collection("users").doc(user["id"]).update(
      {
        "status": "Offline",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }

  //last seen update
  void groupTypingStatus(pId, documentId, isTyping) async {
    var user = appCtrl.storage.read("user");
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(pId)
        .update(
      {"status": isTyping ? "${user["name"]} is typing" : ""},
    );
  }

  //typing update
  void setTyping() async {
    var user = appCtrl.storage.read("user");
    await FirebaseFirestore.instance.collection("users").doc(user["id"]).update(
      {
        "status": "typing...",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }

  statusDeleteAfter24Hours() async {
   /* var user = appCtrl.storage.read("user") ?? "";
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
    }*/
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
}
