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
  bool FAB_visibility = true;
  int position = 0;
  Status? status;
  List seenBy = [];

  @override
  void initState() {
    super.initState();
    status = Get.arguments;
    setState(() {});
    initStoryPageItems();
  }

  void initStoryPageItems() {
    for (int i = 0; i < status!.photoUrl!.length; i++) {
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
              controller: controller),
        );
      } else {
        storyItems.add(StoryItem.pageImage(
          url: status!.photoUrl![i].image!,
          controller: controller,
        ));
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanEnd: (details) {
        print(details.velocity.pixelsPerSecond.dy.toString());
        print(details.velocity.pixelsPerSecond.dx.toString());
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
        setState(() {});
      },
      child: Scaffold(
        body: storyItems.isEmpty
            ? const CircularProgressIndicator()
            : Stack(
          alignment: Alignment.topLeft,
          children: [
            StoryView(
                onStoryShow: (s) async {
                  log("s : $s");
                  dynamic user = appCtrl.storage.read(session.user);

                  position = position + 1;
                  int lastPosition = position - 1;

                  if (status!.uid !=
                      appCtrl.user["id"]) {
                    log("CHECK L: ${(position - 1) <
                        status!.photoUrl!.length}");
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
                          element["uid"] ==
                              appCtrl.user["id"])
                              .isNotEmpty;
                          if (!isSeen) {
                            photoUrl[lastPosition].seenBy!.add({
                              "uid":
                              appCtrl.user["id"],
                              "seenTime":
                              DateTime
                                  .now()
                                  .millisecondsSinceEpoch
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
                            if (!seenAll.contains(status!.uid)) {
                              seenAll.add(appCtrl.user["id"]);
                            }
                            FirebaseFirestore.instance
                                .collection(collectionName.users)
                                .doc(status!.uid)
                                .collection(collectionName.status)
                                .doc(doc.docs[0].id)
                                .update({"seenAllStatus": seenAll});
                          }
                        }
                      });
                    }
                  } else {
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
                        log("getStatus : ${doc.docs[0].id}");
                        List<PhotoUrl> photoUrl = getStatus.photoUrl!;
                        seenBy = photoUrl[lastPosition].seenBy!;
                        setState(() {});
                        log("seenBy : $seenBy");
                      }
                    });
                  }
                },
                storyItems: storyItems,
                controller: controller,
                onComplete: () {
                  Navigator.maybePop(context);
                },
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
                }),

            Row(
              children: [
                CommonImage(
                  width: Sizes.s50,
                  height: Sizes.s50,
                  image: status!.profilePic!,
                  name: status!.username!,
                ), const HSpace(Sizes.s5),
                Text(status!.username!, style: AppCss.poppinsMedium16.textColor(
                    appCtrl.appTheme.white))
              ],
            ).marginSymmetric(horizontal: Insets.i30,vertical: Insets.i70)
          ],
        ),
      ),
    );
  }

  Widget buildSheet() {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        log("notification: $notification");
        if (FAB_visibility && notification.extent >= 0.2) {
          setState(() {
            FAB_visibility = false;
          });
        } else if (!FAB_visibility && notification.extent < 0.2) {
          setState(() {
            FAB_visibility = true;
          });
        }
        return FAB_visibility;
        // here determine if scroll is over and func.call()
      },
      child: GestureDetector(
        onVerticalDragDown: (panel) {
          FAB_visibility = false;
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
                          padding:const EdgeInsets.all(Insets.i20),
                          decoration: BoxDecoration(
                              color: appCtrl.appTheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppRadius.r20))),
                          child: Text("${seenBy.length} ${fonts.views.tr}",style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.whiteColor),),
                        ),
                        ...seenBy.asMap().entries.map((e) {
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection(collectionName.users)
                                  .doc(e.value["uid"])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                String image ="",name="";
                                if (snapshot.hasData) {

                                 image =
                                      snapshot.data!.data()!["image"] ?? "";
                                 name =
                                      snapshot.data!.data()!["name"] ?? "";
                                }
                                return ListTile(
                                    leading: CommonImage(
                                        image: image,
                                        height: Sizes.s50,
                                        width: Sizes.s50,
                                        name: name),
                                    title: Text(name),
                                    subtitle: Text(DateFormat('HH:mm a').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(e.value["seenTime"].toString())))));
                              });
                        }).toList()
                      ],
                    ),
                  );
                }
              );
            }),
      ),
    );
  }
}
