import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contact;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ContactListController extends GetxController {
  List<contact.Contact>? contacts;
  List<contact.Contact> contactList = [];
  List<contact.Contact>? searchContactList = [];
  List selectedContact = [];
  bool isLoading = true;
  int counter =0;
  static const pageSize = 20;
  TextEditingController searchText = TextEditingController();
  final messageCtrl = Get.isRegistered<MessageController>()
      ? Get.find<MessageController>()
      : Get.put(MessageController());


  final PagingController<int, contact.Contact> pagingController =
  PagingController(firstPageKey: 0);

  @override
  void onInit() {
    // TODO: implement onInit
    pagingController.addPageRequestListener((pageKey) {

      fetchPage(pageKey,"");
    });
    super.onInit();
  }

   fetchPage(int pageKey,search) async {
    try {
counter ++;

      contacts = await contact.FlutterContacts.getContacts(withPhoto: true, withProperties: true,withThumbnail: true);

      if(search == "") {
        pagingController.itemList = [];
        contactList = [];
        contactList = contacts!;
      }else{
      pagingController.itemList = [];
      contactList = [];
        for (int i = 0; i < contacts!.length; i++) {
          if (contacts![i].phones.isNotEmpty) {
            if (contacts![i].displayName.toLowerCase().contains(search)) {
              contactList.add(contacts![i]);
            }
          }
        }
      }
      update();
      final isLastPage = contactList.length < pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(contactList);
      } else {
        final nextPageKey = pageKey + contactList.length;
        pagingController.appendPage(contactList, nextPageKey);
      }

      update();
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  void onReady() async {
    // TODO: implement onReady
update();
    super.onReady();
  }
}
