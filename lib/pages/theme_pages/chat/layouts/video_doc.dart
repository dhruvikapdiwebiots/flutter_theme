import 'package:video_player/video_player.dart';

import '../../../../config.dart';

class VideoDoc extends StatefulWidget {
  final DocumentSnapshot? document;
  const VideoDoc({Key? key,this.document}) : super(key: key);

  @override
  State<VideoDoc> createState() => _VideoDocState();
}

class _VideoDocState extends State<VideoDoc> {
  VideoPlayerController? videoController;
  Future<void>? initializeVideoPlayerFuture;
  bool startedPlaying = false;

  Future<bool> started() async {
    await videoController!.initialize();
    await videoController!.play();
    startedPlaying = true;
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.document!["type"] == MessageType.video.name) {
      videoController = VideoPlayerController.network(
        widget.document!["content"],
      );
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (chatCtrl) {
        return FutureBuilder<bool>(
          future: started(),
          builder:
              (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(
                  videoController!,
                ),
              ).height(Sizes.s200).gestures(onLongPress: () {
                showDialog(
                  context: Get.context!,
                  builder: (BuildContext context) => chatCtrl
                      .buildPopupDialog(context, widget.document!),
                );
              });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      }
    );
  }
}
