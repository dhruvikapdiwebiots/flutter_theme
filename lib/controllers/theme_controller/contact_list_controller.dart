import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/contact_model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';


class ContactListController extends GetxController {
  List<ContactModel> contactList = [];
  List<UserContactModel>? searchContactList = [];
  List<UserContactModel>? registerContactList = [];
  List<UserContactModel>? unRegisterContactList = [];
  List<Contact> storageContact = [];
  List<UserContactModel>? nameList = [];
  bool isLoading = true;
  int counter = 0;
  static const pageSize = 20;
  final PagingController<int, ContactModel> pagingController =
      PagingController(firstPageKey: 0);
  TextEditingController searchText = TextEditingController();

  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());
  
  //fetch data
  Future<void> fetchPage(pageKey) async {
    contactList = [];
    registerContactList = [];
    unRegisterContactList = [];
    storageContact = await  permissionHandelCtrl.getContact();
    if (storageContact.isNotEmpty) {
      log("storageContact : ${storageContact.length}");
      storageContact
          .where((c) => c.phones.isNotEmpty)
          .forEach((Contact p) async {
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
              if(!registerContactList!.contains(userContactModel)) {
                registerContactList!.add(userContactModel);
              }
              update();
              nameList!.add(userContactModel);
            } else {
              UserContactModel userContactModel = UserContactModel(
                  isRegister: false,
                  phoneNumber: phone,
                  contactImage: p.photo,
                  uid: "0",
                  username: p.displayName);
              if(!unRegisterContactList!.contains(userContactModel)) {
                unRegisterContactList!.add(userContactModel);
              }
              nameList!.add(userContactModel);
            }
          });
          update();
        }
      });
    }

    ContactModel contactModel = ContactModel(
        title: "Register User with", userTitle: registerContactList);
    contactList.add(contactModel);

    log("contactList : ${contactList[0].userTitle!.length}");
    ContactModel unRegisterContactModel = ContactModel(
        title: "Invite User for use Chatter", userTitle: unRegisterContactList);
    contactList.add(unRegisterContactModel);
    isLoading = false;
    try {
      final newItems = contactList;
      final isLastPage = newItems.length < pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  searchList(pageKey, search) async {
    if(search != "" && search != null) {
      try {
        searchContactList = [];
        update();
        log("nameList : ${nameList!.length}");
        List<ContactModel> filter = [];
        contactList
            .asMap()
            .entries
            .forEach((element) {
          pagingController.itemList = [];

          element.value.userTitle!.asMap().entries.forEach((contact) {
            if (contact.value.username!.toLowerCase().contains(search)) {
              log("contact.value : ${contact.value.username}");
              searchContactList!.add(contact.value);
              update();
              log("ddd : ${searchContactList!.length}");
            }
          });

          update();
        });
        ContactModel unRegisterContactModel = ContactModel(
            title: "Invite User for use Chatter",
            userTitle: searchContactList);
        filter.add(unRegisterContactModel);
        final isLastPage = filter.length < pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(filter);
        } else {
          final nextPageKey = pageKey + filter.length;
          pagingController.appendPage(filter, nextPageKey);
        }
      } catch (error) {
        pagingController.error = error;
      }
      update();
      log("pagingController : ${pagingController.itemList!.length}");
    }else{
      fetchPage(0);
    }
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    update();

    super.onReady();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    super.onInit();
  }
}
