import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_theme/config.dart';

class ContactListController extends GetxController{
  List<Contact>? contacts;
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
    contacts = contacts;
    update();

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        contact.avatar = avatar;
        update();
      });
    }
  }

  void updateContact() async {
    Contact ninja = contacts!
        .firstWhere((contact) => contact.familyName!.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
  }

}