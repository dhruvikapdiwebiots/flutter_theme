import 'package:flutter_theme/config.dart';

class ContactListController extends GetxController {
  List<Contact>? contacts;
  List<Contact> contactList = [];
  List<Contact>? searchContactList = [];
  List selectedContact = [];
  bool isLoading = true;
  TextEditingController searchText = TextEditingController();
  final messageCtrl = Get.isRegistered<MessageController>()
      ? Get.find<MessageController>()
      : Get.put(MessageController());

  @override
  void onReady() async {
    // TODO: implement onReady
    contactList = await permissionHandelCtrl.getContact();
    for (final contact in contactList) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        contact.avatar = avatar;
        update();
      });
    }
    refreshContacts();
    super.onReady();
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.

    contactList = Get.arguments;
    update();
    await Future.delayed(Durations.s2);
    isLoading = false;
    update();
    //  getFirebaseContact(contacts);
  }

  getFirebaseContact(contacts) async {
    final msgList = await FirebaseFirestore.instance.collection("users").get();

    for (final user in msgList.docs) {
      for (final contact in contacts!) {
        String phone = contact.phones![0].value.toString();
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
        }
        if (phone == user.data()["phone"]) {
          final storeUser = appCtrl.storage.read("user");
          if (user.data()["id"] != storeUser["id"]) {
            contactList.add(Contact.fromMap(contact));
          }
        }
      }
    }
    update();
  }

  searchContact(val, isTapSearch) {
    searchContactList = [];
    if(isTapSearch){
      for (int i = 0; i < contactList.length; i++) {
        if (contactList[i].phones!.isNotEmpty) {
          if (contactList[i].displayName!.toLowerCase().contains(val)) {
            searchContactList!.add(contactList[i]);
          }
        }
      }
    }else {
      if (val.length > 5) {
        for (int i = 0; i < contactList.length; i++) {
          if (contactList[i].phones!.isNotEmpty) {
            if (contactList[i].displayName!.toLowerCase().contains(val)) {
              searchContactList!.add(contactList[i]);
            }
          }
        }
      }
    }
    update();
  }
}
