import 'dart:developer';
import 'dart:io';

import 'package:video_player/video_player.dart';

import '../../../../config.dart';

class ConfirmStatusScreen extends StatefulWidget {
  const ConfirmStatusScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ConfirmStatusScreen> createState() => _ConfirmStatusScreenState();
}

class _ConfirmStatusScreenState extends State<ConfirmStatusScreen> {
  File? file;
  VideoPlayerController? videoController;
  late Future<void> initializeVideoPlayerFuture;
  bool startedPlaying = true;
  File? video;

  @override
  void initState() {
    // TODO: implement initState


    super.initState();
  }

  getImage(dataFile) async {
    file = await dataFile.file;
    setState(() {});
  }

  getVideo(dataFile) async {
    File? videoFile = await dataFile.file;
    video = File(videoFile!.path);
    setState(() {});
    videoController = VideoPlayerController.file(video!);
    initializeVideoPlayerFuture = videoController!.initialize();
    log("video : $videoController");
    videoController!.play();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StatusController>(builder: (statusCtrl) {
      return Scaffold(
        body: Stack(
          children: [
            video != null
                ? FutureBuilder(
                    future: initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        // If the VideoPlayerController has finished initialization, use
                        // the data it provides to limit the aspect ratio of the video.
                        return Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            AspectRatio(
                              aspectRatio: videoController!.value.aspectRatio,
                              // Use the VideoPlayer widget to display the video.
                              child: VideoPlayer(videoController!),
                            ).height(Sizes.s350).clipRRect(all: AppRadius.r8),
                          ],
                        );
                      } else {
                        // If the VideoPlayerController is still initializing, show a
                        // loading spinner.
                        return Container();
                      }
                    },
                  )
                : file != null
                    ? Center(
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: Image.file(file!),
                        ),
                      )
                    : Container(),
            if (statusCtrl.isLoading)
              CommonLoader(
                isLoading: statusCtrl.isLoading,
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
           //   await statusCtrl.addStatus(file!);

              Get.back();
            },
            child: Icon(Icons.done, color: appCtrl.appTheme.whiteColor)),
      );
    });
  }
}
