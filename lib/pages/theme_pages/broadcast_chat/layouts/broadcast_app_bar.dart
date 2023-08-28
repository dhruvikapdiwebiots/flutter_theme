import 'package:flutter/services.dart';

import '../../../../config.dart';

class BroadCastAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? name, nameList;

  const BroadCastAppBar({Key? key, this.name, this.nameList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return AppBar(
          backgroundColor: appCtrl.appTheme.whiteColor,
          shadowColor: const Color.fromRGBO(255, 255, 255, 0.08),
          bottomOpacity: 0.0,
          elevation: 18,
          shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 1)),
          automaticallyImplyLeading: false,
          leadingWidth: Sizes.s70,
          toolbarHeight: Sizes.s90,
          titleSpacing: 0,
          actions: [
           if(chatCtrl.selectedIndexId.isNotEmpty)
                Row(children: [
              chatCtrl.selectedIndexId.length > 1
                  ? Container()
                  : CommonSvgIcon(icon: svgAssets.star)
                  .marginSymmetric(vertical: Insets.i22)
                  .inkWell(onTap: () {
                int index =0;
                chatCtrl.selectedIndexId.asMap().entries.forEach((e) {
                  chatCtrl.localMessage.asMap().entries.forEach((element) {
                    index = element.value.message!.indexWhere((element) => element.docId == e.value );

                    if(index >0) {
                      chatCtrl.localMessage[element.key]
                          .message![index].isFavourite =
                      true;
                      chatCtrl.localMessage[element.key]
                          .message![index].favouriteId =
                      appCtrl.user["id"];
                    }
                  });
                  chatCtrl.update();

                });
                chatCtrl.showPopUp = false;
                chatCtrl.enableReactionPopup = false;
                chatCtrl.selectedIndexId
                    .asMap()
                    .entries
                    .forEach((element) async {
                  await FirebaseFirestore.instance
                      .collection(collectionName.users)
                      .doc(appCtrl.user["id"])
                      .collection(collectionName.broadcastMessage)
                      .doc(chatCtrl.pId)
                      .collection(collectionName.chat)
                      .doc(element.value)
                      .update({"isFavourite": true,"favouriteId":chatCtrl.userData["id"]});
                });
                chatCtrl.selectedIndexId = [];
                chatCtrl.update();
              }),
              CommonSvgIcon(icon: svgAssets.trash)
                  .marginSymmetric(
                  vertical: Insets.i22, horizontal: Insets.i20)
                  .inkWell(onTap: () => chatCtrl.buildPopupDialog())
            ])
              ,
            PopupMenuButton(
              color: appCtrl.appTheme.whiteColor,
              padding: EdgeInsets.zero,
              iconSize: Sizes.s20,
              onSelected: (result) async {
                if(result ==0){
                  int index = chatCtrl.message.indexWhere((element) {

                    return element.id == chatCtrl.selectedIndexId[0];
                  });

                  var data ={
                    "backgroundImage" :chatCtrl.broadData["backgroundImage"],
                    "message": decryptMessage(
                        chatCtrl.message[index].data()["content"]),
                    "messageType" :chatCtrl.message[index].data()["type"] ,
                    "seenBy": chatCtrl.message[index].data()["seenMessageList"]
                  };
                  Get.toNamed(routeName.myMessageViewer,arguments: data);
                }else
                if (result == 1) {
                  int index = chatCtrl.message.indexWhere((element) {

                    return element.id == chatCtrl.selectedIndexId[0];
                  });

                  Clipboard.setData(ClipboardData(
                      text: decryptMessage(
                          chatCtrl.message[index].data()["content"])));
                } else if (result == 2) {
                  Get.toNamed(routeName.backgroundList,
                      arguments: {"broadcastId": chatCtrl.pId})!
                      .then((value) {

                    if (value != null && value != "") {
                      chatCtrl.wallPaperConfirmation(value);
                    } else {
                      chatCtrl.broadData["backgroundImage"] = null;
                      chatCtrl.update();
                    }
                  });
                }else if (result == 3) {
                  chatCtrl.clearChatConfirmation();
                }
              },
              offset: Offset(0.0, appBarHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              itemBuilder: (ctx) => chatCtrl.selectedIndexId.isNotEmpty
                  ? [
                if(chatCtrl.selectedIndexId.length ==1)
                  _buildPopupMenuItem(fonts.info, svgAssets.info, 0),
                if (chatCtrl.selectedIndexId.length == 1)
                  _buildPopupMenuItem(fonts.copy, svgAssets.copy, 1,isDivider: false)
              ]
                  : [

                _buildPopupMenuItem(fonts.wallpaper, svgAssets.gallery, 2),
                _buildPopupMenuItem(fonts.clearChat, svgAssets.trash, 3,isDivider: false),
              ],
              child: SvgPicture.asset(
                svgAssets.more,
                height: Sizes.s22,
                color: appCtrl.appTheme.blackColor,
              ).paddingAll(Insets.i10),
            )
                .decorated(
                color: appCtrl.appTheme.whiteColor,
                boxShadow: [
                  const BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 5,
                      spreadRadius: 1,
                      color: Color.fromRGBO(0, 0, 0, 0.05))
                ],
                borderRadius: BorderRadius.circular(AppRadius.r10))
                .marginSymmetric(vertical: Insets.i23)
                .marginOnly(right: Insets.i20)
          ],
          leading: SvgPicture.asset(
                  appCtrl.isRTL ? svgAssets.arrowForward : svgAssets.arrowBack,
                  color: appCtrl.appTheme.blackColor,
                  height: Sizes.s18)
              .paddingAll(Insets.i10)
              .decorated(
                  borderRadius: BorderRadius.circular(AppRadius.r10),
                  boxShadow: [
                    const BoxShadow(
                        offset: Offset(0, 2),
                        blurRadius: 5,
                        spreadRadius: 2,
                        color: Color.fromRGBO(0, 0, 0, 0.05))
                  ],
                  color: appCtrl.appTheme.whiteColor)
              .marginOnly(
                  right: Insets.i10,
                  top: Insets.i22,
                  bottom: Insets.i22,
                  left: Insets.i20)
              .inkWell(onTap: () => Get.back()),
          title:chatCtrl.selectedIndexId.isNotEmpty
              ? Text(
            chatCtrl.selectedIndexId.length.toString(),
            style: AppCss.poppinsMedium16
                .textColor(appCtrl.appTheme.blackColor),
          ).marginSymmetric(horizontal: Insets.i2)
              :   Row(
            children: [
              Container(
                height: Sizes.s40,
                width: Sizes.s40,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                    color: const Color(0xff3282B8),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1),
                    ),
                    image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: NetworkImage('${chatCtrl.pName}'))),
                child: Text(
                    chatCtrl.pName != null ?   chatCtrl.pName!.length > 2
                      ? chatCtrl.pName!.replaceAll(" ", "").substring(0, 2).toUpperCase()
                      : chatCtrl.pName![0] : "B",
                  style:
                      AppCss.poppinsblack16.textColor(appCtrl.appTheme.white),
                ),
              ),
              const HSpace(Sizes.s10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  name ?? "",
                  textAlign: TextAlign.center,
                  style: AppCss.poppinsBold16
                      .textColor(appCtrl.appTheme.blackColor),
                ),
                const VSpace(Sizes.s5),
                Text(
                  nameList!,
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.blackColor),
                )
              ]),
            ],
          ).inkWell(onTap: ()=> Get.toNamed(routeName.broadcastProfile)));
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(Sizes.s85);

  PopupMenuItem _buildPopupMenuItem(
      String title, String iconData, int position, {isDivider = true}) {
    return PopupMenuItem(
      value: position,
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconData,
                height: Sizes.s20,
                color: appCtrl.appTheme.blackColor,
              ),
              const HSpace(Sizes.s5),
              Text(
                title.tr,
                style: AppCss.poppinsMedium14
                    .textColor(appCtrl.appTheme.blackColor),
              )
            ],
          ),
          if (isDivider)
            Divider(
              color: appCtrl.appTheme.txtColor.withOpacity(.20),
              height: 0,
              thickness: 1,
            ).marginOnly(top: Insets.i15)
        ],
      ).width(Sizes.s170),
    );
  }
}
