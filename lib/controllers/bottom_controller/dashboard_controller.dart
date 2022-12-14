
import 'package:flutter_theme/config.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;
  int selectedPopTap = 0;

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
    print(value);
    if (selectedPopTap == 0) {
      print("My account menu is selected.");
    } else if (selectedPopTap == 1) {
      Get.toNamed(routeName.groupChat);
    } else if (selectedPopTap == 2) {
      Get.toNamed(routeName.setting);
    }
  }
}
