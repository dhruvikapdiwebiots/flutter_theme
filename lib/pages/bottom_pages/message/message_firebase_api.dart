import 'dart:developer';
import 'dart:io';

import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../config.dart';

class MessageFirebaseApi {
  String? currentUserId;
  final messageCtrl = Get.find<MessageController>();
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
          final uri = Uri(
            scheme: "sms",
            path: phone,
            queryParameters: <String, String>{
              'body': Uri.encodeComponent('Download the ChatBox App'),
            },
          );
          await launchUrl(uri);
        }
      } else {
        var data = {
          "data": m.docs[0].data(),
          "chatId": "0",
          "allData": m.docs[0]
        };
        Get.back();
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

  //get all exist users
  Future<List> getExistUser() async {
    List contactList= [];
    final msgList = await FirebaseFirestore.instance.collection("users").get();
    List<Contact> contactUserList  = await FlutterContacts.getContacts(withPhoto: true, withProperties: true,withThumbnail: true);
    for (final user in msgList.docs) {
      for (final contact in contactUserList) {
        if (contact.phones.isNotEmpty) {
          String phone = phoneNumberExtension(contact.phones[0].number.toString());
          if (phone == user.data()["phone"]) {
            log("us : ${user.data()}");
            final storeUser = appCtrl.storage.read("user");
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
    final storageUser = appCtrl.storage.read("user");
    for (int j = 0; j < messageCtrl.contactExistList.length; j++) {
      for (int a = 0; a < snapshot.data!.docs.length; a++) {
        if (snapshot.data!.docs[a].data()["isGroup"] == false) {
          if (snapshot.data!.docs[a].data()["senderPhone"] ==
              storageUser["phone"] ||
              snapshot.data!.docs[a].data()["receiverPhone"] == messageCtrl.contactExistList[j]["phone"] &&
                  snapshot.data!.docs[a].data()["senderPhone"] == messageCtrl.contactExistList[j]["phone"] ||
              snapshot.data!.docs[a].data()["receiverPhone"] ==
                  storageUser["phone"]) {
            if(!message.contains(snapshot.data!.docs[a])) {
              message.add(snapshot.data!.docs[a]);
            }
          }
        } else {
          List groupReceiver = snapshot.data!.docs[a].data()["receiverId"];
          if (groupReceiver
              .where((element) => element["phone"] == messageCtrl.contactExistList[j]["phone"])
              .isNotEmpty) {
            if(!message.contains(snapshot.data!.docs[a])) {
              message.add(snapshot.data!.docs[a]);
            }
          }
        }
      }
      return message;
    }
    return message;
  }
}
