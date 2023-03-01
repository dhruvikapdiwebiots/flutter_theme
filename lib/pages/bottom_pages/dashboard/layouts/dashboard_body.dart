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
                    leadingWidth: Sizes.s80,
                    leading: SvgPicture.asset(svgAssets.menu, height: Sizes.s20)
                        .paddingAll(Insets.i8)
                        .decorated(
                            color: appCtrl.appTheme.white,
                            boxShadow: [
                              const BoxShadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 15,
                                  color: Color.fromRGBO(0, 0, 0, 0.08))
                            ],
                            borderRadius: BorderRadius.circular(AppRadius.r10))
                        .marginSymmetric(
                            horizontal: Insets.i20, vertical: Insets.i10),
                    elevation: 0,
                    actions: [
                      SvgPicture.asset(svgAssets.search, height: Sizes.s20)
                          .paddingAll(Insets.i12)
                          .decorated(
                              color: appCtrl.appTheme.white,
                              boxShadow: [
                                const BoxShadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 15,
                                    color: Color.fromRGBO(0, 0, 0, 0.08))
                              ],
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10))
                          .marginSymmetric(vertical: Insets.i5),
                      SvgPicture.asset(svgAssets.more, height: Sizes.s20)
                          .paddingAll(Insets.i12)
                          .decorated(
                              color: appCtrl.appTheme.white,
                              boxShadow: [
                                const BoxShadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 15,
                                    color: Color.fromRGBO(0, 0, 0, 0.08))
                              ],
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10))
                          .marginSymmetric(
                              vertical: Insets.i5, horizontal: Insets.i15),
                    ],
                    centerTitle: true,
                    title: Text(fonts.chatify.tr,
                        style: AppCss.poppinsSemiBold16
                            .textColor(appCtrl.appTheme.primary)),
                    bottom: const DashboardTab(),
                  ),
                  body: TabBarView(
                    controller: dashboardCtrl.controller,
                    children: dashboardCtrl.widgetOptions,
                  )));
    });
  }
}
