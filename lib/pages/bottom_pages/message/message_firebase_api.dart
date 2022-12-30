import 'dart:developer';
import 'dart:io';

import '../../../config.dart';

class MessageFirebaseApi {
  String? currentUserId;

  //get contact list
  getContactList(List<Contact> contacts) async {
    List message = [];

    final data = appCtrl.storage.read("user");
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
  saveContact(value) async {
    if (value != null) {
      Contact contact = value;

      String phone = contact.phones[0].number;
      if (phone.length > 10) {
        if (phone.contains(" ")) {
          phone = phone.replaceAll(" ", "");
        }
        if (phone.contains("-")) {
          phone = phone.replaceAll("-", "");
        }
        if (phone.contains("+")) {
          phone = phone.replaceAll("+91", "");
        }
        if (phone.length > 10) {
          phone = phone.substring(3);
        }
      }

      final m = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (m.docs.isEmpty) {
        if (Platform.isAndroid) {

          final uri = Uri(scheme: "sms", path: phone,queryParameters: <String, String>{
            'body': Uri.encodeComponent('Download the ChatBox App'),
          },);
          await launchUrl(uri);
        }
      } else {
        var data = {"data": m.docs[0].data(), "chatId": "0","allData":m.docs[0]};
        Get.toNamed(routeName.chat, arguments: data);
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

  //chat list

  List chatListWidget(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      MessageController messageCtrl) {
    List message = [];

    for (int j = 0; j < messageCtrl.contactUserList.length; j++) {
      if (messageCtrl.contactUserList[j].phones.isNotEmpty) {
        String phone = phoneNumberExtension(
            messageCtrl.contactUserList[j].phones[0].number.toString());
        for (int a = 0; a < snapshot.data!.docs.length; a++) {
          if (snapshot.data!.docs[a].data()["isGroup"] == false) {
            if (snapshot.data!.docs[a].data()["senderPhone"] ==
                    messageCtrl.storageUser["phone"] ||
                snapshot.data!.docs[a].data()["receiverPhone"] == phone &&
                    snapshot.data!.docs[a].data()["senderPhone"] == phone ||
                snapshot.data!.docs[a].data()["receiverPhone"] ==
                    messageCtrl.storageUser["phone"]) {
              message.add(snapshot.data!.docs[a]);
            }
          } else {
            if (snapshot.data!.docs[a].data()["senderPhone"] ==
                messageCtrl.storageUser["phone"]) {
              message.add(snapshot.data!.docs[a]);
            } else {
              List groupReceiver = snapshot.data!.docs[a].data()["receiverId"];
              if (groupReceiver
                  .where((element) => element["phone"] == phone)
                  .isNotEmpty) {
                message.add(snapshot.data!.docs[a]);
              }
            }
          }
        }
        return message;
      }
    }
    return message;
  }
}
