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
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration:const BoxDecoration(boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(49, 100, 189, 0.08),
                blurRadius: 15,
                spreadRadius: 2
            )
          ]),
          child: AppBar(
              backgroundColor: appCtrl.appTheme.whiteColor,

              shadowColor: const Color.fromRGBO(255, 255, 255, 0.08),
              bottomOpacity: 0.0,
              elevation: 25,
              shape: SmoothRectangleBorder(
                  borderRadius:
                  SmoothBorderRadius(cornerRadius: 22, cornerSmoothing: 1)),
              automaticallyImplyLeading: false,
              leadingWidth: Sizes.s70,
              toolbarHeight: Sizes.s90,
              titleSpacing: 0,
              leading: SvgPicture.asset(
                  appCtrl.isRTL ? svgAssets.arrowForward : svgAssets.arrowBack,

                  colorFilter: ColorFilter.mode(appCtrl.appTheme.blackColor, BlendMode.srcIn),
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
                  .inkWell(onTap: ()  {
                    chatCtrl.onBackPress();
                    Get.back();}),
              actions: [
                chatCtrl.isChatSearch == true
                    ? Row(
                  children: [
                    SvgPicture.asset(svgAssets.search).inkWell(
                        onTap: () async {
log("CHECLL");
                          FocusScope.of(context).unfocus();
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
                                chatCtrl.localMessage.length;

                            log("DOCID L ${chatCtrl.searchChatId[chatCtrl.count!]}");
                            if (!chatCtrl.selectedIndexId.contains(
                              chatCtrl.searchChatId[chatCtrl.count!])) {
                            chatCtrl.localMessage.asMap().entries.forEach((element) {
                              element.value.message!.asMap().entries.forEach((e) {
                                if(e.key ==chatCtrl.searchChatId[chatCtrl.count!] ) {
                                  chatCtrl.selectedIndexId.add(e.value.docId);
                                }
                              });
                            });

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
                            await Future.delayed(DurationClass.s1).then((value) {
                              chatCtrl.selectedIndexId = [];
                              chatCtrl.update();
                            });
                            chatCtrl.update();
                            chatCtrl.getPeerStatus();

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
                    int index =0;
                    chatCtrl.selectedIndexId.asMap().entries.forEach((e) {
                      chatCtrl.localMessage.asMap().entries.forEach((element) {
                        index = element.value.message!.indexWhere((element) => element.docId == e.value );
                        log("index : $index");
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
                    :PopupMenuButton(
                  color: appCtrl.appTheme.whiteColor,
                  padding: EdgeInsets.zero,
                  constraints:const BoxConstraints(maxWidth: Sizes.s170),
                  iconSize: Sizes.s20,
                  onSelected: (result) async {

                    if (result == 0) {
                      callTap;
                    } else if (result == 2) {
                      videoTap;
                    }
                  },
                  offset: Offset(0.0, appBarHeight),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppRadius.r8)),
                  itemBuilder: (ctx) => [
                    _buildPopupMenuItem(
                        "audio", svgAssets.audio, 0),
                    _buildPopupMenuItem("video", svgAssets.video, 1,
                        isDivider: false),
                  ],
                  child: SvgPicture.asset(
                      svgAssets.audioVideo,
                      height: Sizes.s22,
                      colorFilter: ColorFilter.mode(appCtrl.appTheme.blackColor, BlendMode.srcIn)
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
                    borderRadius:
                    BorderRadius.circular(AppRadius.r10))
                    .marginSymmetric(vertical: Insets.i23)
                    .marginOnly(right: Insets.i20),
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

                        return element.id == chatCtrl.selectedIndexId[0];
                      });

                      Clipboard.setData(ClipboardData(
                          text: decryptMessage(
                              chatCtrl.message[index].data()["content"])));
                    } else if (result == 2) {
                      chatCtrl.isChatSearch = true;
                      chatCtrl.update();
                    }else if (result == 2) {
                      Get.toNamed(routeName.backgroundList,
                          arguments: {"groupId": chatCtrl.pId})!
                          .then((value) {

                        if (value != null && value != "") {
                          chatCtrl.wallPaperConfirmation(value);
                        } else {
                          chatCtrl.allData["backgroundImage"] = null;
                          chatCtrl.update();
                        }
                      });
                    } else if (result == 4) {
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
                    _buildPopupMenuItem(fonts.search, svgAssets.search, 2),
                    _buildPopupMenuItem(fonts.wallpaper, svgAssets.gallery, 3),
                    _buildPopupMenuItem(fonts.clearChat, svgAssets.trash, 4,isDivider: false),
                  ],
                  child: SvgPicture.asset(
                    svgAssets.more,
                    height: Sizes.s22,
                      colorFilter: ColorFilter.mode(appCtrl.appTheme.blackColor, BlendMode.srcIn)
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
              title:chatCtrl.selectedIndexId.isNotEmpty
                  ? Text(
                chatCtrl.selectedIndexId.length.toString(),
                style: AppCss.poppinsMedium16
                    .textColor(appCtrl.appTheme.blackColor),
              ).marginSymmetric(horizontal: Insets.i2)
                  : chatCtrl.isChatSearch
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
              }))
        ),
      );
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
                  colorFilter: ColorFilter.mode(appCtrl.appTheme.blackColor, BlendMode.srcIn)
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
