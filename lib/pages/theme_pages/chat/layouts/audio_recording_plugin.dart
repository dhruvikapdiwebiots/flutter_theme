import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_theme/common/theme/app_css.dart';
import 'package:flutter_theme/config.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
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
  String statusText = "";
  bool isRecording = false;
  bool isComplete = false;
  bool mPlaybackReady = false;
  String mPath = 'tau_file.mp4';
  Timer? _timer;
  int recordingTime = 0;
  bool mPlayerIsInited = false;
  bool mRecorderIsInited = false;
  File? recordedFile;
  FlutterSoundPlayer? mPlayer = FlutterSoundPlayer();
  bool isPlaying = false;

  AudioPlayer player = AudioPlayer();

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
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
    return sdPath + "/$fileName.mp3";
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
  void record() {
    mRecorder!.startRecorder(toFile: mPath, codec: codec).then((value) {
      setState(() {});
    });
  }

  // stop recording method
  void stopRecorder() async {
    await mRecorder!.stopRecorder().then((value) {
      mPlaybackReady = true;
      setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    mPlayer!.openPlayer().then((value) {
      mPlayerIsInited = true;
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
    if (!mPlayerIsInited || !mPlaybackReady || !mRecorder!.isStopped) {
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
    assert(mPlayerIsInited &&
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Audio Instruction", style: AppCss.poppinsBold12),
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  "X",
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: appCtrl.appTheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                child: IconButton(
                  onPressed: getRecorderFn(),
                  icon: mRecorder != null
                      ? mRecorder!.isRecording
                          ? const Icon(Icons.stop, color: Colors.white)
                          : const Icon(Icons.settings_voice,
                              color: Colors.white)
                      : const Icon(Icons.settings_voice, color: Colors.white),
                ),
              ),
              Text(
                recordingTime.toString(),
              ),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: appCtrl.appTheme.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                child: IconButton(
                  onPressed: getPlaybackFn(),
                  color: Colors.black,
                  icon: Icon(
                    mPlayer != null
                        ? mPlayer!.isPlaying
                            ? Icons.stop
                            : Icons.play_arrow
                        : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(width: 10),
                const Text("audio is processing...")
              ],
            ),
          ),
      ],
    );
  }
}
