import 'dart:developer';

import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:flutter_theme/pages/bottom_pages/status/layouts/status_list_card.dart';
import 'package:provider/provider.dart';

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
        return GetBuilder<DashboardController>(builder: (dashboardCtrl) {
          return Consumer<FetchContactController>(
              builder: (context, registerAvailableContact,child) {
log("ALLL : ${statusCtrl.allViewStatusList.length}");
            return Stack(
              children: [
                Container(
                    alignment: Alignment.topCenter,
                    width: MediaQuery.of(context).size.width,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [

                      ListView.builder(
                          itemCount: statusCtrl.allViewStatusList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Get.toNamed(routeName.statusView,
                                    arguments: statusCtrl.allViewStatusList[index]);
                              },
                              child: StatusListCard(snapshot: statusCtrl.allViewStatusList[index],isSeen: true,),
                            );
                          })
                    ])),
              ],
            );
          });
        });
      });
    });
  }
}
