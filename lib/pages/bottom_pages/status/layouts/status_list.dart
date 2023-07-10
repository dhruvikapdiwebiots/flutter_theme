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
      return GetBuilder<AppController>(builder: (appCtrl) {
        log("statusCtrl.isData : ${statusCtrl.isData}");
        return Stack(
          children: [
            Container(
                alignment: Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                child: appCtrl.firebaseContact.isEmpty
                    ? Container()
                    : Column(mainAxisSize: MainAxisSize.min, children: [
                  ...appCtrl.firebaseContact.asMap().entries.map((e) {
                    return StatusListStream(id: e.value["id"]);
                  })
                ])),
            if(!statusCtrl.isData)
              CommonEmptyLayout(
                gif: gifAssets.status,
                title: fonts.emptyStatusTitle.tr,
                desc: fonts.emptyStatusDesc,
              )
          ],
        );
      });
    });
  }
}
