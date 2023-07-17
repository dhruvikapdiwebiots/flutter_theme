import 'dart:developer' as log;

import 'package:dotted_border/dotted_border.dart';
import 'package:video_player/video_player.dart';
import '../../../../config.dart';
import 'dart:math';

class StatusLayout extends StatefulWidget {
  final AsyncSnapshot? snapshot;

  const StatusLayout({Key? key, this.snapshot}) : super(key: key);

  @override
  State<StatusLayout> createState() => _StatusLayoutState();
}

class _StatusLayoutState extends State<StatusLayout> {
  VideoPlayerController? videoController;
  Future<void>? initializeVideoPlayerFuture;
  bool startedPlaying = false;
  Status? status;

  @override
  void initState() {
    // TODO: implement initState
  log.log("SRR : ${(widget.snapshot!.data!).docs[0].data()}");
    Status status = Status.fromJson((widget.snapshot!.data!).docs[0].data());
    List<PhotoUrl> photoUrl = status.photoUrl!;
    if(photoUrl.isNotEmpty) {
      if (photoUrl.isNotEmpty) {
        if ((widget.snapshot!.data!).docs[0]["photoUrl"][
        (widget.snapshot!.data!).docs[0]["photoUrl"].length == 0
            ? 0
            : (widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
        ["statusType"] ==
            StatusType.video.name) {
          videoController = VideoPlayerController.network(
            (widget.snapshot!.data!).docs[0]["photoUrl"]
            [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
            ["image"],
          )
            ..initialize().then((_) {
              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
              setState(() {});
            }).onError((error, stackTrace) {});
          initializeVideoPlayerFuture = videoController!.initialize();
        }
      }
    }
    setState(() {});
    log.log("STA : $status");
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (videoController != null) {
      if (videoController!.value.isInitialized) {
        videoController!.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    status = Status.fromJson(widget.snapshot!.data!.docs[0].data());
    return ListTile(
      onTap: () async {
        Status status = Status.fromJson(widget.snapshot!.data!.docs[0].data());

        Get.toNamed(routeName.statusView, arguments: status);
      },
      trailing: const Icon(Icons.more_vert)
          .inkWell(onTap: () => Get.toNamed(routeName.myStatus)),
      title: Text((widget.snapshot!.data!).docs[0]['username'],
          style: AppCss.poppinsBold14.textColor(appCtrl.appTheme.blackColor)),
      subtitle: Text("Tap to add status update",
          style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor)),
      leading: DottedBorder(
        color: appCtrl.appTheme.primary,
        padding: const EdgeInsets.all(Insets.i2),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        radius: const SmoothRadius(
          cornerRadius: 15,
          cornerSmoothing: 1,
        ),
        dashPattern: status!.photoUrl!.length == 1
            ? [
                //one status
                (2 * pi * (radius + 2)),
                0,
              ]
            : [
                //multiple status
                colorWidth(radius + 2, status!.photoUrl!.length,
                    separation(status!.photoUrl!.length)),
                separation(status!.photoUrl!.length),
              ],
        strokeWidth: 1,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            (widget.snapshot!.data!).docs[0]["photoUrl"]
                            [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
                        ["statusType"] ==
                    StatusType.text.name
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.i4),
                    height: Sizes.s50,
                    width: Sizes.s50,
                    alignment: Alignment.center,
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
                      style: AppCss.poppinsMedium8
                          .textColor(appCtrl.appTheme.whiteColor),
                    ),
                  )
                : (widget.snapshot!.data!).docs[0]["photoUrl"]
                                [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
                            ["statusType"] ==
                        StatusType.image.name
                    ? CommonImage(
                        height: Sizes.s50,
                        width: Sizes.s50,
                        image: (widget.snapshot!.data!)
                            .docs[0]["photoUrl"]
                                [(widget.snapshot!.data!).docs[0]["photoUrl"].length - 1]
                                ["image"]
                            .toString(),
                        name: (widget.snapshot!.data!).docs[0]["username"])
                    : ClipRRect(
                        borderRadius:
                            SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                        child: videoController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio: videoController!.value.aspectRatio,
                                // Use the VideoPlayer widget to display the video.
                                child: VideoPlayer(videoController!),
                              ).height(Sizes.s50).width(Sizes.s50)
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: Insets.i4),
                                height: Sizes.s50,
                                width: Sizes.s50,
                                alignment: Alignment.center,
                                decoration: ShapeDecoration(
                                    color: appCtrl.appTheme.primary,
                                    shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                          cornerRadius: 12, cornerSmoothing: 1),
                                    )),
                                child: const Text("C"))),
          ],
        ),
      ),
    );
  }
}
