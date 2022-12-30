import 'package:flutter_theme/config.dart';

class GroupFirebaseApi{

  //create group

  createGroup(CreateGroupController groupCtrl)async{
    groupCtrl.isLoading = true;
    groupCtrl.imageFile =
        groupCtrl.pickerCtrl.imageFile;
    if (groupCtrl.imageFile != null) {
      await groupCtrl.uploadFile();
    }
    groupCtrl.update();
    final now = DateTime.now();
    String id = now.microsecondsSinceEpoch.toString();

    final user = appCtrl.storage.read("user");
    await Future.delayed(Durations.s3);
    await FirebaseFirestore.instance
        .collection('groups')
        .doc(id)
        .set({
      "name": groupCtrl.txtGroupName.text,
      "image": groupCtrl.imageUrl,
      "groupTypeNotification": "new_added",
      "users": groupCtrl.selectedContact,
      "groupId": id,
      "createdBy": user,
      'timestamp': DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
    });

    FirebaseFirestore.instance
        .collection('groupMessage')
        .doc(id)
        .collection("chat")
        .add({
      'sender': user["id"],
      'senderName': user["name"],
      'receiver': groupCtrl.selectedContact,
      'content': "${user["name"]} created this group",
      "groupId": id,
      'type': MessageType.messageType.name,
      'messageType': "sender",
      "status": "",
      'timestamp': DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
    });
    groupCtrl.selectedContact.add(user);
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(id)
        .get()
        .then((value) async {
      await FirebaseFirestore.instance
          .collection('contacts')
          .add({
        'sender': {
          "id": user['id'],
          "name": user['name'],
          "phone": user["phone"]
        },
        'receiver': null,
        "isBroadcast": false,
        "isBroadcastSender": false,
        'group': {
          "id": value.id,
          "name": groupCtrl.txtGroupName.text,
          "image": groupCtrl.imageUrl,
        },
        'receiverId': groupCtrl.selectedContact,
        'senderPhone': user["phone"],
        'timestamp': DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        "lastMessage": "",
        "isGroup": true,
        "groupId": value.id,
        "updateStamp": DateTime.now()
            .millisecondsSinceEpoch
            .toString()
      }).then((value) {
        groupCtrl.selectedContact = [];
        groupCtrl.txtGroupName.text = "";
        groupCtrl.isLoading = false;
        groupCtrl.update();
        Get.back();
        Get.back();
      });
    });
  }
}