import '../../../../config.dart';

class StatusListBodyLayout extends StatelessWidget {
  const StatusListBodyLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            //current user status
            CurrentUserStatus(
                    currentUserId:
                        statusCtrl.user != null ? statusCtrl.user["phone"] : "")
                .marginSymmetric(vertical: Insets.i10),
            const VSpace(Sizes.s5),
            if (statusCtrl.statusList.isNotEmpty)
              StatusClass().titleLayout(fonts.recentUpdates),
            if (statusCtrl.statusList.isNotEmpty) const VSpace(Sizes.s10),
            //all contacts user status list
            const StatusListLayout(),
            const VSpace(Sizes.s10),

            if(statusCtrl.allViewStatusList.isNotEmpty)
            StatusClass().titleLayout(fonts.viewUpdate),
                if(statusCtrl.allViewStatusList.isNotEmpty)
            const VSpace(Sizes.s10),
            //all contacts user status list
            const ViewAllStatusListLayout()
          ]).paddingSymmetric(horizontal: Insets.i10));
    });
  }
}
