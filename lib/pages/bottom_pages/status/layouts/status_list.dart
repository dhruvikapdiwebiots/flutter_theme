import 'dart:developer';

import '../../../../config.dart';

class StatusListLayout extends StatefulWidget {
  const StatusListLayout({Key? key}) : super(key: key);

  @override
  State<StatusListLayout> createState() => _StatusListLayoutState();
}

class _StatusListLayoutState extends State<StatusListLayout> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
        return GetBuilder<AppController>(builder: (appCtrl) {
          log("statusCtrl.isData : ${appCtrl.firebaseContact.length}");
          return Stack(
            children: [
              Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width,
                  child: appCtrl.firebaseContact.isEmpty
                      ? Container()
                      : dashboardCtrl.userText.text.isNotEmpty &&
                              dashboardCtrl.selectedIndex == 1
                          ? Column(mainAxisSize: MainAxisSize.min, children: [
                              ...appCtrl.firebaseContact
                                  .asMap()
                                  .entries
                                  .map((e) {
                                return e.value.isRegister == true
                                    ? e.value.name!.contains(
                                            dashboardCtrl.userText.text)
                                        ? StatusListStream(id: e.value.id)
                                        : Container()
                                    : Container();
                              })
                            ])
                          : Column(mainAxisSize: MainAxisSize.min, children: [
                              ...appCtrl.firebaseContact
                                  .asMap()
                                  .entries
                                  .map((e) {
                                return e.value.isRegister == true
                                    ? StatusListStream(id: e.value.id)
                                    : Container();
                              })
                            ])),
              if (!statusCtrl.isData)
                CommonEmptyLayout(
                  gif: gifAssets.status,
                  title: fonts.emptyStatusTitle.tr,
                  desc: fonts.emptyStatusDesc,
                ).height(MediaQuery.of(context).size.height / 2)
            ],
          );
        });
      });
    });
  }
}
