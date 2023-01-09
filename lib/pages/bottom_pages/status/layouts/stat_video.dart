import 'package:video_player/video_player.dart';

import '../../../../config.dart';

class StatusVideo extends StatefulWidget {
  final Status? snapshot;
  const StatusVideo({Key? key,this.snapshot}) : super(key: key);

  @override
  State<StatusVideo> createState() => _StatusVideoState();
}

class _StatusVideoState extends State<StatusVideo> {
  VideoPlayerController? videoController;
  late Future<void> initializeVideoPlayerFuture;
  bool startedPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.snapshot!.photoUrl![widget.snapshot!.photoUrl!
        .length - 1].statusType == StatusType.video.name) {
      videoController = VideoPlayerController.network(
        widget.snapshot!.photoUrl![widget.snapshot!.photoUrl!
            .length - 1].image!,
      );
      initializeVideoPlayerFuture = videoController!.initialize();
    }
    setState(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        radius: 28,
        child: AspectRatio(
          aspectRatio: videoController!.value.aspectRatio,
          // Use the VideoPlayer widget to display the video.
          child: VideoPlayer(videoController!),
        ).height(Sizes.s52).width(Sizes.s52).clipRRect(all: AppRadius.r52)
    ).paddingAll(Insets.i2).decorated(
        color: widget.snapshot!.isSeenByOwn ==
        true
        ? appCtrl.appTheme.grey
        : appCtrl.appTheme.primary,
    shape: BoxShape.circle);
  }
}
