import '../../../config.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardCtrl) {
        return BottomNavigationBar(
          selectedItemColor: appCtrl.appTheme.secondary,
          backgroundColor: appCtrl.appTheme.primary,
          selectedLabelStyle: AppCss.poppinsBold14
              .textColor(appCtrl.appTheme.whiteColor),
          unselectedItemColor: appCtrl.appTheme.accent,
          selectedIconTheme:
          IconThemeData(color: appCtrl.appTheme.secondary),
          unselectedLabelStyle: AppCss.poppinsMedium16
              .textColor(appCtrl.appTheme.primary),
          items: <BottomNavigationBarItem>[
            ...dashboardCtrl.bottomList
                .asMap()
                .entries
                .map((e) => BottomNavigationBarItem(
                icon: Icon(e.value["icon"])
                    .paddingOnly(bottom: Insets.i5),
                label: trans(e.value["title"])))
                .toList()
          ],
          currentIndex: dashboardCtrl.selectedIndex,
          onTap: (index) => dashboardCtrl.onTapSelect(index),
        );
      }
    );
  }
}
