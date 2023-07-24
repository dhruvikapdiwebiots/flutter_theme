import 'dart:developer';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

import '../../../../config.dart';

class GroupAudioDoc extends StatefulWidget {
  final VoidCallback? onLongPress, onTap;
  final DocumentSnapshot? document;

  final bool isReceiver;
  final String? currentUserId;

  const GroupAudioDoc(
      {Key? key,
      this.onLongPress,
      this.document,
      this.isReceiver = false,
      this.currentUserId,
      this.onTap})
      : super(key: key);

  @override
  State<GroupAudioDoc> createState() => _GroupAudioDocState();
}

class _GroupAudioDocState extends State<GroupAudioDoc>
    with WidgetsBindingObserver {

  /// Optional
  int timeProgress = 0;
  int audioDuration = 0;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration positions = Duration.zero;
  AudioPlayer audioPlayer = AudioPlayer();
  int value = 2;

  void play() async {
    log("play");
    String url = decryptMessage(widget.document!['content']).contains("-BREAK")
        ? decryptMessage(widget.document!['content']).split("-BREAK-")[1]
        : decryptMessage(widget.document!['content']);

    log("time : ${value.minutes}");
    audioPlayer.play(UrlSource(url));
  }

  void pause() {
    audioPlayer.pause();
  }

  void seek(Duration position) {
    log("pso :$position");
    audioPlayer.seek(position);
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  /// Optional
  Widget slider() {
    return SliderTheme(
      data: SliderThemeData(overlayShape: SliderComponentShape.noThumb),
      child: Slider(
          value: timeProgress.toDouble(),
          max: audioDuration.toDouble(),
          activeColor: appCtrl.appTheme.orangeColor,
          inactiveColor: appCtrl.appTheme.whiteColor,
          onChanged: (value) async {
            seekToSec(value.toInt());
          }),
    ).width(Sizes.s130);
  }

  @override
  void initState() {
    super.initState();

    /// Compulsory
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      log("state : $state");
      isPlaying = state == PlayerState.playing;
    });
    String url = decryptMessage(widget.document!['content']).contains("-BREAK")
        ? decryptMessage(widget.document!['content']).split("-BREAK-")[1]
        : decryptMessage(widget.document!['content']);

    audioPlayer.setSourceUrl(url);

    audioPlayer.onPositionChanged.listen((position) async {
      setState(() {
        timeProgress = position.inSeconds;
      });
    });

    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        audioDuration = duration.inSeconds;
      });
    });
  }

  /// Optional
  void seekToSec(int sec) {
    Duration newPos = Duration(seconds: sec);
    audioPlayer
        .seek(newPos); // Jumps to the given position within the audio file
  }

  /// Optional
  String getTimeString(int seconds) {
    String minuteString =
        '${(seconds / 60).floor() < 10 ? 0 : ''}${(seconds / 60).floor()}';
    String secondString = '${seconds % 60 < 10 ? 0 : ''}${seconds % 60}';
    return '$minuteString:$secondString'; // Returns a string with the format mm:ss
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Release the player's resources when not in use. We use "stop" so that
      // if the app resumes later, it will still remember what position to
      // resume from.
      audioPlayer.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupChatMessageController>(builder: (chatCtrl) {
      return InkWell(
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  
                    margin: const EdgeInsets.symmetric(vertical: Insets.i10,horizontal: Insets.i10),
                    padding: const EdgeInsets.symmetric(
                        vertical: Insets.i5, horizontal: Insets.i15),
                    decoration: BoxDecoration(
                      color: widget.isReceiver
                          ? appCtrl.appTheme.chatSecondaryColor
                          : appCtrl.appTheme.primary,
                      borderRadius: BorderRadius.circular(AppRadius.r15),
                    ),
                    height: widget.isReceiver ? Sizes.s115 : Sizes.s90,
                    child: Column(
                      crossAxisAlignment: widget.isReceiver ? CrossAxisAlignment.start :CrossAxisAlignment.end ,
                      children: [
                        if (widget.isReceiver)
                          if (widget.document!["sender"] !=
                              widget.currentUserId)
                            Align(
                                alignment: Alignment.topLeft,
                                child: Column(children: [
                                  const VSpace(Sizes.s2),
                                  Text(widget.document!['senderName'],
                                      style: AppCss.poppinsMedium12
                                          .textColor(appCtrl.appTheme.primary)),

                                ])),
                        Expanded(
                          child: Row(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if (!widget.isReceiver)
                                Row(
                                  children: [
                                    decryptMessage(widget.document!['content'])
                                            .contains("-BREAK-")
                                        ? SvgPicture.asset(svgAssets.headPhone)
                                            .paddingAll(Insets.i10)
                                            .decorated(
                                                color: appCtrl
                                                    .appTheme.darkRedColor,
                                                shape: BoxShape.circle)
                                        : Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Image.asset(imageAssets.user1),
                                              SvgPicture.asset(
                                                  svgAssets.speaker)
                                            ],
                                          ),
                                    const HSpace(Sizes.s10),
                                  ],
                                ),
                              IntrinsicHeight(
                                  child: Row(mainAxisSize: MainAxisSize.min,children: [
                                InkWell(
                                    onTap: () async {
                                      if (isPlaying) {
                                        await audioPlayer.pause();
                                      } else {
                                        play();
                                      }
                                    },
                                    child: SvgPicture.asset(
                                      isPlaying
                                          ? svgAssets.pause
                                          : svgAssets.arrow,
                                      height: Sizes.s15,
                                      color: widget.isReceiver
                                          ? appCtrl.appTheme.primary
                                          : appCtrl.appTheme.blackColor,
                                    )),
                                const HSpace(Sizes.s10),
                                Column(
                                  children: [
                                    slider(),
                                    const VSpace(Sizes.s5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(getTimeString(timeProgress),
                                            style: AppCss.poppinsMedium12
                                                .textColor(appCtrl
                                                    .appTheme.blackColor)),
                                        const HSpace(Sizes.s80),
                                        Text(getTimeString(audioDuration),
                                            style: AppCss.poppinsMedium12
                                                .textColor(appCtrl
                                                    .appTheme.blackColor))
                                      ],
                                    )
                                  ],
                                ).marginOnly(top: Insets.i16)
                              ])),
                              if (widget.isReceiver)
                                Row(
                                  children: [
                                    const HSpace(Sizes.s10),
                                    decryptMessage(widget.document!['content'])
                                            .contains("-BREAK-")
                                        ? SvgPicture.asset(svgAssets.headPhone)
                                            .paddingAll(Insets.i10)
                                            .decorated(
                                                color: appCtrl
                                                    .appTheme.darkRedColor,
                                                shape: BoxShape.circle)
                                        : Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Image.asset(imageAssets.user,height: Sizes.s20,)
                                                  .paddingAll(Insets.i10)
                                                  .decorated(
                                                      color: appCtrl
                                                          .appTheme.primary
                                                          .withOpacity(.5),
                                                      shape: BoxShape.circle),
                                              SvgPicture.asset(
                                                  svgAssets.speaker1)
                                            ],
                                          ),
                                  ],
                                ),
                            ],
                          )
                        ),
                        IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.document!.data().toString().contains('isFavourite'))
                                  if(appCtrl.user["id"] == widget.document!["favouriteId"])
                                  Icon(Icons.star,color: appCtrl.appTheme.txtColor,size: Sizes.s10),
                                const HSpace(Sizes.s3),
                                Text(
                                  DateFormat('HH:mm a').format(DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(widget.document!['timestamp']))),
                                  style:
                                  AppCss.poppinsMedium12.textColor(appCtrl.appTheme.txtColor),
                                ),
                              ],
                            )
                        )
                      ],
                    )),
                if (widget.document!.data().toString().contains('emoji'))
                  EmojiLayout(emoji: widget.document!["emoji"])
              ],
            ),
          ],
        ),
      );
    });
  }
}
