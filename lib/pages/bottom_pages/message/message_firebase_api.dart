import 'dart:developer';


import '../../../config.dart';

class MessageFirebaseApi {
  String? currentUserId;
  final messageCtrl = Get.isRegistered<MessageController>()? Get.find<MessageController>():Get.put(MessageController());

  //check contact in firebase and if not exists
  saveContact(UserContactModel userModel, {message}) async {
    bool isRegister = false;


    await FirebaseFirestore.instance.collection(collectionName.users).where("phone",isEqualTo: userModel.phoneNumber).limit(1).get().then((value) {
      if(value.docs.isNotEmpty){
        isRegister = true;
        userModel.uid = value.docs[0].id;
      }else{
        isRegister = false;
      }
    });


    final data = appCtrl.storage.read(session.user);
    currentUserId = data["id"];

    UserContactModel userContact = userModel;
    if (isRegister) {
      log("val: ${userContact.uid}");
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(currentUserId)
          .collection("chats")
          .where("isOneToOne", isEqualTo: true)
          .get()
          .then((value) {

        bool isEmpty = value.docs
            .where((element) =>
                element.data()["senderId"] == userContact.uid ||
                element.data()["receiverId"] == userContact.uid)
            .isNotEmpty;
        if (!isEmpty) {
          var data = {"chatId": "0", "data": userContact,"message":message};

          Get.back();
          Get.toNamed(routeName.chat, arguments: data);
        } else {
          value.docs.asMap().entries.forEach((element) {
            if(element.value.data()["senderId"]  == userContact.uid ||
                element.value.data()["receiverId"] == userContact.uid){
              var data = {"chatId": element.value.data()["chatId"], "data": userContact,"message":message};
              Get.back();
              Get.toNamed(routeName.chat,arguments: data);
            }
          });

          //
        }
      });
    } else {
      String? encodeQueryParameters(Map<String, String> params) {
        return params.entries
            .map((e) =>
        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }

      Uri smsUri = Uri(
        scheme: 'sms',
        path: '${userModel.phoneNumber}',
        query: encodeQueryParameters(
            <String, String>{'body': "Hello, let's chat with Chatify. Download the app from google play store"}),
      );

      try {
        await launchUrl(smsUri);
      } catch (e) {
        throw "Can't phone that number.";
      }
    }
  }

  //chat list

  List chatListWidget(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> snapshot) {
    List message = [];
    for (int a = 0; a < snapshot.length; a++) {
      message.add(snapshot[a]);
    }
    return message;
  }
}
