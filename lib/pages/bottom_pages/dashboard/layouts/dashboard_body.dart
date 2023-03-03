import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../config.dart';

class DashboardBody extends StatelessWidget {
  final AsyncSnapshot<ConnectivityResult>? snapshot;

  const DashboardBody({Key? key, this.snapshot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
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
                    toolbarHeight: 80,
                    elevation: 0,
                    actions: [
                      SvgPicture.asset(svgAssets.search, height: Sizes.s20)
                          .paddingAll(Insets.i10)
                          .decorated(
                              color: appCtrl.appTheme.white,
                              boxShadow: [
                                const BoxShadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                    color: Color.fromRGBO(0, 0, 0, 0.08))
                              ],
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10))
                          .marginSymmetric(vertical: Insets.i5)
                          .paddingSymmetric(vertical: Insets.i14),
                      PopupMenuButton(
                        color: appCtrl.appTheme.whiteColor,
                        padding: EdgeInsets.zero,
                        icon:
                            SvgPicture.asset(svgAssets.more, height: Sizes.s20),
                        onSelected: (result){
                         dashboardCtrl.onMenuItemSelected(result);
                        },
                        offset: Offset(0.0, appBarHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                        ),
                        itemBuilder: (ctx) => dashboardCtrl.selectedIndex == 0
                            ? [
                                _buildPopupMenuItem(fonts.broadCast.tr,
                                    Icons.search,0),
                                _buildPopupMenuItem(fonts.create.tr,
                                    Icons.upload, 1),
                                _buildPopupMenuItem(fonts.setting.tr,
                                    Icons.copy,2),
                              ]
                            : [
                                _buildPopupMenuItem(fonts.setting.tr,
                                    Icons.copy, 2),
                              ],
                      )
                          .decorated(
                              color: appCtrl.appTheme.white,
                              boxShadow: [
                                const BoxShadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                    color: Color.fromRGBO(0, 0, 0, 0.08))
                              ],
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10))
                          .marginSymmetric(
                              vertical: Insets.i5, horizontal: Insets.i15)
                          .paddingSymmetric(vertical: Insets.i14)
                    ],
                    title: Image.asset(
                      imageAssets.logo,
                      height: Sizes.s30,
                      fit: BoxFit.fill,
                    ).paddingOnly(top: Insets.i10),
                    bottom: const DashboardTab(),
                  ),
                  body: TabBarView(
                    controller: dashboardCtrl.controller,
                    children: dashboardCtrl.widgetOptions,
                  )));
    });
  }

  PopupMenuItem _buildPopupMenuItem(
      String title, IconData iconData, int position) {
    return PopupMenuItem(
      value: position,

      child: Text(title),
    );
  }
}
