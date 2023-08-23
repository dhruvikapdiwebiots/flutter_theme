import 'dart:developer';

import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_profile/group_images_video.dart';
import 'package:intl/intl.dart';
import '../../../../../config.dart';

class GroupProfileBody extends StatelessWidget {
  const GroupProfileBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(collectionName.groups)
              .doc(chatCtrl.pId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.exists) {
                chatCtrl.allData = snapshot.data!.data();
                if (chatCtrl.allData != null) {
                  List user = chatCtrl.allData["users"];
                  log("UUUU : ${user.length}");
                  chatCtrl.userList = user.length <= 5
                      ? user
                      : chatCtrl.allData["users"].getRange(0, 5);
                }
                chatCtrl.isThere = chatCtrl.userList.any(
                    (element) => element["id"].contains(chatCtrl.user["id"]));
                log("userList : ${chatCtrl.allData}");
              }
            }
            return Container(
                decoration: ShapeDecoration(
                    color: appCtrl.appTheme.bgColor,
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 20, cornerSmoothing: 1))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 10),
                          decoration: ShapeDecoration(
                              color: appCtrl.appTheme.bgColor,
                              shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                      cornerRadius: 20, cornerSmoothing: 1))),
                          child: Column(children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                chatCtrl.isTextBox
                                    ? Expanded(
                                        child: CommonTextBox(
                                        labelText: fonts.enterGroupName.tr,
                                        controller: chatCtrl.textNameController,
                                        maxLength: 30,
                                        counterText: chatCtrl
                                            .textNameController.text.length
                                            .toString(),
                                      ))
                                    : Text(chatCtrl.pName!,
                                        style: AppCss.poppinsSemiBold18
                                            .textColor(
                                                appCtrl.appTheme.blackColor)),
                                HSpace(
                                    chatCtrl.isTextBox ? Sizes.s8 : Sizes.s5),
                                SvgPicture.asset(
                                  chatCtrl.isTextBox
                                      ? svgAssets.send
                                      : svgAssets.edit2,
                                  color: appCtrl.appTheme.txtColor,
                                ).paddingOnly(bottom: Insets.i2).inkWell(
                                    onTap: () async {
                                  chatCtrl.isTextBox = !chatCtrl.isTextBox;
                                  chatCtrl.textNameController.text =
                                      chatCtrl.pName!;
                                  chatCtrl.update();
                                  if (chatCtrl.textNameController.text !=
                                      chatCtrl.pName) {
                                    await FirebaseFirestore.instance
                                        .collection(collectionName.groups)
                                        .doc(chatCtrl.pId)
                                        .update({
                                      "name": chatCtrl.textNameController.text
                                    }).then((value) {
                                      chatCtrl.pName =
                                          chatCtrl.textNameController.text;
                                      chatCtrl.update();
                                    });
                                  }
                                })
                              ],
                            ).marginSymmetric(horizontal: Insets.i20),
                            const VSpace(Sizes.s10),
                            Text(
                                "${chatCtrl.userList.length.toString()} ${fonts.participants.tr}",
                                style: AppCss.poppinsSemiBold14
                                    .textColor(appCtrl.appTheme.txtColor)),
                            const VSpace(Sizes.s10),
                            AudioVideoButtonLayout(
                              isGroup: true,
                              callTap: () async {
                                await chatCtrl.permissionHandelCtrl
                                    .getCameraMicrophonePermissions()
                                    .then((value) {
                                  if (value == true) {
                                    // chatCtrl.audioVideoCallTap(false);
                                  }
                                });
                              },
                              videoTap: () async {
                                await chatCtrl.permissionHandelCtrl
                                    .getCameraMicrophonePermissions()
                                    .then((value) {
                                  if (value == true) {
                                    //chatCtrl.audioVideoCallTap(true);
                                  }
                                });
                              },
                              addTap: () async {
                                log("ADD PARTICIPATE : ${appCtrl.contactList.length}");
                                if (appCtrl.contactList.isEmpty) {
                                  final groupChatCtrl = Get.isRegistered<
                                          AddParticipantsController>()
                                      ? Get.find<AddParticipantsController>()
                                      : Get.put(AddParticipantsController());

                                  groupChatCtrl.refreshContacts();
                                  var data = {
                                    "exitsUser": chatCtrl.userList,
                                    "groupId": chatCtrl.pId
                                  };
                                  log("arg : $data");
                                  Get.toNamed(routeName.addParticipants,
                                      arguments: data);
                                } else {
                                  final groupChatCtrl = Get.isRegistered<
                                          AddParticipantsController>()
                                      ? Get.find<AddParticipantsController>()
                                      : Get.put(AddParticipantsController());
                                  if (groupChatCtrl.contactList.isEmpty) {
                                    groupChatCtrl.getFirebaseContact();
                                  }
                                  var data = {
                                    "exitsUser": chatCtrl.userList,
                                    "groupId": chatCtrl.pId
                                  };
                                  log("arg : $data");
                                  Get.toNamed(routeName.addParticipants,
                                      arguments: data);
                                }
                              },
                            ),
                            const VSpace(Sizes.s20)
                          ])),
                      Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            !chatCtrl.isDescTextBox
                                ? Text(
                                        chatCtrl.allData != null
                                            ? chatCtrl.allData["desc"] ??
                                                fonts.addGroupDescription.tr
                                            : fonts.addGroupDescription.tr,
                                        textAlign: TextAlign.center,
                                        style: AppCss.poppinsMedium14.textColor(
                                            appCtrl.appTheme.primary))
                                    .inkWell(onTap: () {
                                    chatCtrl.isDescTextBox =
                                        !chatCtrl.isDescTextBox;
                                    chatCtrl.update();
                                  })
                                : Row(
                                    children: [
                                      Expanded(
                                          child: CommonTextBox(
                                        labelText:
                                            fonts.enterGroupDescription.tr,
                                        controller: chatCtrl.textDescController,
                                        maxLength: 30,
                                        counterText: chatCtrl
                                            .textDescController.text.length
                                            .toString(),
                                      )),
                                      SvgPicture.asset(
                                        svgAssets.send,
                                        color: appCtrl.appTheme.txtColor,
                                      ).paddingOnly(bottom: Insets.i2).inkWell(
                                          onTap: () async {
                                        chatCtrl.isDescTextBox =
                                            !chatCtrl.isDescTextBox;

                                        chatCtrl.update();
                                        log("chatCtrl.textDescController.text : ${chatCtrl.textDescController.text}");
                                        if (chatCtrl.textDescController.text !=
                                            chatCtrl.allData["desc"]) {
                                          await FirebaseFirestore.instance
                                              .collection(collectionName.groups)
                                              .doc(chatCtrl.pId)
                                              .update({
                                            "desc":
                                                chatCtrl.textDescController.text
                                          }).then((value) {
                                            chatCtrl.allData["desc"] = chatCtrl
                                                .textDescController.text;
                                            chatCtrl.update();
                                          });
                                        }
                                      })
                                    ],
                                  ),
                            const VSpace(Sizes.s7),
                            Text(
                                "${fonts.createdBy.tr} ${chatCtrl.allData["createdBy"]["name"]}, ${DateFormat("dd/MM/yyy").format(DateTime.fromMillisecondsSinceEpoch(int.parse(chatCtrl.allData['timestamp'])))}",
                                textAlign: TextAlign.center,
                                style: AppCss.poppinsMedium12
                                    .textColor(appCtrl.appTheme.txtColor)),
                          ])
                          .width(MediaQuery.of(context).size.width)
                          .paddingAll(Insets.i20)
                          .decorated(
                              color: appCtrl.appTheme.chatSecondaryColor,
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(AppRadius.r20),
                                  bottomRight: Radius.circular(AppRadius.r20))),
                      const VSpace(Sizes.s5),
                      GroupImagesVideos(chatId: chatCtrl.pId),
                      const VSpace(Sizes.s5),
                      Container(
                          margin: const EdgeInsets.all(Insets.i20),
                          padding: const EdgeInsets.all(Insets.i15),
                          decoration: ShapeDecoration(
                              color: appCtrl.appTheme.whiteColor,
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 20, cornerSmoothing: 1),
                              ),
                              shadows: const [
                                BoxShadow(
                                    color: Color.fromRGBO(49, 100, 189, 0.08),
                                    spreadRadius: 2,
                                    blurRadius: 12)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "${chatCtrl.userList.length.toString()} ${fonts.participants.tr}",
                                        style: AppCss.poppinsSemiBold14
                                            .textColor(
                                                appCtrl.appTheme.blackColor)),
                                    SvgPicture.asset(svgAssets.search).inkWell(
                                        onTap: () => Get.toNamed(
                                            routeName.searchUser,
                                            arguments: chatCtrl.userList))
                                  ],
                                ),
                                const VSpace(Sizes.s22),
                                ...chatCtrl.userList.asMap().entries.map((e) {
                                  return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection(collectionName.users)
                                          .doc(e.value["id"])
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return snapshot.data!.data() != null
                                              ? GestureDetector(
                                                  onTapDown: (pos) {
                                                    if (e.value["id"] !=
                                                        chatCtrl.user["id"]) {
                                                      chatCtrl
                                                          .getTapPosition(pos);
                                                    }
                                                  },
                                                  onLongPress: () {
                                                    if (e.value["id"] !=
                                                        chatCtrl.user["id"]) {
                                                      chatCtrl.showContextMenu(
                                                          context,
                                                          e.value,
                                                          snapshot);
                                                    } else {
                                                      Get.toNamed(
                                                          routeName.editProfile,
                                                          arguments: {
                                                            "resultData":
                                                                chatCtrl.user,
                                                            "isPhoneLogin":
                                                                false
                                                          });
                                                    }
                                                  },
                                                  child: Row(children: [
                                                    CommonImage(
                                                        image: snapshot.data!
                                                                    .data()![
                                                                "image"] ??
                                                            "",
                                                        name: snapshot.data!
                                                                        .data()![
                                                                    "id"] ==
                                                                chatCtrl
                                                                    .user["id"]
                                                            ? "Me"
                                                            : snapshot.data!
                                                                    .data()![
                                                                "name"],
                                                        height: Sizes.s40,
                                                        width: Sizes.s40),
                                                    const HSpace(Sizes.s10),
                                                    Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              snapshot.data!.data()![
                                                                          "id"] ==
                                                                      (FirebaseAuth.instance.currentUser !=
                                                                              null
                                                                          ? FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid
                                                                          : chatCtrl.user[
                                                                              "id"])
                                                                  ? "Me"
                                                                  : snapshot
                                                                          .data!
                                                                          .data()![
                                                                      "name"],
                                                              style: AppCss
                                                                  .poppinsSemiBold14
                                                                  .textColor(appCtrl
                                                                      .appTheme
                                                                      .blackColor)),
                                                          const VSpace(
                                                              Sizes.s5),
                                                          Text(
                                                              snapshot.data!
                                                                      .data()![
                                                                  "statusDesc"],
                                                              style: AppCss
                                                                  .poppinsMedium12
                                                                  .textColor(appCtrl
                                                                      .appTheme
                                                                      .txtColor))
                                                        ])
                                                  ]).marginOnly(
                                                      bottom: Insets.i15))
                                              : Container();
                                        } else {
                                          return Container();
                                        }
                                      });
                                }).toList(),
                                if (chatCtrl.userList.length > 5)
                                  Divider(
                                      color: appCtrl.appTheme.primary
                                          .withOpacity(.10),
                                      thickness: 1),
                                if (chatCtrl.userList.length > 5)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(fonts.viewAll.tr,
                                          style: AppCss.poppinsSemiBold14
                                              .textColor(
                                                  appCtrl.appTheme.primary)),
                                      Text(
                                          "${chatCtrl.userList.length - 5} more",
                                          style: AppCss.poppinsMedium12
                                              .textColor(
                                                  appCtrl.appTheme.txtColor)),
                                    ],
                                  ).marginSymmetric(vertical: Insets.i15)
                              ])),
                      BlockReportLayout(
                          icon: svgAssets.exit,
                          name: chatCtrl.isThere
                              ? fonts.exitGroup.tr
                              : fonts.deleteGroup.tr,
                          onTap: () => chatCtrl.isThere
                              ? chatCtrl.exitGroupDialog()
                              : chatCtrl.deleteGroup()),
                      BlockReportLayout(
                          icon: svgAssets.dislike,
                          name: fonts.reportGroup.tr,
                          onTap: () async {
                            accessDenied(
                                "Are you sure you want to report ${chatCtrl.pName} group?. Once you report this group you will be remove from this group without notify anyone",
                                onTap: () async {
                              await FirebaseFirestore.instance
                                  .collection(collectionName.groups)
                                  .doc(chatCtrl.pId)
                                  .get()
                                  .then((value) {
                                if (value.exists) {
                                  List users = value.data()!["users"];
                                  users.removeWhere((element) =>
                                      element["id"] == chatCtrl.user["id"]);
                                  FirebaseFirestore.instance
                                      .collection(collectionName.groups)
                                      .doc(chatCtrl.pId)
                                      .update({"users": users}).then(
                                          (value) async {
                                    await FirebaseFirestore.instance
                                        .collection(collectionName.users)
                                        .doc(chatCtrl.user["id"])
                                        .collection(collectionName.chats)
                                        .where("groupId",
                                            isEqualTo: chatCtrl.pId)
                                        .limit(1)
                                        .get()
                                        .then((userChat) {
                                      if (userChat.docs.isNotEmpty) {
                                        FirebaseFirestore.instance
                                            .collection(collectionName.users)
                                            .doc(chatCtrl.user["id"])
                                            .collection(collectionName.chats)
                                            .doc(userChat.docs[0].id)
                                            .delete();
                                      }
                                    });
                                  });
                                }
                              });
                              await FirebaseFirestore.instance
                                  .collection(collectionName.report)
                                  .add({
                                "reportFrom": chatCtrl.user["id"],
                                "reportTo": chatCtrl.pId,
                                "isSingleChat": false,
                                "timestamp":
                                    DateTime.now().millisecondsSinceEpoch
                              }).then((value) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(fonts.reportSend.tr),
                                  backgroundColor: appCtrl.appTheme.greenColor,
                                ));
                              });
                            });
                          }),
                      const VSpace(Sizes.s35)
                    ]));
          });
    });
  }
}
