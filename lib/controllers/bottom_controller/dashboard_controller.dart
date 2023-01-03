
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/bottom_pages/status/status.dart';

class DashboardController extends GetxController with GetSingleTickerProviderStateMixin {
  int selectedIndex = 0;
  int selectedPopTap = 0;
  TabController? controller;
  late int iconCount = 0;
  List bottomList = [];
  final statusCtrl = Get.isRegistered<StatusController>() ? Get.find<StatusController>() :Get.put(StatusController());
  final settingCtrl = Get.isRegistered<SettingController>() ? Get.find<SettingController>() :Get.put(SettingController());
  List actionList = [];


//list of bottommost page
  List<Widget> widgetOptions = <Widget>[
    const Message(),
    const StatusList(),

    Setting(),
  ];

  //on tap select
  onTapSelect(val) async {
    selectedIndex = val;

    update();
    if(selectedIndex ==0){
      statusCtrl.getStatus();
    }
    if(selectedIndex ==2){
      settingCtrl.onReady();
    }
  }


  @override
  void onReady() {
    // TODO: implement onReady


    bottomList = appArray.bottomList;
    actionList = appArray.actionList;
    controller = TabController(length: bottomList.length, vsync: this);
    firebaseCtrl.setIsActive();
    controller!.addListener(() {
      selectedIndex = controller!.index;
      update();
    });
   // firebaseCtrl.statusDeleteAfter24Hours();
    update();
    super.onReady();
  }


  popupMenuTap(value){

    if (selectedPopTap == 0) {
      Get.toNamed(routeName.groupChat,arguments: false);
    } else if (selectedPopTap == 1) {
      Get.toNamed(routeName.groupChat,arguments: true);
    } else if (selectedPopTap == 2) {
      Get.toNamed(routeName.setting);
    }
  }
}
