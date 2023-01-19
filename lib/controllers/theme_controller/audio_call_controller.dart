import 'dart:async';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart' as audio_players;
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import '../../config.dart';

class AudioCallController extends GetxController {
  String? channelName;
  Call? call;
  bool localUserJoined = false;
  bool isSpeaker = true, switchCamera = false;
  late RtcEngine engine;
  final _infoStrings = <String>[];
  Stream<int>? timerStream;
  int? remoteUId;

  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  bool muted = false;
  final _users = <int>[];
  bool isAlreadyEnded = false;
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

    userData = appCtrl.storage.read(session.user);
    stream = FirebaseFirestore.instance
        .collection("calls")
        .doc(userData["id"] == call!.callerId
            ? call!.receiverId
            : call!.callerId)
        .collection("collectionCallHistory")
        .doc("callData")
        .snapshots();
    update();

    super.onReady();
  }

  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone].request();
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
                .doc("callData")
                .set({
              'type': 'OUTGOING',
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
                .doc("callData")
                .set({
              'type': 'INCOMING',
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
          update();
          debugPrint("remote user $remoteUidValue joined");
          final info = 'userJoined: $remoteUidValue';
          if (userData["id"] == call!.callerId) {
            _stopCallingSound();
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .doc("callData")
                .set({
              'started': DateTime.now(),
              'status': 'pickedUp',
              'isJoin': true,
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectionCallHistory")
                .doc("callData")
                .set({
              'started': DateTime.now(),
              'status': 'pickedUp',
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .set({
              "audioCallMade": FieldValue.increment(1),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .set({
              "audioCallReceived": FieldValue.increment(1),
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

          final info = 'userOffline: $remoteUid';
          _infoStrings.add(info);
          _users.remove(remoteUid);
          update();
          _stopCallingSound();
          if (isAlreadyEnded == false) {
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .doc("callData")
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectionCallHistory")
                .doc("callData")
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
          _infoStrings.add('onLeaveChannel');
          _users.clear();
          update();
          if (isAlreadyEnded == false) {
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .doc("callData")
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.receiverId)
                .collection("collectionCallHistory")
                .doc("callData")
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
                isAlreadyEnded =
                    status == 'ended' || status == 'rejected' ? true : false;
                update();
                _onCallEnd(Get.context!);
              },
              shape: const CircleBorder(),
              elevation: 2.0,
              fillColor: status == 'ended' || status == 'rejected'
                  ? appCtrl.appTheme.blackColor
                  : Colors.redAccent,
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                status == 'ended' || status == 'rejected'
                    ? Icons.close
                    : Icons.call,
                color: appCtrl.appTheme.whiteColor,
                size: 35.0,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> endCall({required Call call}) async {
    try {
      log("endCallDelete");

      FirebaseFirestore.instance
          .collection("calls")
          .doc(call.callerId)
          .delete();
      FirebaseFirestore.instance
          .collection("calls")
          .doc(call.receiverId)
          .delete();
      return true;
    } catch (e) {
      log("error : $e");
      return false;
    }
  }

  void _onCallEnd(BuildContext context) async {
    /*  final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
    Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);*/
    _stopCallingSound();
    log("endCall1");
    await endCall(call: call!).then((value) async {
      log("value : $value");
      DateTime now = DateTime.now();
      FirebaseFirestore.instance
          .collection("calls")
          .doc(call!.callerId)
          .collection("collectionCallHistory")
          .doc("callData")
          .set({'status': 'ended', 'ended': now}, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection("calls")
          .doc(call!.receiverId)
          .collection("collectionCallHistory")
          .doc("callData")
          .set({'status': 'ended', 'ended': now}, SetOptions(merge: true));
    });

    update();
    log("endCall");
    Wakelock.disable();
    Get.back();
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
    player = (await audioCache.load('sounds/callingtone.mp3'))
        as audio_players.AudioPlayer;
    update();
  }

  audioScreenForPORTRAIT({
    required BuildContext context,
    String? status,
    bool? isPeerMuted,
  }) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    if (status == 'rejected') {
      _stopCallingSound();
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color:appCtrl.appTheme.primary,
            height: h / 4,
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // SizedBox(height: h / 35),
                SizedBox(
                  height: h / 9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 7),
                      SizedBox(
                        width: w / 1.1,
                        child: Text(
                          call!.callerId == userData["id"]
                              ? call!.receiverName!
                              : call!.callerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: appCtrl.appTheme.whiteColor,
                            fontSize: 27,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        call!.callerId == userData["id"]
                            ? call!.receiverId!
                            : call!.callerId!,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: appCtrl.appTheme.whiteColor.withOpacity(0.34),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: h / 25),
                status == 'pickedup'
                    ? Text(
                  "$hoursStr:$minutesStr:$secondsStr",
                  style: TextStyle(
                      fontSize: 20.0,
                      color:  Colors.green[300],
                      fontWeight: FontWeight.w600),
                )
                    : Text(
                  status == 'pickedUp'
                      ? 'picked'
                      : status == 'noNetwork'
                      ? 'connecting'
                      : status == 'ringing' || status == 'missedCall'
                      ? 'calling'
                      : status == 'calling'
                      ?call!.receiverId ==
                      userData["id"]
                      ? 'connecting'
                      : 'calling'
                      : status == 'pickedUp'
                      ?  'onCall'
                      : status == 'ended'
                      ? 'callEnded'
                      : status == 'rejected'
                      ? 'callRejected'
                      : 'plsWait',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: status == 'pickedUp'
                        ? Colors.green
                        :  appCtrl.appTheme.whiteColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Stack(
            children: [
              call!.callerId == userData['id']
                  ? call!.receiverPic == null ||
                  call!.receiverPic == '' ||
                  status == 'ended' ||
                  status == 'rejected'
                  ? Container(
                height: w + (w / 11),
                width: w,
                color: Colors.white12,
                child: Icon(
                  status == 'ended'
                      ? Icons.person_off
                      : status == 'rejected'
                      ? Icons.call_end_rounded
                      : Icons.person,
                  size: 140,
                  color: Colors.green,
                ),
              )
                  : Stack(
                children: [
                  Container(
                      height: w + (w / 11),
                      width: w,
                      color: Colors.white12,
                      child: CachedNetworkImage(
                        imageUrl: call!.callerId ==
                            userData["id"]
                            ? call!.receiverPic!
                            : call!.callerPic!,
                        fit: BoxFit.cover,
                        height: w + (w / 11),
                        width: w,
                        placeholder: (context, url) => Center(
                            child: Container(
                              height: w + (w / 11),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                status == 'ended'
                                    ? Icons.person_off
                                    : status == 'rejected'
                                    ? Icons.call_end_rounded
                                    : Icons.person,
                                size: 140,
                                color: Colors.green,
                              ),
                            )),
                        errorWidget: (context, url, error) =>
                            Container(
                              height: w + (w / 11),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                status == 'ended'
                                    ? Icons.person_off
                                    : status == 'rejected'
                                    ? Icons.call_end_rounded
                                    : Icons.person,
                                size: 140,
                                color: Colors.green,
                              ),
                            ),
                      )),
                  Container(
                    height: w + (w / 11),
                    width: w,
                    color: Colors.black.withOpacity(0.18),
                  ),
                ],
              )
                  : call!.callerPic == null ||
                  call!.callerPic == '' ||
                  status == 'ended' ||
                  status == 'rejected'
                  ? Container(
                height: w + (w / 11),
                width: w,
                color: Colors.white12,
                child: Icon(
                  status == 'ended'
                      ? Icons.person_off
                      : status == 'rejected'
                      ? Icons.call_end_rounded
                      : Icons.person,
                  size: 140,
                  color: Colors.green,
                ),
              )
                  : Stack(
                children: [
                  Container(
                      height: w + (w / 11),
                      width: w,

                      child: CachedNetworkImage(
                        imageUrl: call!.callerId ==
                            userData["id"]
                            ? call!.receiverPic!
                            : call!.callerPic!,
                        fit: BoxFit.cover,
                        height: w + (w / 11),
                        width: w,
                        placeholder: (context, url) => Center(
                            child: Container(
                              height: w + (w / 11),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                status == 'ended'
                                    ? Icons.person_off
                                    : status == 'rejected'
                                    ? Icons.call_end_rounded
                                    : Icons.person,
                                size: 140,
                                color: Colors.green,
                              ),
                            )),
                        errorWidget: (context, url, error) =>
                            Container(
                              height: w + (w / 11),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                status == 'ended'
                                    ? Icons.person_off
                                    : status == 'rejected'
                                    ? Icons.call_end_rounded
                                    : Icons.person,
                                size: 140,
                                color: Colors.green,
                              ),
                            ),
                      )),
                  Container(
                    height: w + (w / 11),
                    width: w,
                    color: Colors.black.withOpacity(0.18),
                  ),
                ],
              ),
              // call!.callerId == curr!entuseruid
              //     ? call!.receiverPic == null ||
              //             call!.receiverPic == '' ||
              //             status == 'ended' ||
              //             status == 'rejected'
              //         ? SizedBox()
              //         : Container(
              //             height: w + (w / 11),
              //             width: w,
              //             color: Colors.black.withOpacity(0.3),
              //           )
              //     : call!.callerPic == null ||
              //             call!.callerPic == '' ||
              //             status == 'ended' ||
              //             status == 'rejected'
              //         ? SizedBox()
              //         : Container(
              //             height: w + (w / 11),
              //             width: w,
              //             color: Colors.black.withOpacity(0.3),
              //           ),
              Positioned(
                  bottom: 20,
                  child: Container(
                    width: w,
                    height: 20,
                    child: Center(
                      child: status == 'pickedUp'
                          ? isPeerMuted == true
                          ? Text(
                        'muted',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.yellow,
                          fontSize: 16,
                        ),
                      )
                          : const SizedBox(
                        height: 0,
                      )
                          : const SizedBox(
                        height: 0,
                      ),
                    ),
                  )),
            ],
          ),
          SizedBox(height: h / 6),
        ],
      ),
    );
  }
}
