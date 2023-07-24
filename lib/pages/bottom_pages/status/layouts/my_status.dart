import 'dart:developer';

import 'package:flutter_theme/pages/bottom_pages/status/layouts/my_status_video.dart';
import 'package:flutter_theme/widgets/common_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config.dart';

class MyStatus extends StatelessWidget {
  const MyStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return Scaffold(
        backgroundColor: appCtrl.appTheme.bgColor,
        appBar: CommonAppBar(text: "My Status"),
        floatingActionButton: const StatusFloatingButton(),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(appCtrl.storage.read(session.user)["id"])
                .collection(collectionName.status)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container();
              } else if (!snapshot.hasData) {
                return Container();
              } else {
                Status? status;
                List<PhotoUrl> photoUrlList = [];
                log("LENGTH : ${snapshot.data!.docs.length}");
                if (snapshot.data!.docs.isNotEmpty) {
                  status = Status.fromJson(snapshot.data!.docs[0].data());

                  photoUrlList = status.photoUrl!;
                  log("photoUrlList : ${photoUrlList.length}");
                  return SingleChildScrollView(
                    child: SizedBox(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          InkWell(
                              onTap: () {
                                Get.toNamed(routeName.statusView,
                                    arguments: status);
                              },
                              child: Column(
                                children: [
                                  ...photoUrlList.asMap().entries.map((e) {
                                    log("photoUrlList : ${photoUrlList.length}");
                                    return ListTile(
                                        horizontalTitleGap: 10,
                                        trailing: PopupMenuButton(
                                          color: appCtrl.appTheme.whiteColor,
                                          padding: EdgeInsets.zero,
                                          iconSize: Sizes.s20,
                                          onSelected: (result) async {
                                            log("RESULT : R${photoUrlList.length}");
                                            if (result == 0) {
                                              List<PhotoUrl> photoUrl =
                                                  photoUrlList;
                                              photoUrl.removeAt(e.key);
                                              log("PHOTOURL : ${photoUrl.length}");
                                              if(photoUrl.isEmpty){
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                    collectionName.users)
                                                    .doc(appCtrl.user["id"])
                                                    .collection(
                                                    collectionName.status)
                                                    .doc(
                                                    snapshot.data!.docs[0].id).delete();
                                                Get.back();
                                              }else {
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                    collectionName.users)
                                                    .doc(appCtrl.user["id"])
                                                    .collection(
                                                    collectionName.status)
                                                    .doc(
                                                    snapshot.data!.docs[0].id)
                                                    .update({
                                                  'photoUrl': photoUrl
                                                      .map((e) => e.toJson())
                                                      .toList(),
                                                });
                                              }
                                            } else if (result == 1) {
                                              Share.share(e.value.image!,
                                                  subject: 'Look what I made!');
                                            } else {
                                              Get.to(() => ContactList(message: e.value,));
                                            }
                                          },
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.r8)),
                                          itemBuilder: (ctx) => [
                                            _buildPopupMenuItem(
                                                fonts.delete.tr, 0),
                                            _buildPopupMenuItem(
                                                fonts.share.tr, 1),
                                            _buildPopupMenuItem(
                                                fonts.forward.tr, 2),
                                          ],
                                          child: Icon(Icons.more_vert)
                                              .paddingAll(Insets.i10),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: Insets.i15),
                                        subtitle: Row(children: [
                                          Text(
                                              DateFormat("dd/MM/yyyy").format(
                                                          statusCtrl.date) ==
                                                      DateFormat('dd/MM/yyyy')
                                                          .format(DateTime
                                                              .fromMillisecondsSinceEpoch(
                                                                  int.parse(e
                                                                      .value
                                                                      .timestamp!)))
                                                  ? fonts.today.tr
                                                  : fonts.yesterday.tr,
                                              style: AppCss.poppinsMedium12
                                                  .textColor(appCtrl
                                                      .appTheme.txtColor)),
                                          Text(
                                              DateFormat('HH:mm a').format(
                                                  DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          int.parse(e.value
                                                              .timestamp!))),
                                              style: AppCss.poppinsMedium12
                                                  .textColor(appCtrl
                                                      .appTheme.txtColor)),
                                        ]),
                                        title: Text(e.value.seenBy!.length.toString(),
                                            style: AppCss.poppinsblack14
                                                .textColor(
                                                    appCtrl.appTheme.txt)),
                                        leading: Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              e.value.statusType ==
                                                      StatusType.text.name
                                                  ? Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal:
                                                              Insets.i4),
                                                      height: Sizes.s50,
                                                      width: Sizes.s50,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration:
                                                          ShapeDecoration(
                                                              color: Color(
                                                                  int.parse(
                                                                      e.value
                                                                          .statusBgColor!,
                                                                      radix:
                                                                          16)),
                                                              shape:
                                                                  SmoothRectangleBorder(
                                                                borderRadius:
                                                                    SmoothBorderRadius(
                                                                        cornerRadius:
                                                                            12,
                                                                        cornerSmoothing:
                                                                            1),
                                                              )),
                                                      child: Text(
                                                        e.value.statusText!,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: AppCss
                                                            .poppinsMedium10
                                                            .textColor(appCtrl
                                                                .appTheme
                                                                .whiteColor),
                                                      ),
                                                    )
                                                  : e.value.statusType ==
                                                          StatusType.image.name
                                                      ? CommonImage(
                                                          height: Sizes.s50,
                                                          width: Sizes.s50,
                                                          image: e.value.image
                                                              .toString(),
                                                          name: "C",
                                                        )
                                                      : MyStatusVideo(
                                                          snapshot: e.value),
                                            ]));
                                  }).toList()
                                ],
                              ))
                        ])),
                  );
                } else {
                  return Container();
                }
              }
            }),
      );
    });
  }

  PopupMenuItem _buildPopupMenuItem(String title, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(
        children: [
          Text(
            title,
            style:
                AppCss.poppinsMedium14.textColor(appCtrl.appTheme.blackColor),
          )
        ],
      ),
    );
  }
}
