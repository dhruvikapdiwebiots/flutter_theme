import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

import '../../../../config.dart';

class StatusLayout extends StatefulWidget {
  final AsyncSnapshot? snapshot;

  const StatusLayout({Key? key, this.snapshot}) : super(key: key);

  @override
  State<StatusLayout> createState() => _StatusLayoutState();
}

class _StatusLayoutState extends State<StatusLayout> {
  VideoPlayerController? videoController;
  late Future<void> initializeVideoPlayerFuture;
  bool startedPlaying = false;

  @override
  void initState() {
    log("dfdf : ${(widget.snapshot!.data!)
        .docs[0]["photoUrl"][(widget.snapshot!.data!).docs[0]["photoUrl"]
        .length - 1]
    ["statusType"]}");
    // TODO: implement initState
    if ((widget.snapshot!.data!)
        .docs[0]["photoUrl"][(widget.snapshot!.data!).docs[0]["photoUrl"]
        .length - 1]
    ["statusType"] == StatusType.video.name) {
      videoController = VideoPlayerController.network(
        (widget.snapshot!.data!)
            .docs[0]["photoUrl"][(widget.snapshot!.data!).docs[0]["photoUrl"]
            .length - 1]
        ["image"],
      );
      initializeVideoPlayerFuture = videoController!.initialize();
    }
    setState(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () async {
          Status status = Status.fromJson(
              widget.snapshot!.data!.docs[0].data());

          Get.toNamed(routeName.statusView, arguments: status);
          await FirebaseFirestore.instance
              .collection('status')
              .doc((widget.snapshot!.data!).docs[0].id)
              .update({
            'isSeenByOwn': true,
          });
        },
        title: Text((widget.snapshot!.data!).docs[0]["username"]),
        trailing: Icon(
          Icons.more_horiz,
          color: appCtrl.appTheme.primary,
        ),
        leading: Stack(alignment: Alignment.bottomRight, children: [
          (widget.snapshot!.data!).docs[0]["photoUrl"]
          [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
          ["statusType"] ==
              StatusType.text.name
              ? CircleAvatar(
            radius: AppRadius.r25,
            backgroundColor: Color(int.parse(
                (widget.snapshot!.data!).docs[0]["photoUrl"]
                [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
                ['statusBgColor'],
                radix: 16)),
            child: Text(
              (widget.snapshot!.data!).docs[0]["photoUrl"]
              [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
              ["statusText"],
              textAlign: TextAlign.center,
              style: AppCss.poppinsMedium10
                  .textColor(appCtrl.appTheme.whiteColor),
            ),
          ).paddingAll(Insets.i2).decorated(
              color: (widget.snapshot!.data!).docs[0]["isSeenByOwn"] ==
                  true
                  ? appCtrl.appTheme.grey
                  : appCtrl.appTheme.primary,
              shape: BoxShape.circle)
              : (widget.snapshot!.data!).docs[0]["photoUrl"]
          [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
          ["statusType"] ==
              StatusType.image.name ? CachedNetworkImage(
              imageUrl: (widget.snapshot!.data!)
                  .docs[0]["photoUrl"][(widget.snapshot!.data!)
                  .docs[0]["photoUrl"].length - 1]
              ["image"]
                  .toString(),
              imageBuilder: (context, imageProvider) =>
                  CircleAvatar(
                    backgroundColor: const Color(0xffE6E6E6),
                    radius: 32,
                    backgroundImage: NetworkImage((widget.snapshot!.data!)
                        .docs[0]["photoUrl"][
                    (widget.snapshot!.data!).docs[0]["photoUrl"].length -
                        1]["image"]
                        .toString()),
                  ).paddingAll(Insets.i2).decorated(
                      color: (widget.snapshot!.data!).docs[0]["isSeenByOwn"] ==
                          true
                          ? appCtrl.appTheme.grey
                          : appCtrl.appTheme.primary,
                      shape: BoxShape.circle),
              placeholder: (context, url) =>
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                  )
                      .width(Sizes.s20)
                      .height(Sizes.s20)
                      .paddingAll(Insets.i15)
                      .decorated(
                      color: appCtrl.appTheme.grey.withOpacity(.4),
                      shape: BoxShape.circle),
              errorWidget: (context, url, error) =>
                  Image.asset(
                    imageAssets.user,
                    color: appCtrl.appTheme.whiteColor,
                  ).paddingAll(Insets.i15).decorated(
                      color: appCtrl.appTheme.grey.withOpacity(.4),
                      shape: BoxShape.circle)) : CircleAvatar(
              radius: AppRadius.r22,
              child: AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                // Use the VideoPlayer widget to display the video.
                child: VideoPlayer(videoController!),
              ).height(Sizes.s52).width(Sizes.s52).clipRRect(all: AppRadius.r52)
          ).paddingAll(Insets.i2).decorated(
              color: (widget.snapshot!.data!).docs[0]["isSeenByOwn"] ==
                  true
                  ? appCtrl.appTheme.grey
                  : appCtrl.appTheme.primary,
              shape: BoxShape.circle),
          Icon(
            CupertinoIcons.add_circled_solid,
            color: appCtrl.appTheme.primary,
          ).decorated(
              color: appCtrl.appTheme.whiteColor, shape: BoxShape.circle),
        ]));
  }
}
