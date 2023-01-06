import 'dart:developer';

import 'package:flutter_theme/config.dart';

class GroupFirebaseApi {
  //create group
  createGroup(CreateGroupController groupCtrl) async {
    Map<String, dynamic>? arg;
    groupCtrl.dismissKeyboard();
    Get.back();
    groupCtrl.isLoading = true;
    final user = appCtrl.storage.read(session.user);
    groupCtrl.update();
    var userData = {
      "id": user["id"],
      "name": user["name"],
      "phone": user["phone"],
      "image": user["image"]
    };
    groupCtrl.selectedContact.add(userData);
    groupCtrl.imageFile = groupCtrl.pickerCtrl.imageFile;
    if (groupCtrl.imageFile != null) {
      await groupCtrl.uploadFile();
    }
    groupCtrl.update();
    final now = DateTime.now();
    String id = now.microsecondsSinceEpoch.toString();


    await Future.delayed(Durations.s3);
    await FirebaseFirestore.instance.collection('groups').doc(id).set({
      "name": groupCtrl.txtGroupName.text,
      "image": groupCtrl.imageUrl,
      "users": groupCtrl.selectedContact,
      "groupId": id,
      "status": "",
      "createdBy": user,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
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
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    print("groupCtrl.selectedContact : ${groupCtrl.selectedContact}");
    await FirebaseFirestore.instance
        .collection("groups")
        .doc(id)
        .get()
        .then((value) async {
      groupCtrl.selectedContact.map((e) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(e["id"])
            .collection("chats")
            .add({
          "isSeen": false,
          'receiverId': groupCtrl.selectedContact,
          "senderId": user["id"],
          'chatId': "",
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": "${user["name"]} created this group",
          "isGroup": true,
          "isBlock": false,
          "isBroadcast": false,
          "isBroadcastSender": false,
          "isOneToOne": false,
          "blockBy": "",
          "blockUserId": "",
          "groupId": id,
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
        });
      }).toList();
      groupCtrl.selectedContact = [];
      groupCtrl.txtGroupName.text = "";
      groupCtrl.isLoading = false;
      groupCtrl.imageUrl = "";
      groupCtrl.image = null;
      groupCtrl.imageFile = null;
      groupCtrl.update();
      arg = value.data();

    });
  log("back");
  log("back : $arg");
    Get.back();
    Get.back();
    Get.toNamed(routeName.groupChatMessage, arguments: arg);
  }
}
