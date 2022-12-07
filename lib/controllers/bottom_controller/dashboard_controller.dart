import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/bottom_pages/message/message.dart';

class DashboardController extends GetxController{
  int selectedIndex = 0;

  late int iconCount = 0;
  List bottomList = [];


//list of bottommost page
  List<Widget> widgetOptions = <Widget>[
    Message(),
    Text("Message"),
    Text("Setting"),
  ];

  //on tap select
  onTapSelect (val)async {
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