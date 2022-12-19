import 'package:flutter_theme/config.dart';

class FirebaseCommonController extends GetxController {
  var user = appCtrl.storage.read("user");

  //online status update
  void setIsActive() async {

    await FirebaseFirestore.instance.collection("users").doc(user["id"]).update(
      {
        "status": "Online",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }

  //last seen update
  void setLastSeen() async {

    await FirebaseFirestore.instance.collection("users").doc(user["id"]).update(
      {
        "status": "Offline",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }

  //last seen update
  void groupTypingStatus(pId, documentId, isTyping) async {
    await FirebaseFirestore.instance
        .collection("groupMessage")
        .doc(pId)
        .collection("chat")
        .doc(documentId)
        .update(
      {
        "status": isTyping ? "${user["name"]} is typing" : "",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }

  //typing update
  void setTyping() async {
    await FirebaseFirestore.instance.collection("users").doc(user["id"]).update(
      {
        "status": "typing...",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }

  statusDeleteAfter24Hours() async {

    FirebaseFirestore.instance
        .collection('status')
        .where("uid", isEqualTo: user["id"])
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {

        for (int i = 0; i < value.docs[0].data()["photoUrl"].length; i++) {
          var millis =
              int.parse(value.docs[0].data()["photoUrl"][i]["timestamp"]);
          DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
          var date = DateTime.now();
          Duration diff = date.difference(dt);
          if (diff.inHours == 24) {
            FirebaseFirestore.instance
                .collection('status')
                .doc(user["id"])
                .update({"isExpired": true});
          }
        }
      }
    });
  }
}
