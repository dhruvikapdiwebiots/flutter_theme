import 'dart:developer';

import 'package:flutter/services.dart';
import '../../../../config.dart';

class GroupChatMessageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? name, image;
  final VoidCallback? callTap, moreTap, videoTap;

  const GroupChatMessageAppBar(
      {Key? key,
      this.name,
      this.callTap,
      this.image,
      this.videoTap,
      this.moreTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
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
                        spreadRadius: 1,
                        color: Color.fromRGBO(0, 0, 0, 0.05))
                  ],
                  color: appCtrl.appTheme.whiteColor)
              .marginOnly(
                  right: Insets.i10,
                  top: Insets.i22,
                  bottom: Insets.i22,
                  left: Insets.i20)
              .inkWell(onTap: () => Get.back()),
          actions: [
            chatCtrl.isChatSearch == true
                ? Row(
                    children: [
                      SvgPicture.asset(svgAssets.search).inkWell(
                          onTap: () async {
                        if (chatCtrl.txtChatSearch.text.isEmpty) {
                          chatCtrl.isChatSearch = false;
                          chatCtrl.update();
                        } else {
                          chatCtrl.count = chatCtrl.count ?? 0;

                          chatCtrl.update();
                          if (chatCtrl.count! >= chatCtrl.searchChatId.length) {
                            chatCtrl.count = 0;
                          }
                          final contentSize = chatCtrl.listScrollController
                                  .position.viewportDimension +
                              chatCtrl.listScrollController.position
                                  .maxScrollExtent;

                          final target = contentSize *
                              chatCtrl.searchChatId[chatCtrl.count!] /
                              chatCtrl.message.length;

                          if (!chatCtrl.selectedIndexId.contains(
                              chatCtrl.searchChatId[chatCtrl.count!])) {
                            chatCtrl.selectedIndexId.add(chatCtrl
                                .message[chatCtrl.searchChatId[chatCtrl.count!]]
                                .id);
                          }
                          // Scroll to that position.
                          chatCtrl.listScrollController.position.animateTo(
                            target,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeInOut,
                          );

                          if (chatCtrl.count! >= chatCtrl.searchChatId.length) {
                            chatCtrl.count = 0;
                          } else {
                            chatCtrl.count = chatCtrl.count! + 1;
                          }
                          await Future.delayed(Durations.s1).then((value) {
                            chatCtrl.selectedIndexId = [];
                            chatCtrl.update();
                          });
                          chatCtrl.update();
                          log("chatCtrl.selectedIndexId : ${chatCtrl.selectedIndexId}");
                        }
                      }),
                      const HSpace(Sizes.s10)
                    ],
                  )
                : chatCtrl.selectedIndexId.isNotEmpty
                    ? Row(children: [
                        chatCtrl.selectedIndexId.length > 1
                            ? Container()
                            : CommonSvgIcon(icon: svgAssets.star)
                                .marginSymmetric(vertical: Insets.i22)
                                .inkWell(onTap: () {
                                chatCtrl.showPopUp = false;
                                chatCtrl.enableReactionPopup = false;
                                chatCtrl.selectedIndexId
                                    .asMap()
                                    .entries
                                    .forEach((element) async {
                                  await FirebaseFirestore.instance
                                      .collection(collectionName.groupMessage)
                                      .doc(chatCtrl.pId)
                                      .collection(collectionName.chat)
                                      .doc(element.value)
                                      .update({"isFavourite": true,"favouriteId":chatCtrl.user["id"]});
                                });
                                chatCtrl.selectedIndexId = [];
                                chatCtrl.update();
                              }),
                        CommonSvgIcon(icon: svgAssets.trash)
                            .marginSymmetric(
                                vertical: Insets.i22, horizontal: Insets.i20)
                            .inkWell(onTap: () => chatCtrl.buildPopupDialog())
                      ])
                    : Row(children: [
                        CommonSvgIcon(icon: svgAssets.video)
                            .marginSymmetric(vertical: Insets.i22)
                            .inkWell(onTap: videoTap),
                        CommonSvgIcon(icon: svgAssets.call)
                            .marginSymmetric(
                                horizontal: Insets.i10, vertical: Insets.i22)
                            .inkWell(onTap: callTap)
                      ]),
            PopupMenuButton(
              color: appCtrl.appTheme.whiteColor,
              padding: EdgeInsets.zero,
              iconSize: Sizes.s20,
              onSelected: (result) async {
                if(result ==0){
                  int index = chatCtrl.message.indexWhere((element) {
                    log("element.id : ${element.id}");
                    return element.id == chatCtrl.selectedIndexId[0];
                  });
                  log("seenMessageList : ${chatCtrl.message[index].data()["seenMessageList"]}");
                  var data ={
                    "backgroundImage" :chatCtrl.backgroundImage,
                    "message": decryptMessage(
                        chatCtrl.message[index].data()["content"]),
                    "messageType" :chatCtrl.message[index].data()["type"] ,
                    "seenBy": chatCtrl.message[index].data()["seenMessageList"]
                  };
                  Get.toNamed(routeName.myMessageViewer,arguments: data);
                }else
                if (result == 1) {
                  int index = chatCtrl.message.indexWhere((element) {
                    log("element.id : ${element.id}");
                    return element.id == chatCtrl.selectedIndexId[0];
                  });
                  log("index : $index");
                  Clipboard.setData(ClipboardData(
                      text: decryptMessage(
                          chatCtrl.message[index].data()["content"])));
                } else if (result == 2) {
                  chatCtrl.isChatSearch = true;
                  chatCtrl.update();
                } else if (result == 4) {
                  List userId = [];
                  chatCtrl.clearChatId.add(chatCtrl.user["id"]);
                  chatCtrl.update();
                  await FirebaseFirestore.instance
                      .collection(collectionName.users)
                      .doc(chatCtrl.user["id"])
                      .collection(collectionName.chats)
                      .where("groupId", isEqualTo: chatCtrl.pId)
                      .limit(1)
                      .get()
                      .then((value) async {
                    if (value.docs.isNotEmpty) {
                      userId = value.docs[0].data()["clearChatId"] ?? [];
                      userId.add(chatCtrl.user["id"]);
                      await FirebaseFirestore.instance
                          .collection(collectionName.users)
                          .doc(chatCtrl.user["id"])
                          .collection(collectionName.chats)
                          .doc(value.docs[0].id)
                          .update({"clearChatId": userId});
                    }
                  }).then((value) async {
                    await FirebaseFirestore.instance
                        .collection(collectionName.groups)
                        .where("groupId", isEqualTo: chatCtrl.pId)
                        .limit(1)
                        .get()
                        .then((group) async {
                      await FirebaseFirestore.instance
                          .collection(collectionName.groups)
                          .doc(group.docs[0].id)
                          .update({"clearChatId": userId});
                    });
                  });
                }
              },
              offset: Offset(0.0, appBarHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              itemBuilder: (ctx) => chatCtrl.selectedIndexId.isNotEmpty
                  ? [
                    if(chatCtrl.selectedIndexId.length ==1)
                      _buildPopupMenuItem("Info", svgAssets.info, 0),
                      if (chatCtrl.selectedIndexId.length == 1)
                        _buildPopupMenuItem("Copy", svgAssets.copy, 1)
                    ]
                  : [
                      _buildPopupMenuItem("Search", svgAssets.search, 2),
                      _buildPopupMenuItem("Wallpaper", svgAssets.gallery, 3),
                      _buildPopupMenuItem("Clear Chat", svgAssets.trash, 4),
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
          title: chatCtrl.isChatSearch
              ? chatCtrl.searchTextField()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CommonImage(
                        image: image,
                        name: name,
                        height: Sizes.s40,
                        width: Sizes.s40),
                    const HSpace(Sizes.s8),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name ?? "",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: AppCss.poppinsSemiBold14
                                  .textColor(appCtrl.appTheme.blackColor),
                            ),
                            const VSpace(Sizes.s6),
                            const GroupUserLastSeen()
                          ]).marginSymmetric(vertical: Insets.i2),
                    )
                  ],
                ).inkWell(onTap: () async {
                  await chatCtrl.getPeerStatus();
                  Get.toNamed(routeName.groupProfile);
                }));
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(Sizes.s85);

  PopupMenuItem _buildPopupMenuItem(
      String title, String iconData, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        children: [
          SvgPicture.asset(iconData),
          const HSpace(Sizes.s5),
          Text(
            title,
            style:
                AppCss.poppinsMedium14.textColor(appCtrl.appTheme.blackColor),
          ),
        ],
      ),
    );
  }
}
