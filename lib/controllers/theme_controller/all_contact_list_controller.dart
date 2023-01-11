

import 'package:flutter_theme/config.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';


class AllContactListController extends GetxController {

  List<Contact> storageContact = [];
  List<Contact> allContact = [];
  bool isLoading = true;
  int counter = 0;
  static const pageSize = 20;
   PagingController<int, Contact> pagingController =
      PagingController(firstPageKey: 0);
  TextEditingController searchText = TextEditingController();

  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());

  //fetch data
  Future<void> fetchPage(pageKey,search) async {
    pagingController.itemList = [];

    storageContact = [];
    if(search !="") {
      allContact = await permissionHandelCtrl.getContact();
      allContact.asMap().entries.forEach((element) {
        if(element.value.displayName.toLowerCase().contains(search)){
          if(!storageContact.contains(element.value)) {
            storageContact.add(element.value);
          }else{
            storageContact.remove(element.value);
          }
        }
      });
      update();
    }else{

      pagingController.itemList = [];
      storageContact = [];
      storageContact = await permissionHandelCtrl.getContact();
      update();
    }

    update();
    Get.forceAppUpdate();
    try {
      final newItems = storageContact;
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
    isLoading = false;
    update();
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
      fetchPage(pageKey,"");
    });
    super.onInit();
  }
}
