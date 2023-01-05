import 'dart:developer';

import '../../../config.dart';

class ChatMessageApi{

  
  
  //save message in user 
  saveMessageInUserCollection(id, receiverId,newChatId,content,{isBlock = false})async{
    final chatCtrl = Get.isRegistered<ChatController>() ? Get.find<ChatController>() : Get.put(ChatController());
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id).collection("chats").where("chatId",isEqualTo: newChatId)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id).collection("chats").doc(value.docs[0].id)
            .update({
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content,
          "senderId": id,
          "isSeen": false,
          "isGroup": false,
          "isBlock": isBlock ?? false,
          "isBroadcast": false,
          "isBroadcastSender": false,
          "blockBy": isBlock ? id :"",
          "blockUserId":  isBlock ? receiverId :"",
          "receiverId": receiverId,
        }).then((value) {
          chatCtrl.textEditingController.text = "";
          chatCtrl.update();
        });
      } else {
        dynamic user = appCtrl.storage.read("user");

        FirebaseFirestore.instance.collection('users').doc(id).collection("chats").add({
          "isSeen": false,
          'receiverId': receiverId,
          "senderId": id,
          'chatId': newChatId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content,
          "isGroup": false,
          "isBlock": isBlock ?? false,
          "isBroadcast": false,
          "isBroadcastSender": false,
          "isOneToOne": true,
          "blockBy": isBlock ? id :"",
          "blockUserId":  isBlock ? receiverId :"",
          "groupId": "",
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
        }).then((value) {
          chatCtrl.isLoading = false;
          chatCtrl.update();
          Get.forceAppUpdate();
        });
      }
    }).then((value) {
      chatCtrl.isLoading = false;
      chatCtrl.update();
      Get.forceAppUpdate();
    });
  }

  //save group data
  saveGroupData(id, groupId,content,pData)async{
    var user = appCtrl.storage.read("user");
    List receiver = pData["users"];
    log("receiver : ${receiver.length}");
   receiver.asMap().entries.forEach((element) async{
     await FirebaseFirestore.instance
         .collection("users").doc(receiver[element.key]["id"]).collection("chats")
         .where("groupId", isEqualTo: groupId)
         .get()
         .then((value) {
           log("value.docs : ${value.docs}");
       if (value.docs.isNotEmpty) {
         FirebaseFirestore.instance
             .collection("users").doc(id).collection("chats")
             .doc(value.docs[0].id)
             .update({
           "updateStamp":
           DateTime.now().millisecondsSinceEpoch.toString(),
           "lastMessage": content,
           "senderId": user["id"],
         });
       }
     });
   });

  }
}