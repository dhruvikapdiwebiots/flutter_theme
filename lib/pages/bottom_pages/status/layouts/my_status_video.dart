
import 'package:video_player/video_player.dart';

import '../../../../config.dart';

class MyStatusVideo extends StatefulWidget {
  final PhotoUrl? snapshot;

  const MyStatusVideo({Key? key, this.snapshot}) : super(key: key);

  @override
  State<MyStatusVideo> createState() => _MyStatusVideoState();
}

class _MyStatusVideoState extends State<MyStatusVideo> {
  VideoPlayerController? videoController;
  late Future<void> initializeVideoPlayerFuture;
  bool startedPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.snapshot!
            .statusType ==
        StatusType.video.name) {
      videoController = VideoPlayerController.network(
        widget.snapshot!.image!,
      );
      initializeVideoPlayerFuture = videoController!.initialize();
    }
    setState(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(


      borderRadius:  SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
      child: AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        // Use the VideoPlayer widget to display the video.
        child: VideoPlayer(videoController!),
      ).height(Sizes.s50).width(Sizes.s50)
    );
  }
}
