import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_theme/config.dart';

class ContactListController extends GetxController {
  List<Contact>? contacts;
  List<Contact>? contactList = [];
  List selectedContact = [];

  @override
  void onReady() {
    // TODO: implement onReady
    refreshContacts();
    super.onReady();
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts = (await ContactsService.getContacts(
        withThumbnails: false, iOSLocalizedLabels: false));
    contactList = contacts;
    update();

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contactList!) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        contact.avatar = avatar;
        update();
      });
    }
  //  getFirebaseContact(contacts);
  }

  void updateContact() async {
    Contact ninja = contacts!
        .firstWhere((contact) => contact.familyName!.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);
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
            contacts.add(user.data());
          }
        }
      }
    }
    update();
  }
}
