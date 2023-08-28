
import '../../../../config.dart';

class BroadcastChatWallPaper extends StatelessWidget {
  final String? image;
  const BroadcastChatWallPaper({Key? key,this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
              return Align(
                  alignment: Alignment.center,
                  child: Container(
                      height: 250,
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
                            "Set Wallpaper",
                            style: AppCss.poppinsblack14
                                .textColor(appCtrl.appTheme.blackColor),
                          ),

                          ListTile(
                            title: Text('Set For this chat "${chatCtrl.pName}"'),
                            leading: Radio(
                              value: "Person Name",
                              groupValue: chatCtrl.wallPaperType,
                              onChanged: (String? value) {
                                chatCtrl.wallPaperType = value;
                                chatCtrl.update();
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('For all chats'),
                            leading: Radio(
                              value: "For All",
                              groupValue: chatCtrl.wallPaperType,
                              onChanged: (String? value) {
                                chatCtrl.wallPaperType = value;
                                chatCtrl.update();
                              },
                            ),
                          ),
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

                                        if (chatCtrl.wallPaperType == "Person Name") {
                                          await FirebaseFirestore.instance
                                              .collection(collectionName.broadcast)
                                              .doc(chatCtrl.pId)

                                              .get()
                                              .then((userChat) {
                                            if (userChat.exists) {
                                              FirebaseFirestore.instance
                                                  .collection(collectionName.broadcast)
                                                  .doc(chatCtrl.pId)
                                                  .update({
                                                'backgroundImage': image
                                              });
                                            }
                                          });
                                        } else {
                                          FirebaseFirestore.instance
                                              .collection(collectionName.users)
                                              .doc(chatCtrl.userData["id"])
                                              .update(
                                              {'backgroundImage': image});
                                        }
                                        chatCtrl.broadData["backgroundImage"] =
                                            image;
                                        chatCtrl.update();
                                      },
                                      title: fonts.ok.tr,
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
