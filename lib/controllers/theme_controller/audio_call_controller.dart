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
  int counter = 0;

  Stream<int> stopWatchStream() {
    // ignore: close_sinks

    Timer? timer;
    Duration timerInterval = const Duration(seconds: 1);

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void setCountDown() {
      const reduceSecondsBy = 1;
      final seconds = timerInterval.inSeconds + reduceSecondsBy;
      streamController!.add(seconds);
      timerInterval = Duration(seconds: seconds);
      update();
    }

    void startTimer() {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
      // timer = Timer.periodic(timerInterval, tick);
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
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await engine.leaveChannel();
    await engine.release();

  }

  @override
  void onReady() async {
    // TODO: implement onReady
    var data = Get.arguments;
    channelName = data["channelName"];
    call = data["call"];
    role = data["role"];
    userData = appCtrl.storage.read(session.user);
    update();

    userData = appCtrl.storage.read(session.user);
    stream = FirebaseFirestore.instance
        .collection(collectionName.calls)
        .doc(userData["id"] == call!.callerId
            ? call!.receiverId
            : call!.callerId)
        .collection("collectionCallHistory")
        .doc(call!.timestamp.toString())
        .snapshots();
    update();
    // retrieve permissions
    await [Permission.microphone].request();
    log("permission :");
    //create the engine
    initAgora();
    super.onReady();
  }

  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  //start time count
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

  Future<void> initAgora() async {
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
          log("localUid : ${connection.localUid}");
          if (call!.callerId == userData["id"]) {

            update();
            FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(call!.callerId)
                .collection(collectionName.collectionCallHistory)
                .doc(call!.timestamp.toString())
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
                .collection(collectionName.calls)
                .doc(call!.receiverId)
                .collection(collectionName.collectionCallHistory)
                .doc(call!.timestamp.toString())
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
          startTimerNow();
          update();
          log("remoteUidValue : $remoteUidValue");
          debugPrint("remote user $remoteUidValue joined");
          if (userData["id"] == call!.callerId) {
            FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(call!.callerId)
                .collection(collectionName.collectionCallHistory)
                .doc(call!.timestamp.toString())
                .set({
              'started': DateTime.now(),
              'status': 'pickedUp',
              'isJoin': true,
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(call!.receiverId)
                .collection(collectionName.collectionCallHistory)
                .doc(call!.timestamp.toString())
                .set({
              'started': DateTime.now(),
              'status': 'pickedUp',
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(call!.callerId)
                .set({
              "audioCallMade": FieldValue.increment(1),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection(collectionName.calls)
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

          if (isAlreadyEnded == false) {
            FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(call!.callerId)
                .collection(collectionName.collectionCallHistory)
                .doc(call!.timestamp.toString())
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(call!.receiverId)
                .collection(collectionName.collectionCallHistory)
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

          _infoStrings.add('onLeaveChannel');
          _users.clear();
          _dispose();
          update();
          if (isAlreadyEnded == false) {
            FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(call!.callerId)
                .collection(collectionName.collectionCallHistory)
                .doc(call!.timestamp.toString())
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection(collectionName.calls)
                .doc(call!.receiverId)
                .collection(collectionName.collectionCallHistory)
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
    await engine.startPreview();

    dynamic agoraToken = appCtrl.storage.read(session.agoraToken);
    log("agoraToken Audio : $agoraToken");
    await engine.joinChannel(
      token: agoraToken["token"],
      channelId: fonts.channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    update();
  }

  //speaker mute - unMute
  void onToggleSpeaker() {
    isSpeaker = !isSpeaker;
    update();
    engine.setEnableSpeakerphone(isSpeaker);
  }


  //firebase mute un Mute
  void onToggleMute() {
    muted = !muted;
    update();

    engine.muteLocalAudioStream(muted);
    FirebaseFirestore.instance
        .collection(collectionName.calls)
        .doc(userData["id"])
        .collection(collectionName.collectionCallHistory)
        .doc(call!.timestamp.toString())
        .set({'isMuted': muted}, SetOptions(merge: true));
  }


  //bottom tool bar
  Widget toolbar(
    bool isShowSpeaker,
    String? status,
  ) {
    if (role == ClientRoleType.clientRoleAudience) return Container();
    return AudioToolBar(
      status: status,
      isShowSpeaker: isShowSpeaker,
    );
  }


  //end call and remove
  Future<bool> endCall({required Call call}) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName.calls)
          .doc(call.callerId)
          .collection(collectionName.calling)
          .where("callerId", isEqualTo: call.callerId)
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection(collectionName.calls)
              .doc(call.callerId)
              .collection("calling")
              .doc(value.docs[0].id)
              .delete();
        }
      });
      await FirebaseFirestore.instance
          .collection(collectionName.calls)
          .doc(call.receiverId)
          .collection(collectionName.calling)
          .where("receiverId", isEqualTo: call.receiverId)
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection(collectionName.calls)
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

  //end call
  void onCallEnd(BuildContext context) async {
    log("endCall1");
    _dispose();
    DateTime now = DateTime.now();
    if (remoteUId != null) {
      await FirebaseFirestore.instance
          .collection(collectionName.calls)
          .doc(call!.callerId)
          .collection(collectionName.collectionCallHistory)
          .doc(call!.timestamp.toString())
          .set({'status': 'ended', 'ended': now}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(collectionName.calls)
          .doc(call!.receiverId)
          .collection(collectionName.collectionCallHistory)
          .doc(call!.timestamp.toString())
          .set({'status': 'ended', 'ended': now}, SetOptions(merge: true));
    } else {
      await endCall(call: call!).then((value) async {
        FirebaseFirestore.instance
            .collection(collectionName.calls)
            .doc(call!.callerId)
            .collection(collectionName.collectionCallHistory)
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
          'started': null,
          'callerName': call!.callerName,
          'status': 'ended',
          'ended': DateTime.now(),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(collectionName.calls)
            .doc(call!.receiverId)
            .collection(collectionName.collectionCallHistory)
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
          'started': null,
          'callerName': call!.callerName,
          'status': 'ended',
          'ended': now
        }, SetOptions(merge: true));
      });
    }
    update();
    log("endCall");
    Wakelock.disable();
    Get.back();
  }


  //audio ui design
  audioScreen({
    String? status,
    bool? isPeerMuted,
  }) {
   var w = MediaQuery.of(Get.context!).size.width;
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // SizedBox(height: h / 35),
              const VSpace(Sizes.s50),
              call!.receiverPic != null
                  ? SizedBox(
                height: Sizes.s100,
                child: CachedNetworkImage(
                    imageUrl: call!.receiverPic!,
                    imageBuilder: (context, imageProvider) =>
                        CircleAvatar(
                          backgroundColor: appCtrl.appTheme.contactBgGray,
                          radius: Sizes.s50,
                          backgroundImage:
                          NetworkImage(call!.receiverPic!),
                        ),
                    placeholder: (context, url) => Image.asset(
                        imageAssets.user,
                        color: appCtrl.appTheme.contactBgGray)
                        .paddingAll(Insets.i15)
                        .decorated(
                        color:
                        appCtrl.appTheme.grey.withOpacity(.4),
                        shape: BoxShape.circle),
                    errorWidget: (context, url, error) => Image.asset(
                      imageAssets.user,
                      color: appCtrl.appTheme.whiteColor,
                    ).paddingAll(Insets.i15).decorated(
                        color:
                        appCtrl.appTheme.grey.withOpacity(.4),
                        shape: BoxShape.circle)),
              )
                  : SizedBox(
                height: Sizes.s100,
                child: Image.asset(
                  imageAssets.user,
                  color: appCtrl.appTheme.whiteColor,
                ).paddingAll(Insets.i15).decorated(
                    color: appCtrl.appTheme.grey.withOpacity(.4),
                    shape: BoxShape.circle),
              ),

              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                        style: AppCss.poppinsblack28
                            .textColor(appCtrl.appTheme.blackColor)))
              ]),
              // SizedBox(height: h / 25),
              const VSpace(Sizes.s20),
              status == 'pickedUp'
                  ? Text(
                "$hoursStr:$minutesStr:$secondsStr",
                style: TextStyle(
                    fontSize: 20.0,
                    color: appCtrl.appTheme.greenColor.withOpacity(.3),
                    fontWeight: FontWeight.w600),
              )
                  : Text(
                  status == 'pickedUp'
                      ? fonts.picked.tr
                      : status == 'noNetwork'
                      ? fonts.connecting.tr
                      : status == 'ringing' || status == 'missedCall'
                      ? fonts.calling.tr
                      : status == 'calling'
                      ? call!.receiverId == userData["id"]
                      ? fonts.connecting.tr
                      : fonts.calling.tr
                      : status == 'pickedUp'
                      ? fonts.onCall.tr
                      : status == 'ended'
                      ? fonts.callEnded.tr
                      : status == 'rejected'
                      ? fonts.callRejected.tr
                      : fonts.plsWait.tr,
                  style: AppCss.poppinsMedium14
                      .textColor(appCtrl.appTheme.blackColor)),
              const SizedBox(height: 16),
            ],
          ).marginSymmetric(vertical: Insets.i15),
        ],
      ),
    );
  }
}
