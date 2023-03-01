import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../config.dart';

class DashboardBody extends StatelessWidget {
  final AsyncSnapshot<ConnectivityResult>? snapshot;

  const DashboardBody({Key? key, this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return DefaultTabController(
          length: 3,
          child: snapshot!.data == ConnectivityResult.none
              ? NoInternet(connectionStatus: dashboardCtrl.connectionStatus)
              : Scaffold(
                  backgroundColor: appCtrl.appTheme.bgColor,
                  appBar: AppBar(
                    backgroundColor: appCtrl.appTheme.bgColor,
                    automaticallyImplyLeading: false,
                    leading: SvgPicture.asset(svgAssets.menu)
                        .paddingAll(Insets.i10)
                        .decorated(
                            color: appCtrl.appTheme.white,boxShadow: [BoxShadow(offset: Offset(0,2),blurRadius: 15,color: appCtrl.appTheme.lightGray)],
                            borderRadius: BorderRadius.circular(AppRadius.r10)).marginAll( Insets.i10),
                    elevation: 0,
                    actions: const [],
                    title: Text(fonts.chatify.tr,
                        style: AppCss.poppinsblack16
                            .textColor(appCtrl.appTheme.white)),
                    bottom: const DashboardTab(),
                  ),
                  body: TabBarView(
                    controller: dashboardCtrl.controller,
                    children: dashboardCtrl.widgetOptions,
                  )));
    });
  }
}
