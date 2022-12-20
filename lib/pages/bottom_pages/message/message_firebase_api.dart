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
        if (contacts[j].phones!.isNotEmpty) {
          String phone =  phoneNumberExtension(contacts[j].phones![0].value.toString());

          if (phone == statusesSnapshot.docs[i]["phone"]) {
            var messageSnapshot =
                await FirebaseFirestore.instance.collection('contacts').orderBy("updateStamp",descending: true).get();
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
                  print(
                      "isExis : ${groupReceiver.where((element) => element["id"] == currentUserId).isEmpty}");
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
  saveContact(value)async{
    if (value != null) {
      Contact contact = value;

      String phone = contact.phones![0].value!;
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
          final uri = Uri(scheme: 'Download the Chatter', path: phone);
          await launchUrl(uri);
        }
      } else {
        var data = {"data": m.docs[0].data(), "chatId": "0"};
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
}
