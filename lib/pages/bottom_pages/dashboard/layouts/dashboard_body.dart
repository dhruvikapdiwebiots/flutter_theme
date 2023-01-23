import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../config.dart';

class DashboardBody extends StatelessWidget {
  final AsyncSnapshot<ConnectivityResult> ?snapshot;
  const DashboardBody({Key? key,this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (dashboardCtrl) {
        return DefaultTabController(
            length: 3,
            child: snapshot!.data == ConnectivityResult.none
                ? NoInternet(
                connectionStatus: dashboardCtrl.connectionStatus)
                : Scaffold(
                backgroundColor: appCtrl.appTheme.whiteColor,
                appBar: AppBar(
                  backgroundColor: appCtrl.appTheme.primary,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  actions: const [
                    PopUpAction(),
                  ],
                  title: Text(fonts.chatify.tr,
                      style: AppCss.poppinsblack16
                          .textColor(appCtrl.appTheme.white)),
                  bottom: const DashboardTab(),
                ),
                body: TabBarView(
                  controller: dashboardCtrl.controller,
                  children: dashboardCtrl.widgetOptions,
                )));
      }
    );
  }
}
