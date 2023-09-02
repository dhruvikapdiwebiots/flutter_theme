
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_profile/group_images_video.dart';
import 'package:intl/intl.dart';
import '../../../../../config.dart';

class BroadcastProfileBody extends StatelessWidget {
  const BroadcastProfileBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BroadcastChatController>(builder: (chatCtrl) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(collectionName.broadcast)
              .doc(chatCtrl.pId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.exists) {
                chatCtrl.broadData = snapshot.data!.data();
                chatCtrl.userList = chatCtrl.pData.isNotEmpty
                    ? chatCtrl.pData.length < 5
                        ? chatCtrl.pData
                        : chatCtrl.pData.getRange(0, 5).toList()
                    : [];
                chatCtrl.isThere = chatCtrl.userList.any((element) =>
                    element["id"].contains(chatCtrl.userData["id"]));
              }
            }
            return Container(
                decoration: ShapeDecoration(
                    color: appCtrl.appTheme.bgColor,
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 20, cornerSmoothing: 1))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height / 12),
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
                                        labelText: fonts.enterBroadcastName.tr,
                                        controller: chatCtrl.textNameController,
                                        maxLength: 30,
                                        counterText: chatCtrl
                                            .textNameController.text.length
                                            .toString(),
                                      ))
                                    : Text(
                                    chatCtrl.pName ??
                                            fonts.broadCast.tr,
                                        style: AppCss.poppinsSemiBold18
                                            .textColor(
                                                appCtrl.appTheme.blackColor)),
                                HSpace(
                                    chatCtrl.isTextBox ? Sizes.s8 : Sizes.s5),
                                SvgPicture.asset(
                                  chatCtrl.isTextBox
                                      ? svgAssets.send
                                      : svgAssets.edit2,
                                  colorFilter:ColorFilter.mode(appCtrl.appTheme.txtColor, BlendMode.srcIn) ,
                                ).paddingOnly(bottom: Insets.i2).inkWell(
                                    onTap: () async {
                                  chatCtrl.isTextBox = !chatCtrl.isTextBox;

                                  chatCtrl.update();
                                  if (chatCtrl.textNameController.text !=
                                      chatCtrl.pName) {
                                    await FirebaseFirestore.instance
                                        .collection(collectionName.broadcast)
                                        .doc(chatCtrl.pId)
                                        .update({
                                      "name": chatCtrl.textNameController.text
                                    }).then((value) async{

                                      chatCtrl.pName =
                                          chatCtrl.textNameController.text;
                                      chatCtrl.update();
                                      await FirebaseFirestore.instance.collection(collectionName.users).doc(appCtrl.user["id"])
                                          .collection(collectionName.chats)
                                          .where("broadcastId",isEqualTo: chatCtrl.pId).limit(1).get().then((chatBroadcast)async{
                                            if(chatBroadcast.docs.isNotEmpty){
                                              await FirebaseFirestore.instance.collection(collectionName.users).doc(appCtrl.user["id"])
                                                  .collection(collectionName.chats).doc(chatBroadcast.docs[0].id).update(
                                                  {"name":chatCtrl.pName});
                                            }
                                      });


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
                            const VSpace(Sizes.s20)
                          ])),
                      Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            Text(
                                "${fonts.createdBy.tr} ${chatCtrl.broadData["createdBy"]["name"]}, ${DateFormat("dd/MM/yyy").format(DateTime.fromMillisecondsSinceEpoch(int.parse(chatCtrl.broadData['timestamp'])))}",
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
                                  children: [
                                    SvgPicture.asset(svgAssets.add, colorFilter:ColorFilter.mode(appCtrl.appTheme.blackColor, BlendMode.srcIn) ,height: Sizes.s20,).inkWell(onTap: ()=>Get.toNamed(routeName.broadcastSearchUser,arguments: chatCtrl.userList)),
                                    const HSpace(Sizes.s8),
                                    Text(
                                        fonts.addContact.tr,
                                        style: AppCss.poppinsSemiBold16
                                            .textColor(
                                            appCtrl.appTheme.blackColor)),

                                  ],
                                ).inkWell(onTap: ()async{
                                  final groupChatCtrl = Get.isRegistered<AddParticipantsController>()
                                      ? Get.find<AddParticipantsController>()
                                      : Get.put(AddParticipantsController());


                                  groupChatCtrl.refreshContacts();
                                  var data ={
                                    "exitsUser":chatCtrl.userList,
                                    "groupId":chatCtrl.pId,
                                    "isGroup": false
                                  };

                                  Get.toNamed(routeName.addParticipants,arguments: data);
                                }),
                                const VSpace(Sizes.s20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "${chatCtrl.userList.length.toString()} ${fonts.participants.tr}",
                                        style: AppCss.poppinsSemiBold14
                                            .textColor(
                                                appCtrl.appTheme.blackColor)),
                                    SvgPicture.asset(svgAssets.search).inkWell(onTap: ()=>Get.toNamed(routeName.broadcastSearchUser,arguments: chatCtrl.userList))
                                  ],
                                ),
                                const VSpace(Sizes.s22),
                                ...chatCtrl.pData.asMap().entries.map((e) {
                                  return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection(collectionName.users)
                                          .doc(e.value["id"])
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return GestureDetector(
                                            onTapDown: (pos) {
                                              if (e.value["id"] !=
                                                  chatCtrl.userData["id"]) {
                                                chatCtrl.getTapPosition(pos);
                                              }
                                            },
                                            onLongPress: () {
                                              if (e.value["id"] !=
                                                  chatCtrl.userData["id"]) {
                                                chatCtrl.showContextMenu(
                                                    context, e.value,
                                                    snapshot);
                                              } else {

                                                Get.toNamed(routeName.editProfile,
                                                    arguments: {"resultData": chatCtrl.userData, "isPhoneLogin": false});
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                CommonImage(
                                                    image: snapshot.data!
                                                        .data()!["image"],
                                                    name: snapshot.data!
                                                                .data()!["id"] ==
                                                        (FirebaseAuth.instance
                                                            .currentUser != null ?        FirebaseAuth.instance
                                                                .currentUser!.uid : chatCtrl.userData["id"])
                                                        ? "Me"
                                                        : snapshot.data!
                                                            .data()!["name"],
                                                    height: Sizes.s40,
                                                    width: Sizes.s40),
                                                const HSpace(Sizes.s10),
                                                Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          snapshot.data!.data()![
                                                                      "id"] ==
                                                              (FirebaseAuth.instance
                                                                  .currentUser != null ?        FirebaseAuth.instance
                                                                  .currentUser!.uid : chatCtrl.userData["id"])
                                                              ? "Me"
                                                              : snapshot.data!
                                                                      .data()![
                                                                  "name"],
                                                          style: AppCss
                                                              .poppinsSemiBold14
                                                              .textColor(appCtrl
                                                                  .appTheme
                                                                  .blackColor)),
                                                      const VSpace(Sizes.s5),
                                                      Text(
                                                          snapshot.data!.data()![
                                                              "statusDesc"],
                                                          style: AppCss
                                                              .poppinsMedium12
                                                              .textColor(appCtrl
                                                                  .appTheme
                                                                  .txtColor)),
                                                    ])
                                              ],
                                            ).marginOnly(bottom: Insets.i15),
                                          );
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
                                          "${chatCtrl.userList.length - 5} ${fonts.more.tr}",
                                          style: AppCss.poppinsMedium12
                                              .textColor(
                                                  appCtrl.appTheme.txtColor)),
                                    ],
                                  ).marginSymmetric(vertical: Insets.i15)
                              ])),
                      BlockReportLayout(
                          icon: svgAssets.trash,
                          name: fonts.deleteBroadcast.tr,
                          onTap: () => chatCtrl.deleteBroadCast()),
                      const VSpace(Sizes.s15)
                    ]));
          });
    });
  }
}
