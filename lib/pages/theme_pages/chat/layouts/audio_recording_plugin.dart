import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:flutter_theme/common/theme/app_css.dart';
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
  Timer? _timer;
  int recordingTime = 0;
  File? recordedFile;

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

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      startTimer();
      recordedFile = null;
      statusText = "Recording...";
      isRecording = true;
      recordingTime = 0;

      recordFilePath = await getFilePath();
      isComplete = false;
      mRecorder!.startRecorder(toFile: "dfd", codec: codec).then((value) {

      });
      setState(() {});
    } else {
      statusText = "No microphone permission";
      isRecording = false;
    }
    setState(() {});
  }

  void stopRecord() async{
    await mRecorder!.stopRecorder().then((value) {
      stopTimer();
      statusText = "Record complete";
      isComplete = true;
      isRecording = false;

      recordedFile = File(recordFilePath);
      setState(() {});
    });

  }

  void getRecorderFnMp3() {
    return !isRecording ? startRecord() : stopRecord();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        recordingTime++;
        setState(() {});
      },
    );
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {});
  }

  void play() {
    if (recordedFile != null && File(recordedFile!.path).existsSync()) {
      setState(() {
        isPlaying = true;
      });
      player.play();

    }
  }

  void stop() {
    player.pause();
    setState(() {
      isPlaying = false;
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
                stopRecord();

              },
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 5),
                child: Text("X", ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text("record audio instruction for you driver.",
           ),
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
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                child: IconButton(
                  onPressed: () => getRecorderFnMp3(),
                  icon: isRecording
                      ? const Icon(Icons.stop, color: Colors.white)
                      : const Icon(Icons.settings_voice, color: Colors.white),
                ),
              ),
              Text(
                 recordingTime.toString(),
              ),
              (recordedFile != null && isComplete)
                  ? Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (isPlaying == true) {
                            stop();
                          } else {
                            play();
                          }
                        },
                        color: Colors.black,
                        icon: Icon(
                          isPlaying == true ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 50,
                      width: 50,
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
                  child: CircularProgressIndicator(

                  ),
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
