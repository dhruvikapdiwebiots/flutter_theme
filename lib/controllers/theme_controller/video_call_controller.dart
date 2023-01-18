import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart' as audioPlayers;
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import '../../config.dart';

class VideoCallController extends GetxController {
  String? channelName;
  Call? call;
  bool localUserJoined = false;
  bool isspeaker = true, switchCamera = false;
  late RtcEngine engine;
  final _infoStrings = <String>[];
  Stream<int>? timerStream;
  int? remoteUId;

  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  bool muted = false;
  final _users = <int>[];
  bool isalreadyendedcall = false;
  bool isuserenlarged = false;
  ClientRoleType? role;
  dynamic userData;
  Stream<DocumentSnapshot>? stream;
  audioPlayers.AudioPlayer? player;
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

    userData = appCtrl.storage.read(session.user);
    stream = FirebaseFirestore.instance
        .collection("calls")
        .doc(userData["id"] == call!.callerId
            ? call!.receiverId
            : call!.callerId)
        .collection("collectioncallhistory")
        .doc("callData")
        .snapshots();
    startTimerNow();
    update();
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
    await engine.initialize( RtcEngineContext(
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
                .collection("collectioncallhistory")
                .doc("callData")
                .set({
              'TYPE': 'OUTGOING',
              'ISVIDEOCALL': call!.isVideoCall,
              'PEER': call!.receiverId,
              'TIME': call!.timestamp,
              'DP': call!.receiverPic,
              'ISMUTED': false,
              'TARGET': call!.receiverId,
              'ISJOINEDEVER': false,
              'STATUS': 'calling',
              'STARTED': null,
              'ENDED': null,
              'CALLERNAME': call!.callerName,
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectioncallhistory")
                .doc("callData")
                .set({
              'TYPE': 'INCOMING',
              'ISVIDEOCALL': call!.isVideoCall,
              'PEER': call!.callerId,
              'TIME': call!.timestamp,
              'DP': call!.callerPic,
              'ISMUTED': false,
              'TARGET': call!.receiverId,
              'ISJOINEDEVER': true,
              'STATUS': 'missedcall',
              'STARTED': null,
              'ENDED': null,
              'CALLERNAME': call!.callerName,
            }, SetOptions(merge: true));
          }
          Wakelock.enable();
          //flutterLocalNotificationsPlugin!.cancelAll();
          update();
          Get.forceAppUpdate();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {

          remoteUidValue = remoteUid;
          update();
          debugPrint("remote user $remoteUidValue joined");
          final info = 'userJoined: $remoteUidValue';
          if (userData["id"] == call!.callerId) {
            _stopCallingSound();
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectioncallhistory")
                .doc("callData")
                .set({
              'STARTED': DateTime.now(),
              'STATUS': 'pickedup',
              'ISJOINEDEVER': true,
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectioncallhistory")
                .doc("callData")
                .set({
              'STARTED': DateTime.now(),
              'STATUS': 'pickedup',
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
              "videoCallRecieved": FieldValue.increment(1),
            }, SetOptions(merge: true));

          }
          Wakelock.enable();
          update();
          Get.forceAppUpdate();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          remoteUid = 0;

          final info = 'userOffline: $remoteUid';
          _infoStrings.add(info);
          _users.remove(remoteUid);
          update();
          _stopCallingSound();
          if (isalreadyendedcall == false) {
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectioncallhistory")
                .doc("callData")
                .set({
              'STATUS': 'ended',
              'ENDED': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectioncallhistory")
                .doc("callData")
                .set({
              'STATUS': 'ended',
              'ENDED': DateTime.now(),
            }, SetOptions(merge: true));
            //----------
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection('recent')
                .doc('callended')
                .set({
              'id': call!.receiverId,
              'ENDED': DateTime.now().millisecondsSinceEpoch,
              'CALLERNAME': call!.callerName,
            }, SetOptions(merge: true));
          }
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
        onLeaveChannel: (connection, stats) {
          _stopCallingSound();
          _infoStrings.add('onLeaveChannel');
          _users.clear();
          update();
          if (isalreadyendedcall == false) {
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectioncallhistory")
                .doc("callData")
                .set({
              'STATUS': 'ended',
              'ENDED': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectioncallhistory")
                .doc("callData")
                .set({
              'STATUS': 'ended',
              'ENDED': DateTime.now(),
            }, SetOptions(merge: true));
            //----------
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection('recent')
                .doc('callended')
                .set({
              'id': call!.receiverId,
              'ENDED': DateTime.now().millisecondsSinceEpoch,
              'CALLERNAME': call!.callerName,
            }, SetOptions(merge: true));
          }
          Wakelock.disable();
        },
      ),
    );

    log("engine1 : ${engine}");

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

  onetooneview(double h, double w, bool iscallended, bool userenlarged) {
    final views = AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas:  VideoCanvas(uid: remoteUId),
          connection: RtcConnection(channelId: call!.channelId!),
        ));

    if (iscallended == true) {
      return Container(
        color: appCtrl.appTheme.primary,
        height: h,
        width: w,
        child: Center(
            child: Icon(
          Icons.videocam_off,
          size: 120,
          color: appCtrl.appTheme.blackColor.withOpacity(0.38),
        )),
      );
    }
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  List<Widget> getRenderViews() {
    final List<StatefulWidget> list = [];
    AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas:  VideoCanvas(uid: remoteUId),
          connection: RtcConnection(channelId: call!.channelId!),
        ));

    return list;
  }

  void _onToggleSpeaker() {
    isspeaker = !isspeaker;
    update();
    engine.setEnableSpeakerphone(isspeaker);
  }

  void _stopCallingSound() async {
    player!.stop();
  }

  void _onToggleMute() {
    muted = !muted;
    update();
    _stopCallingSound();
    engine.muteLocalAudioStream(muted);
    /* FirebaseFirestore.instance
        .collection("calls)
        .doc(currentuseruid!)
        .collection("collectioncallhistory")
        .doc(call!.timestamp.toString())
        .set({'ISMUTED': muted}, SetOptions(merge: true));*/
  }

  Widget toolbar(
    bool isshowspeaker,
    String? status,
  ) {
    if (role == ClientRoleType.clientRoleAudience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isshowspeaker == true
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: _onToggleSpeaker,
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    fillColor: isspeaker ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      isspeaker
                          ? Icons.volume_mute_rounded
                          : Icons.volume_off_sharp,
                      color: isspeaker ? Colors.white : Colors.blueAccent,
                      size: 22.0,
                    ),
                  ))
              : const SizedBox(height: 0, width: 65.67),
          status != 'ended' && status != 'rejected'
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: _onToggleMute,
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    fillColor: muted ? Colors.blueAccent : Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      muted ? Icons.mic_off : Icons.mic,
                      color: muted ? Colors.white : Colors.blueAccent,
                      size: 22.0,
                    ),
                  ))
              : const SizedBox(height: 42, width: 65.67),
          SizedBox(
            width: 65.67,
            child: RawMaterialButton(
              onPressed: () async {
                isalreadyendedcall =
                    status == 'ended' || status == 'rejected' ? true : false;
                update();
                _onCallEnd(Get.context!);
              },
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: status == 'ended' || status == 'rejected'
                  ? Colors.black
                  : Colors.redAccent,
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                status == 'ended' || status == 'rejected'
                    ? Icons.close
                    : Icons.call,
                color: Colors.white,
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
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: const Icon(
                      Icons.switch_camera,
                      color: Colors.blueAccent,
                      size: 20.0,
                    ),
                  ),
                ),
          status == 'pickedup'
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: () {
                      isuserenlarged = !isuserenlarged;
                      update();
                    },
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: const Icon(
                      Icons.open_in_full_outlined,
                      color: Colors.black87,
                      size: 15.0,
                    ),
                  ),
                )
              : const SizedBox(
                  width: 65.67,
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
      await FirebaseFirestore.instance
          .collection("collectioncall")
          .doc(call.callerId)
          .delete();
      await FirebaseFirestore.instance
          .collection("collectioncall")
          .doc(call.receiverId)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _onCallEnd(BuildContext context) async {
    /*  final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
    Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);*/
    _stopCallingSound();
    await endCall(call: call!);
    DateTime now = DateTime.now();
    if (isalreadyendedcall == false) {
      await FirebaseFirestore.instance
          .collection("calls")
          .doc(call!.callerId)
          .collection("collectioncallhistory")
          .doc("callData")
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection("calls")
          .doc(call!.receiverId)
          .collection("collectioncallhistory")
          .doc("callData")
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      //----------
      await FirebaseFirestore.instance
          .collection("calls")
          .doc(call!.receiverId)
          .collection('recent')
          .doc('callended')
          .set({
        'id': call!.receiverId,
        'ENDED': DateTime.now().millisecondsSinceEpoch,
        'CALLERNAME': call!.callerName,
      }, SetOptions(merge: true));
    }
    Wakelock.disable();
    Get.back();
  }

  Widget panel({bool? ispeermuted, String? status}) {
    if (status == 'rejected') {
      _stopCallingSound();
    }
    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.bottomCenter,
      child: Container(
        // height: 73,
        margin: const EdgeInsets.symmetric(vertical: 138),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            status == 'pickedup' && ispeermuted == true
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'muted',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'calling' || status == 'ringing' || status == 'missedcall'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          call!.receiverId == userData["id"]
                              ? 'connecting'
                              : 'calling',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'nonetwork'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'connecting',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'ended'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'callended',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.red),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'rejected'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'callrejected',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.red[500]),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0
                  )
          ],
        ),
      ),
    );
  }

  startTimerNow() {
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      hoursStr =
          ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
      minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
      secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      update();
      flutterLocalNotificationsPlugin!.cancelAll();
    });
  }

  Future<void> initialize() async {
    await _initAgoraRtcEngine();

    VideoEncoderConfiguration configuration = const VideoEncoderConfiguration();
    const VideoEncoderConfiguration(
      dimensions: VideoDimensions(width: 640, height: 360),
      frameRate: 15,
      bitrate: 0,
    );
    await engine.setVideoEncoderConfiguration(configuration);
    await engine.joinChannel(
      token:
          "007eJxTYMi4t6KMs+bwpiPqK3tecc7auXVb88XGiL8aMlllwRkePAkKDEaWaRYWaaaGFqnmFiaGyYlJZqmpaebJJinJySZJZmZpxoePJTcEMjKsPjSNkZEBAkF8Hoa0nNKSktSikIzU3FQGBgDF1yRn",
      channelId: "flutterTheme",
      uid: userData["id"],
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> _initAgoraRtcEngine() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: "29f88f518e7841cab6eef7c4dcc4b66f",
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

  }

  Future<void> playCallingTone() async {
    player = (await audioCache.load('assets/sounds/callingtone.mp3'))
        as audioPlayers.AudioPlayer;
    update();
  }
}
