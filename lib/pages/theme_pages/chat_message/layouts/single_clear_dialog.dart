import '../../../../config.dart';

class SingleClearDialog extends StatelessWidget {
  const SingleClearDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GetBuilder<ChatController>(builder: (chatCtrl) {
              return Align(
                  alignment: Alignment.center,
                  child: Container(
                      height: Sizes.s150,
                      color: appCtrl.appTheme.whiteColor,
                      margin: const EdgeInsets.symmetric(
                          horizontal: Insets.i10, vertical: Insets.i15),
                      padding: const EdgeInsets.symmetric(
                          horizontal: Insets.i15, vertical: Insets.i15),
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

                                        await FirebaseFirestore.instance
                                            .collection(collectionName.users)
                                            .doc(appCtrl.user["id"])
                                            .collection(collectionName.messages)
                                            .doc(chatCtrl.pId).delete();
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
