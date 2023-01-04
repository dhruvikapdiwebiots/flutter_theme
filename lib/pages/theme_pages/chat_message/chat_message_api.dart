import '../../../config.dart';

class ChatMessageApi{
  final chatCtrl = Get.isRegistered<ChatController>() ? Get.find<ChatController>() : Get.put(ChatController());
  
  
  //save message in user 
  saveMessageInUserCollection(id, receiverId,newChatId,content)async{
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
          "isBlock": false,
          "isBroadcast": false,
          "isBroadcastSender": false,
          "blockBy": "",
          "blockUserId": "",
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
          "isBlock": false,
          "isBroadcast": false,
          "isBroadcastSender": false,
          "isOneToOne": true,
          "blockBy": "",
          "blockUserId": "",
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
}