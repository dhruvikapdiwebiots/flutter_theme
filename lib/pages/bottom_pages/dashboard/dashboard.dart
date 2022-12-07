import 'package:flutter_theme/config.dart';

class Dashboard extends StatelessWidget {
  final dashboardCtrl = Get.put(DashboardController());

  Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (_) {
      return Scaffold(
        body:
            dashboardCtrl.widgetOptions.elementAt(dashboardCtrl.selectedIndex),
        bottomNavigationBar: dashboardCtrl.bottomList.isNotEmpty
            ? BottomNavigationBar(
                selectedItemColor: appCtrl.appTheme.secondary,
                backgroundColor: appCtrl.appTheme.primary,
                selectedLabelStyle:
                    AppCss.poppinsBold14.textColor(appCtrl.appTheme.whiteColor),
                unselectedItemColor: appCtrl.appTheme.accent,
                selectedIconTheme:
                    IconThemeData(color: appCtrl.appTheme.secondary),
                unselectedLabelStyle:
                    AppCss.poppinsMedium16.textColor(appCtrl.appTheme.primary),
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon:
                          const Icon(Icons.home).paddingOnly(bottom: Insets.i5),
                      label: 'Calls'),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.message)
                          .paddingOnly(bottom: Insets.i5),
                      label: 'Messages'),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.settings)
                          .paddingOnly(bottom: Insets.i5),
                      label: 'Setting')
                ],
                currentIndex: dashboardCtrl.selectedIndex,
                onTap: (index) => dashboardCtrl.onTapSelect(index),
              )
            : Container(),
      );
    });
  }
}
