import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contact;
import 'package:flutter_theme/models/contact_model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ContactListController extends GetxController {
  List<ContactModel>? contacts;
  List<ContactModel> contactList = [];
  List<ContactModel>? searchContactList = [];
  List<UserContactModel>? registerContactList = [];
  List<UserContactModel>? unRegisterContactList = [];
  List selectedContact = [];
  bool isLoading = true;
  int counter = 0;
  static const pageSize = 20;
  TextEditingController searchText = TextEditingController();


  fetchPage( search) async {
    try {
counter++;
      await contact.FlutterContacts.getContacts(
              withPhoto: true, withProperties: true, withThumbnail: true)
          .then((contacts) {
            log("check : ${counter}");
        contacts.where((c) => c.phones.isNotEmpty).forEach((Contact p) async {
          if (p.phones.isNotEmpty) {
            String phone = phoneNumberExtension(p.phones[0].number);
            await FirebaseFirestore.instance
                .collection("users")
                .where("phone", isEqualTo: phone)
                .get()
                .then((value) {
              if (value.docs.isNotEmpty) {

                UserContactModel userContactModel = UserContactModel(
                    isRegister: true,
                    phoneNumber: phone,
                    uid: value.docs[0].data()["id"],
                    image: value.docs[0].data()["image"],
                    username: value.docs[0].data()["name"]);
                registerContactList!.add(userContactModel);
              }else{
                UserContactModel userContactModel = UserContactModel(
                    isRegister: false,
                    phoneNumber: phone,
                    contactImage: p.photo,
                    uid: "0",
                    username: p.displayName);
                unRegisterContactList!.add(userContactModel);
              }
            });
          }
        });

        ContactModel contactModel = ContactModel(title: "Register User with",userTitle: registerContactList);
        contactList.add(contactModel);
        ContactModel unRegisterContactModel = ContactModel(title: "Invite User for use Chatter",userTitle: unRegisterContactList);
        contactList.add(unRegisterContactModel);
        update();

      });
    log("contactList : ${contactList[1].userTitle}");
      update();
    } catch (error) {
      log("error : $error");
    }
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    update();
    super.onReady();
  }
}
