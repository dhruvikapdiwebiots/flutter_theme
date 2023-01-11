import '../../../../config.dart';

class DashboardTab extends StatelessWidget with PreferredSizeWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardCtrl) {
        return TabBar(
            controller: dashboardCtrl.controller,
            labelColor: appCtrl.isTheme?appCtrl.appTheme.secondary : appCtrl.appTheme.primary,
            unselectedLabelColor: appCtrl.appTheme.white,
            indicatorSize: TabBarIndicatorSize.label,
            padding: EdgeInsets.zero,
            labelStyle: AppCss.poppinsMedium14,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            indicatorWeight: 0,
            onTap: (val) {
              dashboardCtrl.onTapSelect(val);
            },
            indicator: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: appCtrl.appTheme.whiteColor),
            tabs: [
              ...dashboardCtrl.bottomList
                  .asMap()
                  .entries
                  .map((e) => Tab(
                iconMargin: EdgeInsets.zero,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                      trans(e.value["title"]).toUpperCase()),
                ),
              ))
                  .toList()
            ]);
      }
    );
  }
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
