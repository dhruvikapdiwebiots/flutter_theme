
import 'package:flutter_theme/config.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ContactListController extends GetxController {
  bool isLoading = true;
  static const pageSize = 20;
  final PagingController<int, UserContactModel> pagingController =
      PagingController(firstPageKey: 0);

  List<UserContactModel> registerList = [], allRegisterList = [];
  List<UserContactModel> unRegisterList = [], allUnRegisterList = [];

  List<UserContactModel> list = [];

  @override
  void onReady() {
    // TODO: implement onReady
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      timerSet();
    });
    super.onReady();
  }

  timerSet() async {
    Future.delayed(const Duration(milliseconds: 300), () {
      isLoading = false;
      update();
    });
  }


  onSearch(val) async {
    registerList = [];
    unRegisterList = [];

    update();
    //fetchRegisterData(0);
  }

  refreshData() async {
    isLoading = true;
    update();
    await firebaseCtrl.deleteContacts();

    allRegisterList = [];
    allUnRegisterList = [];
    update();

    final dashboardCtrl = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    dashboardCtrl.update();
    update();

    update();
  }
}
