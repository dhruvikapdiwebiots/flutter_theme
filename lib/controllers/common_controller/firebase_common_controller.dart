import 'package:flutter_theme/config.dart';

class FirebaseCommonController extends GetxController{

  //online status update
  void setIsActive() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(userId).update(
      {
        "status": "Online",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }

  //last seen update
  void setLastSeen() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(userId).update(
      {
        "status": "Offline",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }
  //typing update
  void setTyping() async {
    String userId = appCtrl.storage.read("id");
    await FirebaseFirestore.instance.collection("users").doc(userId).update(
      {
        "status": "typing...",
        "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
      },
    );
  }
}