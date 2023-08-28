import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_theme/config.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecordingPlugin extends StatefulWidget {
  final String? type;
  final int? index;

  const AudioRecordingPlugin({Key? key, this.type, this.index})
      : super(key: key);

  @override
  AudioRecordingPluginState createState() => AudioRecordingPluginState();
}

class AudioRecordingPluginState extends State<AudioRecordingPlugin> {
  FlutterSoundRecorder? mRecorder = FlutterSoundRecorder();
  bool isLoading = false;
  Codec codec = Codec.aacMP4;
  late String recordFilePath;
  int counter = 0;
  String statusText = "";
  bool isRecording = false;
  bool isComplete = false;
  bool mPlaybackReady = false;
  String mPath = 'tau_file.mp4';
  Timer? _timer;
  int recordingTime = 0;
  String? filePath;
  bool mPlayerIsInit = false;
  bool mRecorderIsInited = false;
  File? recordedFile;
  FlutterSoundPlayer? mPlayer = FlutterSoundPlayer();
  bool isPlaying = false;

  AudioPlayer player = AudioPlayer();

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = "${storageDirectory.path}/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }

    String fileName = DateTime.now().day.toString() +
        DateTime.now().month.toString() +
        DateTime.now().year.toString() +
        DateTime.now().hour.toString() +
        DateTime.now().minute.toString() +
        DateTime.now().second.toString() +
        DateTime.now().millisecond.toString();
    return "$sdPath/$fileName.mp3";
  }

  Future<void> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await mRecorder!.openRecorder();
    if (!await mRecorder!.isEncoderSupported(codec) && kIsWeb) {
      codec = Codec.opusWebM;
      mPath = 'tau_file.webm';
      if (!await mRecorder!.isEncoderSupported(codec) && kIsWeb) {
        mRecorderIsInited = true;
        return;
      }
    }
    mRecorderIsInited = true;
  }

  // record audio
  getRecorderFn() {
    if (!mRecorderIsInited || !mPlayer!.isStopped) {
      return null;
    }
    return mRecorder!.isStopped ? record : stopRecorder;
  }

  // record audio
  void record() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filepath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    mPath = filepath;
    mRecorder!.startRecorder(toFile: filepath, codec: codec).then((value) {
      setState(() {});
    });
    recordFilePath = await getFilePath();
    startTimer();
    setState(() {});
  }

  startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      recordingTime++;
      setState(() {});
    });
  }

  // stop recording method
  void stopRecorder() async {
    await mRecorder!.stopRecorder().then((value) {
      mPlaybackReady = true;
      _timer!.cancel();
      recordedFile = File(mPath);
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    mPlayer!.openPlayer().then((value) {
      mPlayerIsInit = true;
      setState(() {});
    });

    checkPermission().then((value) {
      mRecorderIsInited = true;
      setState(() {});
    });

    super.initState();
  }

  // play recorded audio
  getPlaybackFn() {
    if (!mPlayerIsInit || !mPlaybackReady || !mRecorder!.isStopped) {
      return null;
    }
    return mPlayer != null
        ? mPlayer!.isStopped
            ? play
            : stopPlayer
        : play;
  }

  // play recorded audio
  void play() {
    assert(mPlayerIsInit &&
        mPlaybackReady &&
        mRecorder!.isStopped &&
        mPlayer!.isStopped);
    mPlayer!
        .startPlayer(
            fromURI: mPath,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  // stop player
  void stopPlayer() {
    mPlayer!.stopPlayer().then((value) {
      _timer!.cancel();
      recordedFile = File(mPath);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
              onTap: () {
                Get.back();
              },
              child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Insets.i5),
                  child: Icon(Icons.cancel)))
        ]),
        const SizedBox(height: Sizes.s20),
        Container(
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
                color: appCtrl.appTheme.grey.withOpacity(.5),
                borderRadius:
                    const BorderRadius.all(Radius.circular(AppRadius.r30))),
            padding: const EdgeInsets.all(0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //audio start and stop icon
                  VoiceStopIcons(
                      onPressed: getRecorderFn(), mRecorder: mRecorder),
                  Text(recordingTime.toString(),
                      style: AppCss.poppinsMedium14
                          .textColor(appCtrl.appTheme.txt)),
                  StopArrowIcons(onPressed: getPlaybackFn(), mPlayer: mPlayer)
                ])),
        const VSpace(Sizes.s10),
        CommonButton(
            title: fonts.done.tr,
            style:
                AppCss.poppinsMedium12.textColor(appCtrl.appTheme.whiteColor),
            onTap: () {
              stopPlayer();

              Get.back(result: mPath);
            },
            color: appCtrl.isTheme
                ? appCtrl.appTheme.white
                : appCtrl.appTheme.primary),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(Insets.i10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                      height: Sizes.s20,
                      width: Sizes.s20,
                      child: CircularProgressIndicator()),
                  const HSpace(Sizes.s10),
                  Text(fonts.audioProcess.tr)
                ]),
          )
      ],
    );
  }
}
