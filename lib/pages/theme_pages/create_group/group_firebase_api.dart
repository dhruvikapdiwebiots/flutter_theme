import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class GroupFirebaseApi {
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

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

    await FirebaseFirestore.instance
        .collection(collectionName.groups)
        .doc(id)
        .set({
      "name": groupCtrl.txtGroupName.text,
      "image": groupCtrl.imageUrl,
      "users": groupCtrl.selectedContact,
      "groupId": id,
      "status": "",
      "createdBy": user,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    final key = encrypt.Key.fromUtf8('my 32 length key................');
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted =
        encrypter.encrypt("${user["name"]} created this group", iv: iv).base64;

    await FirebaseFirestore.instance
        .collection(collectionName.groupMessage)
        .doc(id)
        .collection(collectionName.chat)
        .add({
      'sender': user["id"],
      'senderName': user["name"],
      'receiver': groupCtrl.selectedContact,
      'content': "",
      "groupId": id,
      'type': MessageType.note.name,
      'messageType': "sender",
      "status": "",
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    }).then((e) {
      FirebaseFirestore.instance
          .collection(collectionName.groupMessage)
          .doc(id)
          .collection(collectionName.chat)
          .add({
        'sender': user["id"],
        'senderName': user["name"],
        'receiver': groupCtrl.selectedContact,
        'content': encrypted,
        "groupId": id,
        'type': MessageType.messageType.name,
        'messageType': "sender",
        "status": "",
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    });

    await FirebaseFirestore.instance
        .collection(collectionName.groups)
        .doc(id)
        .get()
        .then((value) async {
      groupCtrl.selectedContact.map((e) {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(e["id"])
            .collection(collectionName.chats)
            .add({
          "isSeen": false,
          'receiverId': groupCtrl.selectedContact,
          "senderId": user["id"],
          'chatId': "",
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": encrypted,
          "isGroup": true,
          "isBlock": false,
          "isBroadcast": false,
          "isBroadcastSender": false,
          "isOneToOne": false,
          "blockBy": "",
          "blockUserId": "",
          "name": groupCtrl.txtGroupName.text,
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
    dynamic messageData;
    log("back : $arg");
    Get.back();
    Get.back();
    FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(userData["id"])
        .collection(collectionName.chats)
        .where("groupId", isEqualTo: id)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        messageData = value.docs[0].data();
      }
    }).then((value) {
      var data = {"message": messageData, "groupData": arg};
      Get.toNamed(routeName.groupChatMessage, arguments: data);
    });
  }
}
