import '../../../../config.dart';

class ChatFirebaseApi{


  //unblock
  unblockFunction(value,chatId,pId)async{
   /* var user = appCtrl.storage.read("user");
    for (int i = 0; i < value.docs.length; i++) {
      if (value.docs[i].data()["blockUserId"] == pId) {
        FirebaseFirestore.instance
            .collection("blocks")
            .doc(user["id"])
            .collection("users")
            .doc(value.docs[i].id)
            .delete();
        DateTime now = DateTime.now();
        String? newChatId = chatId == "0"
            ? now.microsecondsSinceEpoch.toString()
            : chatId;
        chatId = newChatId;
        FirebaseFirestore.instance
            .collection('messages')
            .doc(newChatId)
            .collection("chat")
            .add({
          'sender': user["id"],
          'receiver': pId,
          'content': "You Unblock this contact",
          "chatId": newChatId,
          'type': MessageType.messageType.name,
          'messageType': "sender",
          'timestamp': DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
        });
      }
    }*/
  }
}