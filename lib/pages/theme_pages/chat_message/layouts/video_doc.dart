import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../../../config.dart';

class VideoDoc extends StatefulWidget {
  final dynamic document;

  const VideoDoc({Key? key, this.document}) : super(key: key);

  @override
  State<VideoDoc> createState() => _VideoDocState();
}

class _VideoDocState extends State<VideoDoc> {
  VideoPlayerController? videoController;
  late Future<void> initializeVideoPlayerFuture;
  bool startedPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.document!["type"] == MessageType.video.name) {
      videoController = VideoPlayerController.network(
        widget.document!["content"].contains("-BREAK-") ? widget.document!["content"].split("-BREAK-")[1] :widget.document!["content"],
      );
      initializeVideoPlayerFuture = videoController!.initialize();
    }
    setState(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatCtrl) {
      return FutureBuilder(
        future: initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return Stack(
              alignment: Alignment.bottomRight,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: videoController!.value.aspectRatio,
                      // Use the VideoPlayer widget to display the video.
                      child: VideoPlayer(videoController!),
                    ).height(Sizes.s250).clipRRect(all: AppRadius.r8),
                    IconButton(
                        icon: Icon(
                                videoController!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: appCtrl.appTheme.whiteColor)
                            .marginAll(Insets.i3)
                            .decorated(
                                color: appCtrl.appTheme.secondary,
                                shape: BoxShape.circle),
                        onPressed: () {
                          if (videoController!.value.isPlaying) {
                            videoController!.pause();
                          } else {
                            // If the video is paused, play it.
                            videoController!.play();
                          }
                          setState(() {});
                        }),

                  ],
                ),
                Text(DateFormat('HH:mm a').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(widget.document!['timestamp']))),style: AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor),).marginAll(Insets.i10)
              ],
            ).paddingSymmetric(horizontal: Insets.i8,vertical: Insets.i8).inkWell(onTap: (){
              launchUrl(Uri.parse(widget.document!["content"]));
            });
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    });
  }
}
