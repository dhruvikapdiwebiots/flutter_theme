import 'dart:developer';

import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_list_card.dart';

import '../../../../config.dart';

class ViewAllStatusListLayout extends StatefulWidget {
  const ViewAllStatusListLayout({Key? key}) : super(key: key);

  @override
  State<ViewAllStatusListLayout> createState() =>
      _ViewAllStatusListLayoutState();
}

class _ViewAllStatusListLayoutState extends State<ViewAllStatusListLayout> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {

      return GetBuilder<AppController>(builder: (appCtrl) {
        return GetBuilder<DashboardController>(
          builder: (dashboardCtrl) {
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
              ],
            );
          }
        );
      });
    });
  }
}
