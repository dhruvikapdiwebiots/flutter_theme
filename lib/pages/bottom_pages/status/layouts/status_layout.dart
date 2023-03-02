import 'dart:developer';

import 'package:figma_squircle/figma_squircle.dart';
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
    log("dfdf : ${(widget.snapshot!.data!).docs[0]["photoUrl"][(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]["statusType"]}");
    // TODO: implement initState
    if ((widget.snapshot!.data!).docs[0]["photoUrl"]
                [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
            ["statusType"] ==
        StatusType.video.name) {
      videoController = VideoPlayerController.network(
        (widget.snapshot!.data!).docs[0]["photoUrl"]
            [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]["image"],
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
        Status status = Status.fromJson(widget.snapshot!.data!.docs[0].data());

        Get.toNamed(routeName.statusView, arguments: status);
        await FirebaseFirestore.instance
            .collection('status')
            .doc((widget.snapshot!.data!).docs[0].id)
            .update({
          'isSeenByOwn': true,
        });
      },
      title: Text(appCtrl.storage.read(session.user)["name"],style: AppCss.poppinsBold14.textColor(appCtrl.appTheme.blackColor)),
      subtitle: Text("Tap to add status update",style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor)),
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          (widget.snapshot!.data!).docs[0]["photoUrl"][
                          (widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
                      ["statusType"] ==
                  StatusType.text.name
              ? Container(
            height: Sizes.s50,
            width: Sizes.s50,
                  decoration: ShapeDecoration(
                      color: Color(int.parse(
                          (widget.snapshot!.data!).docs[0]["photoUrl"][
                              (widget.snapshot!.data!)
                                      .docs[0]["photoUrl"]
                                      .length -
                                  1]['statusBgColor'],
                          radix: 16)),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 12, cornerSmoothing: 1),
                      )),
                  child: Text(
                    (widget.snapshot!.data!).docs[0]["photoUrl"][
                        (widget.snapshot!.data!).docs[0]["photoUrl"].length -
                            1]["statusText"],
                    textAlign: TextAlign.center,
                    style: AppCss.poppinsMedium10
                        .textColor(appCtrl.appTheme.whiteColor),
                  ),
                )
              : (widget.snapshot!.data!).docs[0]["photoUrl"]
                              [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
                          ["statusType"] ==
                      StatusType.image.name
                  ? CommonImage(
            isStatusPage: true,
                      image: (widget.snapshot!.data!)
                          .docs[0]["photoUrl"]
                              [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
                              ["image"]
                          .toString(),
                      name: (widget.snapshot!.data!).docs[0]["username"])
                  : Container(
                      height: Sizes.s50,
                      width: Sizes.s50,
                      decoration: ShapeDecoration(
                          color: appCtrl.appTheme.contactBgGray,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 12, cornerSmoothing: 1),
                          )),
                      child: AspectRatio(
                        aspectRatio: videoController!.value.aspectRatio,
                        // Use the VideoPlayer widget to display the video.
                        child: VideoPlayer(videoController!).height(Sizes.s45),
                      ),
                    ),
          Icon(CupertinoIcons.add_circled_solid,
                  color: appCtrl.appTheme.primary, size: Sizes.s18)
              .decorated(
                  color: appCtrl.appTheme.whiteColor, shape: BoxShape.circle)
        ],
      ),
    );
  }
}
