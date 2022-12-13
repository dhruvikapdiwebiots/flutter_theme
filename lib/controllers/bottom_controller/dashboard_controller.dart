
import 'package:flutter_theme/config.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;

  late int iconCount = 0;
  List bottomList = [];

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
    update();
    super.onReady();
  }
}
