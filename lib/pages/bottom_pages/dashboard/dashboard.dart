
import 'package:flutter_theme/config.dart';

class Dashboard extends StatelessWidget {
  final dashboardCtrl = Get.put(DashboardController());
   Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (_) {
        return Scaffold(
            body: dashboardCtrl.widgetOptions
                .elementAt(dashboardCtrl.selectedIndex),
          bottomNavigationBar: dashboardCtrl.bottomList.isNotEmpty
              ? BottomNavBar(onItemSelected: (index) => dashboardCtrl.onTapSelect(index),bottomNavBarList: dashboardCtrl.bottomList,selectedIndex: dashboardCtrl.selectedIndex)
              : Container(),
        );
      }
    );
  }
}
