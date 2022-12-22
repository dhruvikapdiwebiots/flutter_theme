
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/call_model.dart';
import 'package:flutter_theme/pages/bottom_pages/status/status.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;
  int selectedPopTap = 0;

  late int iconCount = 0;
  List bottomList = [];
  final statusCtrl = Get.isRegistered<StatusController>() ? Get.find<StatusController>() :Get.put(StatusController());
  List actionList = [];
/*
//list of bottommost page
  List<Widget> widgetOptions = <Widget>[
    Text("Message"),
    Message(),
    StatusList(),
  ];*/


//list of bottommost page
  List<Widget> widgetOptions = <Widget>[
    StatusList(),
    Message(),
    Setting(),
  ];

  //on tap select
  onTapSelect(val) async {
    selectedIndex = val;

    update();
    if(selectedIndex ==0){
      statusCtrl.getStatus();
    }
  }


  @override
  void onReady() {
    // TODO: implement onReady
    bottomList = appArray.bottomList;
    actionList = appArray.actionList;
    firebaseCtrl.setIsActive();
   // firebaseCtrl.statusDeleteAfter24Hours();
    update();
    super.onReady();
  }


  popupMenuTap(value){
    print(value);
    /*if (selectedPopTap == 0) {
      print("My account menu is selected.");
    } else if (selectedPopTap == 1) {
      Get.toNamed(routeName.groupChat);
    } else if (selectedPopTap == 2) {
      Get.toNamed(routeName.setting);
    }*/
    Get.toNamed(routeName.groupChat);
  }
}
