import 'dart:async';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/config.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../fetch_contact_controller.dart';

class AllContactListController extends GetxController {
  List<Contact> storageContact = [];
  List<Contact> allContact = [];
  bool isLoading = true;
  int counter = 0;
  static const pageSize = 20;
  PagingController<int, Contact> pagingController =
      PagingController(firstPageKey: 0);
  Map<String?, String?>? searchList = <String, String>{};
  TextEditingController searchText = TextEditingController();
  Map<String?, String?> _cachedContacts = {};
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  //fetch data
  Future<void> fetchPage(pageKey, search) async {
    if (search != null) {
      Completer<Map<String?, String?>> completer =
          Completer<Map<String?, String?>>();
      searchList = {};
      _cachedContacts = {};
      completer.future.then((c) {
        searchList = c;
        if (searchList!.isEmpty) {
          update();
        }
      });

      final FetchContactController registerAvailableContact =
          Provider.of<FetchContactController>(Get.context!, listen: false);

      registerAvailableContact.contactList!.forEach((key, value) {
        if (value.toString().toLowerCase().contains(search)) {
          if (!(_cachedContacts[key] == value)) {
            _cachedContacts[key] = value;
          } else {
            _cachedContacts.remove(_cachedContacts[key]);
          }
        }
        update();
      });
      searchList = _cachedContacts;
      update();

    } else {
      searchList = {};
      _cachedContacts = {};
      update();
      Get.forceAppUpdate();
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
      fetchPage(pageKey, "");
    });
    super.onInit();
  }
}
