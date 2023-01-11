import '../../../../config.dart';

class PopUpAction extends StatelessWidget {
  const PopUpAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardCtrl) {
        return dashboardCtrl.selectedIndex == 0 ? PopupMenuButton(
          color: appCtrl.appTheme.whiteColor,
            icon: Icon(Icons.more_vert, color: appCtrl.appTheme.white),
            itemBuilder: (context) {
              return [

                ...dashboardCtrl.actionList
                    .asMap()
                    .entries
                    .map((e) => PopupMenuItem<int>(
                  value: 0,
                  onTap: (){
                    dashboardCtrl.selectedPopTap = e.key;
                    dashboardCtrl.update();
                  },
                  child: Text(trans(e.value["title"]),style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.blackColor),),
                ))
                    .toList(),
              ];
            },
            onSelected: (value) =>
                dashboardCtrl.popupMenuTap(value)) : PopupMenuButton(
            color: appCtrl.appTheme.whiteColor,
            icon: Icon(Icons.more_vert, color: appCtrl.appTheme.white),
            itemBuilder: (context) {
              return [

                ...dashboardCtrl.statusAction
                    .asMap()
                    .entries
                    .map((e) => PopupMenuItem<int>(
                  value: 0,
                  onTap: (){
                    dashboardCtrl.selectedPopTap = e.key;
                    dashboardCtrl.update();
                  },
                  child: Text(trans(e.value["title"]),style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.blackColor),),
                ))
                    .toList(),
              ];
            },
            onSelected: (value) =>
                dashboardCtrl.popupMenuTap(value));
      }
    );
  }
}
