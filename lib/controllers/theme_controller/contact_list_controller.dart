import 'dart:developer';

import 'package:flutter_theme/config.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ContactListController extends GetxController {


  bool isLoading = true;
  static const pageSize = 20;
  final PagingController<int, UserContactModel> pagingController =
      PagingController(firstPageKey: 0);
  ContactModel? registerContact;
  List<UserContactModel>? registerList = [];
  List<UserContactModel>? unRegisterList = [];
  ContactModel? unRegisterContact;

  @override
  void onReady() {
    // TODO: implement onReady
    var dashboardCtrl = Get.find<DashboardController>();
    if(dashboardCtrl.contactList.isNotEmpty) {
      registerContact = dashboardCtrl.contactList[0];
      registerList = registerContact!.userTitle;
      unRegisterContact = dashboardCtrl.contactList[1];
      unRegisterList = unRegisterContact!.userTitle;
      update();
      pagingController.addPageRequestListener((pageKey) {
        fetchRegisterData(pageKey);
      });
    }
    super.onReady();
  }

  fetchRegisterData(pageKey) async {
    pagingController.itemList = [];

    try {
      final newItems = unRegisterList!.isNotEmpty
          ? unRegisterList
          : unRegisterContact!.userTitle;
      final isLastPage = newItems!.length < pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
      isLoading = false;
      update();
    } catch (error) {
      pagingController.error = error;
    }
  }

  onSearch(val) async {
    unRegisterList = [];
    registerContact!.userTitle!.asMap().entries.forEach((element) {
      if (element.value.username!.toLowerCase().contains(val)) {
        if (!registerList!.contains(element.value)) {
          registerList!.add(element.value);
        }
      }
    });
    unRegisterContact!.userTitle!.asMap().entries.forEach((element) {
      if (element.value.username!.toLowerCase().contains(val)) {
        if (!unRegisterList!.contains(element.value)) {
          unRegisterList!.add(element.value);
        }
      }
    });
    log("unRegisterList : ${unRegisterList!.length}");
    update();
    fetchRegisterData(0);
  }
}
