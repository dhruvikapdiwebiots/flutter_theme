import '../../../../config.dart';

class DashboardTab extends StatelessWidget implements PreferredSizeWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return GetBuilder<AppController>(
        builder: (appCtrl) {
          return TabBar(
                  controller: dashboardCtrl.controller,
                  labelColor: appCtrl.appTheme.primary,
                  unselectedLabelColor: appCtrl.appTheme.txtColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  padding: EdgeInsets.zero,
                  unselectedLabelStyle:
                      AppCss.poppinsMedium16.textColor(appCtrl.appTheme.txtColor),
                  labelStyle: AppCss.poppinsBold16.textColor(appCtrl.appTheme.primary),
                  indicatorPadding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.zero,
                  indicatorWeight: 2,
                  indicatorColor: appCtrl.appTheme.primary,
                  onTap: (val) {
                    dashboardCtrl.onTapSelect(val);
                  },
                  tabs: [
                ...dashboardCtrl.bottomList.asMap().entries.map((e) {
                  return Tab(
                      iconMargin: EdgeInsets.zero,
                      child: Align(
                          alignment: Alignment.center,
                          child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                    dashboardCtrl.selectedIndex == e.key
                                        ? e.value["iconSelected"]
                                        .toString()
                                        : e.value["icon"].toString()),
                                const HSpace(Sizes.s8),
                                Text(trans(e.value["title"]))
                              ])));
                }).toList()
              ])
              .decorated(
                  border: Border(
                      bottom: BorderSide(
                          color: appCtrl.appTheme.primary.withOpacity(.2))))
              .marginSymmetric(horizontal: Insets.i20);
        }
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
