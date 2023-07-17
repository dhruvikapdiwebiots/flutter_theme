import 'dart:developer';

import '../../../../config.dart';

class ClearDialog extends StatelessWidget {
  const ClearDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
          return Align(
              alignment: Alignment.center,
              child: Container(
                  height: Sizes.s150,
                  color: appCtrl.appTheme.whiteColor,
                  margin: const EdgeInsets.symmetric(
                      horizontal: Insets.i10, vertical: Insets.i15),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Insets.i10, vertical: Insets.i15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fonts.clearChatId.tr,
                        style: AppCss.poppinsblack16
                            .textColor(appCtrl.appTheme.blackColor),
                      ),
                      const VSpace(Sizes.s12),
                      Text(
                        fonts.deleteOptions.tr,
                        style: AppCss.poppinsMedium14
                            .textColor(appCtrl.appTheme.txtColor),
                      ),
                      const VSpace(Sizes.s20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: CommonButton(
                            title: fonts.cancel.tr,
                            onTap: () => Get.back(),
                            style: AppCss.poppinsMedium14
                                .textColor(appCtrl.appTheme.white),
                          )),
                          const HSpace(Sizes.s10),
                          Expanded(
                              child: CommonButton(
                                  onTap: () async {
                                    Get.back();
                                    log("PID : ${chatCtrl.pId}");
                                    await FirebaseFirestore.instance
                                        .collection(collectionName.users)
                                        .doc(appCtrl.user["id"])
                                        .collection(collectionName.groupMessage)
                                        .doc(chatCtrl.pId)
                                        .collection(collectionName.chat)
                                        .get()
                                        .then((value) {
                                      if (value.docs.isNotEmpty) {
                                        value.docs
                                            .asMap()
                                            .entries
                                            .forEach((element) {
                                          FirebaseFirestore.instance
                                              .collection(collectionName.users)
                                              .doc(appCtrl.user["id"])
                                              .collection(
                                                  collectionName.groupMessage)
                                              .doc(chatCtrl.pId)
                                              .collection(collectionName.chat)
                                              .doc(element.value.id)
                                              .delete();
                                        });
                                      }
                                    });
                                  },
                                  title: fonts.clearChat.tr,
                                  style: AppCss.poppinsMedium14
                                      .textColor(appCtrl.appTheme.white))),
                        ],
                      )
                    ],
                  )));
        });
      }),
    );
  }
}
