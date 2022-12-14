import '../../../../config.dart';

class PopUpAction extends StatelessWidget {
  const PopUpAction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardCtrl) {
        return PopupMenuButton(
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
                  child: Text(trans(e.value["title"])),
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
