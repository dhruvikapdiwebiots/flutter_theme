import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:story_view/story_view.dart';

import '../../../../config.dart';

bool isSwipeUp = false;

class StatusScreenView extends StatefulWidget {
  const StatusScreenView({
    Key? key,
  }) : super(key: key);

  @override
  State<StatusScreenView> createState() => _StatusScreenViewState();
}

class _StatusScreenViewState extends State<StatusScreenView> {
  StoryController controller = StoryController();
  List<StoryItem> storyItems = [];
  bool visibility = true;
  int position = 0, selectedIndex = 0, lastPosition = 0;
  Status? status;
  List seenBy = [];

  @override
  void initState() {
    super.initState();
    status = Get.arguments;
    setState(() {});
    log("status : ${status!.photoUrl!.length}");
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < status!.photoUrl!.length; i++) {
      log("STTTT :${status!.photoUrl![i].statusType}");
      if (status!.photoUrl![i].statusType == StatusType.text.name) {
        int value = int.parse(status!.photoUrl![i].statusBgColor!, radix: 16);
        Color finalColor = Color(value);
        storyItems.add(StoryItem.text(
            title: status!.photoUrl![i].statusText!,
            textStyle: TextStyle(
                color: appCtrl.appTheme.whiteColor,
                fontSize: 23,
                height: 1.6,
                fontWeight: FontWeight.w700),
            backgroundColor: finalColor));
      } else if (status!.photoUrl![i].statusType == StatusType.video.name) {
        storyItems.add(
          StoryItem.pageVideo(status!.photoUrl![i].image!,
              controller: controller, imageFit: BoxFit.fill),
        );
      } else {
        storyItems.add(
          StoryItem.pageImage(
              url: status!.photoUrl![i].image!,
              controller: controller,
              imageFit: BoxFit.cover),
        );
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onPanEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy > -100) {
          setState(() {
            isSwipeUp = true;
          });
        } else {
          setState(() {
            isSwipeUp = false;
          });
        }
        if (isSwipeUp = true) {
          controller.pause();
        } else {
          controller.play();
        }
        log("isSwipeUp : $isSwipeUp");
        setState(() {});
      },
      child: Scaffold(
        body: storyItems.isEmpty
            ? const CircularProgressIndicator()
            : Stack(
                alignment: Alignment.topLeft,
                children: [
                  GestureDetector(
                    onTap: () {
                      log("ONTAP");
                    },
                    behavior: HitTestBehavior.deferToChild,
                    child: StoryView(
                      indicatorColor: const Color.fromRGBO(255, 255, 255, 0.50),
                      onStoryShow: (s) async {
                        log("STATUS : ${s.reactive}");

                        selectedIndex = selectedIndex + 1;
                        position = position + 1;

                        log("CHECK L: ${(position - 1) < status!.photoUrl!.length}");
                        if ((position - 1) < status!.photoUrl!.length) {
                          FirebaseFirestore.instance
                              .collection(collectionName.users)
                              .doc(status!.uid)
                              .collection(collectionName.status)
                              .limit(1)
                              .get()
                              .then((doc) {
                            if (doc.docs.isNotEmpty) {
                              Status getStatus =
                                  Status.fromJson(doc.docs[0].data());
                              log("getStatus : ${doc.docs[0].id}");
                              List<PhotoUrl> photoUrl = getStatus.photoUrl!;
                              bool isSeen = photoUrl[lastPosition]
                                  .seenBy!
                                  .where((element) =>
                                      element["uid"] == appCtrl.user["id"])
                                  .isNotEmpty;
                              if (!isSeen) {
                                photoUrl[lastPosition].seenBy!.add({
                                  "uid": appCtrl.user["id"],
                                  "seenTime":
                                      DateTime.now().millisecondsSinceEpoch
                                });
                                log("SEEN L %${photoUrl[lastPosition].seenBy}");
                                FirebaseFirestore.instance
                                    .collection(collectionName.users)
                                    .doc(status!.uid)
                                    .collection(collectionName.status)
                                    .doc(doc.docs[0].id)
                                    .update({
                                  "photoUrl":
                                      photoUrl.map((e) => e.toJson()).toList()
                                });
                              }

                              if (position == status!.photoUrl!.length) {
                                List seenAll = status!.seenAllStatus ?? [];
                                if (!seenAll.contains(appCtrl.user["id"])) {
                                  seenAll.add(appCtrl.user["id"]);
                                }
                                FirebaseFirestore.instance
                                    .collection(collectionName.users)
                                    .doc(status!.uid)
                                    .collection(collectionName.status)
                                    .doc(doc.docs[0].id)
                                    .update({"seenAllStatus": seenAll}).then(
                                        (value) {
                                  final statusCtrl =
                                      Get.isRegistered<StatusController>()
                                          ? Get.find<StatusController>()
                                          : Get.put(StatusController());
                                  statusCtrl.getAllStatus();
                                });
                              }
                            }
                          });
                        }
                      },
                      storyItems: storyItems,
                      controller: controller,
                      onComplete: () {
                        Navigator.maybePop(context);
                      },
                      repeat: false,
                      onVerticalSwipeComplete: (direction) {
                        log("direction : $direction");
                        if (direction == Direction.down) {
                          Navigator.pop(context);
                        } else if (direction == Direction.up) {
                          dynamic user = appCtrl.storage.read(session.user);
                          if (status!.uid ==
                              (FirebaseAuth.instance.currentUser != null
                                  ? FirebaseAuth.instance.currentUser!.uid
                                  : user["id"])) {
                            controller.pause();

                            setState(() {});
                            int lastPosition = position - 1;
                            FirebaseFirestore.instance
                                .collection(collectionName.users)
                                .doc(FirebaseAuth.instance.currentUser != null
                                    ? FirebaseAuth.instance.currentUser!.uid
                                    : user["id"])
                                .collection(collectionName.status)
                                .limit(1)
                                .get()
                                .then((doc) {
                              if (doc.docs.isNotEmpty) {
                                Status getStatus =
                                    Status.fromJson(doc.docs[0].data());

                                List<PhotoUrl> photoUrl = getStatus.photoUrl!;
                                log("photoUrl : $photoUrl");
                                seenBy = photoUrl[lastPosition].seenBy!;
                                setState(() {});
                                log("seenBy : $seenBy");
                              }
                            });
                            showModalBottomSheet(
                              context: context,
                              backgroundColor:
                                  appCtrl.appTheme.transparentColor,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(AppRadius.r20))),
                              builder: (context) => buildSheet(),
                            );
                          } else if (direction == Direction.down) {
                            controller.play();
                            setState(() {});
                          }
                        }
                      },
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(svgAssets.arrowLeft)
                          .marginOnly(top: Insets.i12),
                      const HSpace(Sizes.s10),
                      CommonImage(
                        width: Sizes.s48,
                        height: Sizes.s48,
                        image: status!.profilePic ?? "",
                        name: status!.username!,
                      ),
                      const HSpace(Sizes.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status!.username!,
                              style: AppCss.poppinsMedium16
                                  .textColor(appCtrl.appTheme.white)),
                          const VSpace(Sizes.s5),
                          DateFormat("dd/MM/yy").format(DateTime.now()) ==
                                  DateFormat('dd/MM/yy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(status!
                                              .photoUrl![lastPosition].timestamp
                                              .toString())))
                              ? Text("${fonts.today.tr}, ${DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(status!.photoUrl![lastPosition].timestamp.toString())))}",
                                  style: AppCss.poppinsMedium12.textColor(
                                      const Color.fromRGBO(255, 255, 255, 0.65)))
                              : Text("${fonts.tomorrow.tr} ${DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(status!.photoUrl![lastPosition].timestamp.toString())))}",
                                  style: AppCss.poppinsMedium12
                                      .textColor(const Color.fromRGBO(255, 255, 255, 0.65))),
                        ],
                      ).marginOnly(top: Insets.i10)
                    ],
                  ).marginSymmetric(
                      horizontal: Insets.i20, vertical: Insets.i75),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: Sizes.s80,
                      ).inkWell(onTap: () {
                        log("lastPosition : ${status!.photoUrl!.length}");
                        log("lastPosition : $lastPosition");

                        lastPosition = lastPosition - 1;
                        if (lastPosition == -1) {
                          Get.back();
                        } else {
                          controller.previous();
                          setState(() {});
                        }
                        log("lastPositionTap : $lastPosition");
                      })),
                  Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: Sizes.s80,
                      ).inkWell(onTap: () {
                        lastPosition = lastPosition + 1;

                        if (lastPosition < status!.photoUrl!.length) {
                          controller.next();
                          setState(() {});
                        } else {
                          Get.back();
                        }
                      })),
                ],
              ),
      ),
    );
  }

  Widget buildSheet() {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        log("notification: $notification");
        if (visibility && notification.extent >= 0.2) {
          setState(() {
            visibility = false;
          });
        } else if (!visibility && notification.extent < 0.2) {
          setState(() {
            visibility = true;
          });
        }
        return visibility;
        // here determine if scroll is over and func.call()
      },
      child: GestureDetector(
        onVerticalDragDown: (panel) {
          visibility = false;
          controller.play();
          Get.back();
          setState(() {});
        },
        child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            snap: true,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                      color: appCtrl.appTheme.whiteColor,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.r20))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(Insets.i20),
                        decoration: BoxDecoration(
                            color: appCtrl.appTheme.primary,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppRadius.r20))),
                        child: Text(
                          "${seenBy.length} ${fonts.views.tr}",
                          style: AppCss.poppinsMedium14
                              .textColor(appCtrl.appTheme.whiteColor),
                        ),
                      ),
                      ...seenBy.asMap().entries.map((e) {
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection(collectionName.users)
                                .doc(e.value["uid"])
                                .snapshots(),
                            builder: (context, snapshot) {
                              String image = "", name = "";
                              if (snapshot.hasData) {
                                image = snapshot.data!.data()!["image"] ?? "";
                                name = snapshot.data!.data()!["name"] ?? "";
                              }
                              return ListTile(
                                  leading: CommonImage(
                                      image: image,
                                      height: Sizes.s48,
                                      width: Sizes.s48,
                                      name: name),
                                  title: Text(name),
                                  subtitle: Text(DateFormat('HH:mm a').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          int.parse(e.value["seenTime"]
                                              .toString())))));
                            });
                      }).toList()
                    ],
                  ),
                );
              });
            }),
      ),
    );
  }
}
