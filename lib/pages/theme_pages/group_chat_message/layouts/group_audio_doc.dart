
import 'dart:developer';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../config.dart';


class GroupAudioDoc extends StatefulWidget {
  final VoidCallback? onLongPress;
  final DocumentSnapshot? document;

  final bool isReceiver;
  final String? currentUserId;
  const GroupAudioDoc({Key? key, this.onLongPress, this.document,this.isReceiver = false, this.currentUserId}) : super(key: key);

  @override
  State<GroupAudioDoc> createState() => _GroupAudioDocState();
}

class _GroupAudioDocState extends State<GroupAudioDoc> with WidgetsBindingObserver {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  late AudioPlayer _audioPlayer;
  int value = 2;

  void _init() async {
    // initialize the song

    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    _audioPlayer = AudioPlayer();

    await _audioPlayer.setUrl(widget.document!["content"].contains("-BREAK")
        ? widget.document!["content"].split("-BREAK-")[1]
        : widget.document!["content"]);

    // listen for changes in player state
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier.value = ButtonState.playing;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    // listen for changes in play position
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    // listen for changes in the buffered position
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    // listen for changes in the total audio duration
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void play() async {
    log("play");
    log("time : ${value.minutes}");
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    log("pso :$position");
    _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _init();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      _audioPlayer.stop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(
      builder: (chatCtrl) {
        return InkWell(
          onLongPress: widget.onLongPress,
          child: Container(
              margin: const EdgeInsets.symmetric(vertical: Insets.i10),
              padding: const EdgeInsets.symmetric(
                  vertical: Insets.i10, horizontal: Insets.i15),
              decoration: BoxDecoration(
                color: widget.isReceiver
                    ? appCtrl.appTheme.whiteColor
                    : appCtrl.appTheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.r15),
              ),
              height:widget.isReceiver ? Sizes.s80: Sizes.s60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    if (widget.isReceiver)
                      if (widget.document!["sender"] != widget.currentUserId)
                        Align(
                            alignment: Alignment.topLeft,
                            child: Column(children: [
                              Text(widget.document!['senderName'],
                                  style: AppCss.poppinsMedium12
                                      .textColor(appCtrl.appTheme.primary)),
                              const VSpace(Sizes.s8)
                            ])),
                  Expanded(
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (!widget.isReceiver)
                          Row(
                            children: [
                              widget.document!["content"].contains("-BREAK-")
                                  ? SvgPicture.asset(svgAssets.headPhone)
                                  .paddingAll(Insets.i10)
                                  .decorated(
                                  color: appCtrl.appTheme.darkRedColor,
                                  shape: BoxShape.circle)
                                  : Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Image.asset(imageAssets.user1),
                                  SvgPicture.asset(svgAssets.speaker)
                                ],
                              ),
                              const HSpace(Sizes.s10),
                            ],
                          ),
                        //Spacer(),
                        ValueListenableBuilder<ButtonState>(
                          valueListenable: buttonNotifier,
                          builder: (_, value, __) {
                            switch (value) {
                              case ButtonState.loading:
                                return Container(
                                  margin: const EdgeInsets.all(2.0),
                                  width: 2.0,
                                  height: 2.0,
                                  child: const CircularProgressIndicator(),
                                );
                              case ButtonState.paused:
                                return InkWell(
                                  onTap: play,
                                  child: SvgPicture.asset(
                                    svgAssets.arrow,
                                    height: Sizes.s15,
                                    color: widget.isReceiver
                                        ? appCtrl.appTheme.primary
                                        : appCtrl.appTheme.whiteColor,
                                  ).marginOnly(bottom: Insets.i8),
                                );
                              case ButtonState.playing:
                                return InkWell(
                                  onTap: pause,
                                  child: SvgPicture.asset(
                                    svgAssets.pause,
                                    height: Sizes.s15,
                                    color: widget.isReceiver
                                        ? appCtrl.appTheme.primary
                                        : appCtrl.appTheme.whiteColor,
                                  ).marginOnly(bottom: Insets.i8),
                                );
                            }
                          },
                        ),
                        const HSpace(Sizes.s10),

                        Container(
                          //'tipo' == 3; esto para los que son audio mensaje
                            padding: const EdgeInsets.symmetric(
                                horizontal: Insets.i10, vertical: Insets.i6),
                            width: Sizes.s140,
                            //'tipo' == 3; esto para los que son audio mensaje
                            child: ValueListenableBuilder<ProgressBarState>(
                                valueListenable: progressNotifier,
                                builder: (_, value, __) {
                                  return ProgressBar(
                                    timeLabelPadding: Insets.i8,
                                    progress: value.current,
                                    buffered: value.buffered,
                                    total: value.total,
                                    progressBarColor: appCtrl.appTheme.whiteColor,
                                    baseBarColor: widget.isReceiver
                                        ? appCtrl.appTheme.primary.withOpacity(.2)
                                        : appCtrl.appTheme.whiteColor.withOpacity(.2),
                                    thumbColor: const Color(0xFFF4A022),
                                    timeLabelTextStyle: AppCss.poppinsMedium12
                                        .textColor(widget.isReceiver
                                        ? appCtrl.appTheme.primary
                                        : appCtrl.appTheme.whiteColor),
                                    onSeek: seek,
                                    onDragUpdate: ((details) {
                                      log("details : $details");
                                    }),
                                  );
                                })),
                        if (widget.isReceiver)
                          Row(
                            children: [
                              const HSpace(Sizes.s10),
                              widget.document!["content"].contains("-BREAK-")
                                  ? SvgPicture.asset(svgAssets.headPhone)
                                  .paddingAll(Insets.i10)
                                  .decorated(
                                  color: appCtrl.appTheme.darkRedColor,
                                  shape: BoxShape.circle)
                                  : Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Image.asset(imageAssets.user)
                                      .paddingAll(Insets.i10)
                                      .decorated(
                                      color: appCtrl.appTheme.primary
                                          .withOpacity(.5),
                                      shape: BoxShape.circle),
                                  SvgPicture.asset(svgAssets.speaker1)
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      }
    );
  }
}
