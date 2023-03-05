import 'dart:developer';

import 'package:flutter_theme/config.dart';
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
    int counter = 0;
    contactList = [];
    registerContactList = [];
    unRegisterContactList = [];
    storageContact = await permissionHandelCtrl.getContact();
    update();

    var user = appCtrl.storage.read(session.user);
    if (appCtrl.contactList.isNotEmpty) {
      appCtrl.contactList
          .where((c) => c.phones.isNotEmpty)
          .forEach((Contact p) async {
        if (p.phones.isNotEmpty) {
          nameList = [];
          String phone = phoneNumberExtension(p.phones[0].number);
          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .where("phone", isEqualTo: phone).limit(1)
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              nameList = [];
              update();
              UserContactModel userContactModel = UserContactModel(
                isRegister: true,
                phoneNumber: phone,
                uid: value.docs[0].data()["id"],
                image: value.docs[0].data()["image"],
                username: value.docs[0].data()["name"],
                description: value.docs[0].data()["statusDesc"],
              );

              registerContactList!
                  .removeWhere((element) => element.phoneNumber == phone);
              update();
              if (phone != user["phone"]) {
                if (!registerContactList!.contains(userContactModel)) {
                  registerContactList!.add(userContactModel);
                }
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
              unRegisterContactList!
                  .removeWhere((element) => element.phoneNumber == phone);
              if (!unRegisterContactList!.contains(userContactModel)) {
                unRegisterContactList!.add(userContactModel);
              }
              nameList!.add(userContactModel);
            }
          });
          update();
        }
      });
    }
    registerContactList = [];

    contactList = [];
    counter++;
    ContactModel contactModel = ContactModel(
        title: fonts.registerUser.tr, userTitle: registerContactList);
    if (!contactList.contains(contactModel)) {
      contactList.add(contactModel);
    }

    ContactModel unRegisterContactModel = ContactModel(
        title: fonts.inviteUser.tr, userTitle: unRegisterContactList);
    if (!contactList.contains(unRegisterContactModel)) {
      contactList.add(unRegisterContactModel);
    }

    pagingController.itemList = [];
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
    log("counter : $counter");
    update();
  }


  //search contact list
  searchList(pageKey, search) async {
    if (search != "" && search != null) {
      try {
        searchContactList = [];
        update();
        log("nameList : ${nameList!.length}");
        List<ContactModel> filter = [];
        contactList.asMap().entries.forEach((element) {
          pagingController.itemList = [];

          element.value.userTitle!.asMap().entries.forEach((contact) {
            if (contact.value.username!.toLowerCase().contains(search)) {
              if (!searchContactList!.contains(contact.value)) {
                searchContactList!.add(contact.value);
                update();
              }
              log("ddd : ${searchContactList!.length}");
            }
          });

          update();
        });
        pagingController.itemList = [];
        ContactModel unRegisterContactModel = ContactModel(
            title: "Invite User for use Chatter", userTitle: searchContactList);
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
    } else {
      fetchPage(0);
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
  }
}
