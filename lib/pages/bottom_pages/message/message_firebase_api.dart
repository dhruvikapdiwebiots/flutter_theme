import 'dart:developer';
import 'dart:io';

import '../../../config.dart';

class MessageFirebaseApi {
  String? currentUserId;
  final messageCtrl = Get.find<MessageController>();
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  //get contact list
  getContactList(List<Contact> contacts) async {
    List message = [];

    final data = appCtrl.storage.read(session.user);
    currentUserId = data["id"];
    var statusesSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    for (int i = 0; i < statusesSnapshot.docs.length; i++) {
      for (int j = 0; j < contacts.length; j++) {
        if (contacts[j].phones.isNotEmpty) {
          String phone =
              phoneNumberExtension(contacts[j].phones[0].number.toString());

          if (phone == statusesSnapshot.docs[i]["phone"]) {
            var messageSnapshot = await FirebaseFirestore.instance
                .collection('contacts')
                .orderBy("updateStamp", descending: true)
                .get();
            for (int a = 0; a < messageSnapshot.docs.length; a++) {
              if (messageSnapshot.docs[a].data()["isGroup"] == false) {
                if (messageSnapshot.docs[a].data()["senderId"] ==
                        currentUserId ||
                    messageSnapshot.docs[a].data()["receiverId"] ==
                            statusesSnapshot.docs[i]["id"] &&
                        messageSnapshot.docs[a].data()["senderId"] ==
                            statusesSnapshot.docs[i]["id"] ||
                    messageSnapshot.docs[a].data()["receiverId"] ==
                        currentUserId) {
                  message.add(messageSnapshot.docs[a]);
                }
              } else {
                if (messageSnapshot.docs[a].data()["senderId"] ==
                    currentUserId) {
                  message.add(messageSnapshot.docs[a]);
                } else {
                  List groupReceiver =
                      messageSnapshot.docs[a].data()["receiverId"];
                  if (groupReceiver
                      .where((element) => element["id"] == currentUserId)
                      .isNotEmpty) {
                    message.add(messageSnapshot.docs[a]);
                  }
                }
              }
            }
            return message;
          }
        }
      }
    }
    return message;
  }

  //check contact in firebase and if not exists
  saveContact(value, isRegister) async {
    final data = appCtrl.storage.read(session.user);
    currentUserId = data["id"];
    UserContactModel userContact = value;
    if (isRegister) {
      log("val: ${userContact.uid}");
      await FirebaseFirestore.instance
          .collection('users')
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
          var data = {"chatId": "0", "data": userContact};

          Get.back();
          Get.toNamed(routeName.chat, arguments: data);
        } else {
          value.docs.asMap().entries.forEach((element) { 
            if(element.value.data()["senderId"]  == userContact.uid ||
                element.value.data()["receiverId"] == userContact.uid){
              var data = {"chatId": element.value.data()["chatId"], "data": userContact};
              Get.back();
              Get.toNamed(routeName.chat,arguments: data);
            }
          });
          
          //
        }
      });
    } else {
      if (Platform.isAndroid) {
        final uri = Uri(
          scheme: "sms",
          path: userContact.phoneNumber,
          queryParameters: <String, String>{
            'body': Uri.encodeComponent('Download the ChatBox App'),
          },
        );
        await launchUrl(uri);
      }
    }
  }

  //get all users
  Future<List> getUser() async {
    List contactList = [];
    final contactLists =
        await FirebaseFirestore.instance.collection("users").get();
    for (int i = 0; i < contactLists.docs.length; i++) {
      if (contactLists.docs[i].id != currentUserId) {
        final msgList = await FirebaseFirestore.instance
            .collection("messages")
            .doc("$currentUserId-${contactLists.docs[i]["id"]}")
            .get();
        if (msgList.exists) {
          contactList.add(contactLists.docs[i]);
        }
      }
    }
    return contactList;
  }

  //get all exist users
  Future<List> getExistUser() async {
    List contactList = [];
    final msgList = await FirebaseFirestore.instance.collection("users").get();
    List<Contact> contactUserList =  await permissionHandelCtrl.getContact();
    for (final user in msgList.docs) {
      for (final contact in contactUserList) {
        if (contact.phones.isNotEmpty) {
          String phone =
              phoneNumberExtension(contact.phones[0].number.toString());
          if (phone == user.data()["phone"]) {

            final storeUser = appCtrl.storage.read(session.user);
            if (user.data()["id"] != storeUser["id"]) {
              contactList.add(user.data());
            }
          }
        }
      }
    }
    return contactList;
  }

  //chat list

  List chatListWidget(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    List message = [];
    for (int a = 0; a < snapshot.data!.docs.length; a++) {
      message.add(snapshot.data!.docs[a]);
    }
    return message;
  }
}
