import 'dart:developer';

import 'package:flutter_theme/controllers/fetch_contact_controller.dart';
import 'package:provider/provider.dart';

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
          return Consumer<FetchContactController>(
              builder: (context, availableContacts, _child) {

            return Stack(
              children: [
                Container(
                    alignment: Alignment.topCenter,
                    width: MediaQuery.of(context).size.width,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                 /*     ...availableContacts.alreadyJoinedSavedUsersPhoneNameAsInServer
                          .asMap()
                          .entries
                          .map((e) {
                        return StatusListStream(id: e.value.id);
                      }),*/
                      ListView.builder(
                          itemCount: statusCtrl.statusList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                log("LENGTH : ${statusCtrl.statusList.length}");
                                Get.toNamed(routeName.statusView,
                                    arguments: statusCtrl.statusList[index]);
                              },
                              child: StatusListCard(
                                  snapshot: statusCtrl.statusList[index]),
                            );
                          })
                    ]))

/*                 if (!statusCtrl.isData)
                        CommonEmptyLayout(
                          gif: gifAssets.status,
                          title: fonts.emptyStatusTitle.tr,
                          desc: fonts.emptyStatusDesc,
                        ).height(MediaQuery.of(context).size.height / 2)*/
              ],
            );
          });
        });
      });
    });
  }
}
