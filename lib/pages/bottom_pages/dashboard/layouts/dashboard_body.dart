
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config.dart';

class DashboardBody extends StatelessWidget {
  final AsyncSnapshot<ConnectivityResult>? snapshot;
  final SharedPreferences? pref;

  const DashboardBody({Key? key, this.snapshot, this.pref}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
      return Stack(
        children: [
          DefaultTabController(
              length: 3,
              child: snapshot!.data == ConnectivityResult.none
                  ? NoInternet(connectionStatus: dashboardCtrl.connectionStatus,pref: pref,)
                  : Scaffold(
                      backgroundColor: appCtrl.appTheme.bgColor,
                      appBar: AppBar(
                        backgroundColor: appCtrl.appTheme.bgColor,
                        automaticallyImplyLeading: false,
                        leadingWidth: Sizes.s80,
                        toolbarHeight: 80,
                        elevation: 0,
                        actions: [
                          if (!dashboardCtrl.isSearch)
                            Row(
                              children: [
                                SvgPicture.asset(
                                  svgAssets.search,
                                  height: Sizes.s20,
                                  colorFilter:ColorFilter.mode(appCtrl.appTheme.blackColor,BlendMode.srcIn)
                                )
                                    .paddingAll(Insets.i10)
                                    .decorated(
                                        color: appCtrl.appTheme.whiteColor,
                                        boxShadow: [
                                          const BoxShadow(
                                              offset: Offset(0, 2),
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.08))
                                        ],
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r10))
                                    .marginSymmetric(vertical: Insets.i18)
                                    .inkWell(onTap: () {
                                  dashboardCtrl.isSearch = true;
                                  dashboardCtrl.update();
                                }),
                              ],
                            ),
                          if (!dashboardCtrl.isSearch)
                            SizedBox(
                              width: Sizes.s62,
                              child: PopupMenuButton(
                                color: appCtrl.appTheme.whiteColor,
                                padding: EdgeInsets.zero,
                                icon: SvgPicture.asset(
                                  svgAssets.more,
                                  height: Sizes.s20,
                                  fit: BoxFit.fill,
                                  colorFilter:ColorFilter.mode(appCtrl.appTheme.blackColor,BlendMode.srcIn)
                                ),
                                onSelected: (result) {

                                  dashboardCtrl.onMenuItemSelected(result);
                                },
                                offset: Offset(0.0, appBarHeight),
                                iconSize: Sizes.s20,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r8),
                                ),
                                itemBuilder: (ctx) => dashboardCtrl
                                            .selectedIndex ==
                                        0
                                    ? [
                                        _buildPopupMenuItem(fonts.broadCast.tr,
                                            Icons.search, 0),
                                        _buildPopupMenuItem(
                                            fonts.setGroup.tr, Icons.upload, 1),
                                        _buildPopupMenuItem(
                                            fonts.setting.tr, Icons.copy, 2),
                                      ]
                                    : dashboardCtrl.selectedIndex == 1
                                        ? [
                                            _buildPopupMenuItem(
                                                fonts.setting.tr,
                                                Icons.copy,
                                                2),
                                          ]
                                        : [
                                            _buildPopupMenuItem(
                                                fonts.clearLog.tr,
                                                Icons.copy,
                                                3),
                                            _buildPopupMenuItem(
                                                fonts.setting.tr,
                                                Icons.copy,
                                                2),
                                          ],
                              )
                                  .decorated(
                                      color: appCtrl.appTheme.whiteColor,
                                      boxShadow: [
                                        const BoxShadow(
                                            offset: Offset(0, 2),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                            color:
                                                Color.fromRGBO(0, 0, 0, 0.08))
                                      ],
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r10))
                                  .marginSymmetric(
                                      vertical: Insets.i18,
                                      horizontal: Insets.i10),
                            )
                        ],
                        title: (!dashboardCtrl.isSearch)
                            ? Image.asset(
                                imageAssets.logo,
                                height: Sizes.s30,
                                fit: BoxFit.fill,
                              ).paddingOnly(top: Insets.i10)
                            : SizedBox(
                                height: Sizes.s50,
                                child: CommonTextBox(
                                    controller: dashboardCtrl.userText,
                                    textInputAction: TextInputAction.done,
                                    labelText: "Search...",
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: Insets.i16,
                                        vertical: Insets.i1),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: appCtrl.appTheme.blackColor,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r8)),
                                    keyboardType: TextInputType.multiline,
                                    onChanged: (val) {
                                      if(dashboardCtrl.selectedIndex == 0){
                                        dashboardCtrl.recentMessageSearch();
                                      } else if(dashboardCtrl.selectedIndex == 1){
                                        dashboardCtrl.statusSearch();
                                      }else {

                                        dashboardCtrl.onSearch(val);
                                        dashboardCtrl.update();
                                      }
                                    },
                                    suffixIcon: dashboardCtrl
                                            .userText.text.isNotEmpty
                                        ? Icon(CupertinoIcons.multiply,
                                                color: appCtrl.appTheme.white,
                                                size: Sizes.s15)
                                            .decorated(
                                                color: appCtrl
                                                    .appTheme.blackColor
                                                    .withOpacity(.3),
                                                shape: BoxShape.circle)
                                            .marginAll(Insets.i12)
                                            .inkWell(onTap: () {
                                            dashboardCtrl.isSearch = false;
                                            dashboardCtrl.userText.text = "";
                                            dashboardCtrl.update();
                                          })
                                        : SvgPicture.asset(svgAssets.search,
                                                height: Sizes.s15)
                                            .marginAll(Insets.i12)
                                            .inkWell(onTap: () {
                                            dashboardCtrl.isSearch = false;
                                            dashboardCtrl.userText.text = "";
                                            dashboardCtrl.update();
                                          })),
                              ),
                        bottom: const DashboardTab(),
                      ),
                      body: TabBarView(
                        controller: dashboardCtrl.controller,
                        children: dashboardCtrl.widgetOptions(pref),

                      ).inkWell(onTap: () {
                        dashboardCtrl.isSearch = false;
                        dashboardCtrl.update();
                      }))),
          if (appCtrl.isLoading)
            Container(
                color: appCtrl.appTheme.whiteColor.withOpacity(0.8),
                child: Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          appCtrl.appTheme.primary)),
                ))
        ],
      );
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
