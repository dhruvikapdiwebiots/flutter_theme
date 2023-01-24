import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart' as audio_players;
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import '../../config.dart';

class VideoCallController extends GetxController {
  String? channelName;
  Call? call;
  bool localUserJoined = false,isFullScreen = false;
  bool isSpeaker = true, switchCamera = false;
  late RtcEngine engine;
  final _infoStrings = <String>[];
  Stream<int>? timerStream;
  int? remoteUId;

  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  bool muted = false;
  final _users = <int>[];
  bool isAlreadyEndedCall = false;

  ClientRoleType? role;
  dynamic userData;
  Stream<DocumentSnapshot>? stream;
  audio_players.AudioPlayer? player;
  AudioCache audioCache = AudioCache();
  int? remoteUidValue;

  // ignore: close_sinks
  StreamController<int>? streamController;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    // ignore: close_sinks

    Timer? timer;
    Duration timerInterval = const Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void tick(_) {
      counter++;
      streamController!.add(counter);
      stopTimer();
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController!.stream;
  }

  @override
  void onReady() {
    // TODO: implement onReady
    var data = Get.arguments;
    channelName = data["channelName"];
    call = data["call"];
    role = data["role"];
    userData = appCtrl.storage.read(session.user);
    update();

    stream = FirebaseFirestore.instance
        .collection("calls")
        .doc(userData["id"])
        .collection("collectionCallHistory")
        .doc(call!.timestamp.toString())
        .snapshots();
    update();
    log("stream : $stream");
    super.onReady();
  }

  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();
    log("permis :");
    //create the engine
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(
      appId: fonts.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    log("engine : $engine");

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          localUserJoined = true;

          if (call!.callerId == userData["id"]) {
            playCallingTone();

            update();
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'type': 'outGoing',
              'isVideoCall': call!.isVideoCall,
              'id': call!.receiverId,
              'timestamp': call!.timestamp,
              'dp': call!.receiverPic,
              'isMuted': false,
              'receiverId': call!.receiverId,
              'isJoin': false,
              'status': 'calling',
              'started': null,
              'ended': null,
              'callerName': call!.callerName,
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'type': 'inComing',
              'isVideoCall': call!.isVideoCall,
              'id': call!.callerId,
              'timestamp': call!.timestamp,
              'dp': call!.callerPic,
              'isMuted': false,
              'receiverId': call!.receiverId,
              'isJoin': true,
              'status': 'missedCall',
              'started': null,
              'ended': null,
              'callerName': call!.callerName,
            }, SetOptions(merge: true));
          }
          Wakelock.enable();
          //flutterLocalNotificationsPlugin!.cancelAll();
          update();
          Get.forceAppUpdate();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          remoteUidValue = remoteUid;
          log("remoteUidValue : $remoteUidValue");
          update();
          debugPrint("remote user $remoteUidValue joined");

          if (userData["id"] == call!.callerId) {
            _stopCallingSound();
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'started': DateTime.now(),
              'status': 'pickedUp',
              'isJoin': true,
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'started': DateTime.now(),
              'status': 'pickedUp',
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .set({
              "videoCallMade": FieldValue.increment(1),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .set({
              "videoCallReceived": FieldValue.increment(1),
            }, SetOptions(merge: true));
          }
          Wakelock.enable();
          update();
          Get.forceAppUpdate();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          remoteUid = 0;
          _users.remove(remoteUid);
          update();
          _stopCallingSound();
          if (isAlreadyEndedCall == false) {
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
          }
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
        onLeaveChannel: (connection, stats) {
          _stopCallingSound();
          remoteUId = null;
          _users.clear();
          _dispose();
          update();
          if (isAlreadyEndedCall == false) {
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory").add({});
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
          }
          Wakelock.disable();
          Get.back();
          update();
        },
      ),
    );

    log("engine1 : $engine");

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.enableVideo();
    await engine.startPreview();

    await engine.joinChannel(
      token: fonts.token,
      channelId: fonts.channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    update();
  }

  void _onToggleSpeaker() {
    isSpeaker = !isSpeaker;
    update();
    engine.setEnableSpeakerphone(isSpeaker);
  }

  void _stopCallingSound() async {
    player!.stop();
  }

  void _onToggleMute() {
    muted = !muted;
    update();
    _stopCallingSound();
    engine.muteLocalAudioStream(muted);
    FirebaseFirestore.instance
        .collection("calls")
        .doc(userData["id"])
        .collection("collectionCallHistory")
        .doc(call!.timestamp.toString())
        .set({'isMuted': muted}, SetOptions(merge: true));
  }


  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await engine.leaveChannel();
    await engine.release();
  }


  Widget toolbar(
    bool isShowSpeaker,
    String? status,
  ) {
    if (role == ClientRoleType.clientRoleAudience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: Insets.i35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              width: 65.67,
              child: RawMaterialButton(
                onPressed: _onToggleSpeaker,
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: isSpeaker
                    ? appCtrl.appTheme.primary
                    : appCtrl.appTheme.whiteColor,
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  isSpeaker
                      ? Icons.volume_mute_rounded
                      : Icons.volume_off_sharp,
                  color: isSpeaker
                      ? appCtrl.appTheme.whiteColor
                      : appCtrl.appTheme.primary,
                  size: 22.0,
                ),
              )),
          status != 'ended' && status != 'rejected'
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: _onToggleMute,
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    fillColor: muted
                        ? appCtrl.appTheme.primary
                        : appCtrl.appTheme.whiteColor,
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      muted ? Icons.mic_off : Icons.mic,
                      color: muted
                          ? appCtrl.appTheme.whiteColor
                          : appCtrl.appTheme.primary,
                      size: 22.0,
                    ),
                  ))
              : const SizedBox(height: 42, width: 65.67),
          SizedBox(
            width: 65.67,
            child: RawMaterialButton(
              onPressed: () async {
                isAlreadyEndedCall =
                    status == 'ended' || status == 'rejected' ? true : false;
                update();
                _onCallEnd(Get.context!);
              },
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: status == 'ended' || status == 'rejected'
                  ? appCtrl.appTheme.blackColor
                  : appCtrl.appTheme.redColor,
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                status == 'ended' || status == 'rejected'
                    ? Icons.close
                    : Icons.call,
                color: appCtrl.appTheme.whiteColor,
                size: 35.0,
              ),
            ),
          ),
          status == 'ended' || status == 'rejected'
              ? const SizedBox(
                  width: 65.67,
                )
              : SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: _onSwitchCamera,
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    fillColor: appCtrl.appTheme.whiteColor,
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.switch_camera,
                      color: appCtrl.appTheme.primary,
                      size: 20.0,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Future<void> _onSwitchCamera() async {
    engine.switchCamera();

    update();
  }

  Future<bool> endCall({required Call call}) async {
    try {
      log("endCallDelete");

      await FirebaseFirestore.instance
          .collection("calls")
          .doc(call.callerId)
          .collection("calling")
          .where("callerId", isEqualTo: call.callerId)
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection("calls")
              .doc(call.callerId)
              .collection("calling")
              .doc(value.docs[0].id)
              .delete();
        }
      });
      await FirebaseFirestore.instance
          .collection("calls")
          .doc(call.receiverId)
          .collection("calling")
          .where("receiverId", isEqualTo: call.receiverId)
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection("calls")
              .doc(call.receiverId)
              .collection("calling")
              .doc(value.docs[0].id)
              .delete();
        }
      });
      return true;
    } catch (e) {
      log("error : $e");
      return false;
    }
  }

  void _onCallEnd(BuildContext context) async {

    await endCall(call: call!).then((value) async {
      log("value : $value");
      DateTime now = DateTime.now();
      FirebaseFirestore.instance
          .collection("calls")
          .doc(call!.callerId)
          .collection("collectionCallHistory")
          .doc(call!.timestamp.toString())
          .set({'status': 'ended', 'ended': now}, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection("calls")
          .doc(call!.receiverId)
          .collection("collectionCallHistory")
          .doc(call!.timestamp.toString())
          .set({'status': 'ended', 'ended': now}, SetOptions(merge: true)).then((value) {
            remoteUId =null;
            channelName="";
            role = null;
            update();
      });
    });

    update();
    _dispose();

    log("endCall");
    Wakelock.disable();
    Get.back();

  }

  Future<void> _initAgoraRtcEngine() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(
      appId: fonts.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  Future<void> playCallingTone() async {
    player = (await audioCache.load('sounds/callingtone.mp3'))
        as audio_players.AudioPlayer;
    update();
  }
}
