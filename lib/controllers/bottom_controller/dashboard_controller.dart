
import 'package:flutter_theme/config.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;

  late int iconCount = 0;
  List bottomList = [];
  List actionList = [];

//list of bottommost page
  List<Widget> widgetOptions = <Widget>[
    Text("Message"),
    Message(),
    Text("Status"),
  ];

  //on tap select
  onTapSelect(val) async {
    selectedIndex = val;
    update();
  }


  @override
  void onReady() {
    // TODO: implement onReady
    bottomList = appArray.bottomList;
    actionList = appArray.actionList;
    update();
    super.onReady();
  }


  popupMenuTap(value){
    if (value == 0) {
      print("My account menu is selected.");
    } else if (value == 1) {
      Get.toNamed(routeName.groupChat);
    } else if (value == 2) {
      Get.toNamed(routeName.setting);
    }
  }
}
