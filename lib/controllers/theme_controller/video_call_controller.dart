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
  bool localUserJoined = false, isFullScreen = false;
  bool isSpeaker = true, switchCamera = false;
  late RtcEngine engine;
  Stream<int>? timerStream;
  int? remoteUId;
  final users = <int>[];
  final infoStrings = <String>[];

  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  bool muted = false;
  bool isAlreadyEndedCall = false;
  String nameList = "";
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
          final info = 'onJoinChannel: $channel, uid: ${connection.localUid}';
          infoStrings.add(info);
          if (call!.receiver != null) {
            List receiver = call!.receiver!;
            receiver.asMap().entries.forEach((element) {
              if (nameList != "") {
                if (element.value["name"] != element.value["name"]) {
                  nameList = "$nameList, ${element.value["name"]}";
                }
              } else {
                if (element.value["name"] != userData["name"]) {
                  nameList = element.value["name"];
                }
              }
            });
          }
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
              'callerName':
                  call!.receiver != null ? nameList : call!.callerName,
            }, SetOptions(merge: true));
            if (call!.receiver != null) {
              List receiver = call!.receiver!;
              receiver.asMap().entries.forEach((element) {
                if (element.value["id"] != userData["id"]) {
                  FirebaseFirestore.instance
                      .collection("calls")
                      .doc(element.value["id"])
                      .collection("collectionCallHistory")
                      .doc(call!.timestamp.toString())
                      .set({
                    'type': 'inComing',
                    'isVideoCall': call!.isVideoCall,
                    'id': call!.callerId,
                    'timestamp': call!.timestamp,
                    'dp': call!.callerPic,
                    'isMuted': false,
                    'receiverId': element.value["id"],
                    'isJoin': true,
                    'status': 'missedCall',
                    'started': null,
                    'ended': null,
                    'callerName':
                        call!.receiver != null ? nameList : call!.callerName,
                  }, SetOptions(merge: true));
                }
              });
              log("nameList : $nameList");
              update();
            } else {
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
                'callerName':
                    call!.receiver != null ? nameList : call!.callerName,
              }, SetOptions(merge: true));
            }
          }
          Wakelock.enable();
          //flutterLocalNotificationsPlugin!.cancelAll();
          update();
          Get.forceAppUpdate();
        },
        onFirstRemoteAudioFrame: (connection, userId, elapsed) {
          final info = 'firstRemoteVideo: $userId';
          infoStrings.add(info);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          remoteUidValue = remoteUid;
          log("remoteUidValue : $remoteUidValue");
          final info = 'userJoined: $remoteUidValue';
          infoStrings.add(info);
          users.add(remoteUidValue!);
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
                .doc(call!.callerId)
                .set({
              "videoCallMade": FieldValue.increment(1),
            }, SetOptions(merge: true));

            if (call!.receiver != null) {
              List receiver = call!.receiver!;
              receiver.asMap().entries.forEach((element) {
                if (element.value["id"] != userData["id"]) {
                  FirebaseFirestore.instance
                      .collection("calls")
                      .doc(element.value["id"])
                      .collection("collectionCallHistory")
                      .doc(call!.timestamp.toString())
                      .set({
                    'started': DateTime.now(),
                    'status': 'pickedUp',
                  }, SetOptions(merge: true));
                  FirebaseFirestore.instance
                      .collection("calls")
                      .doc(element.value["id"])
                      .set({
                    "videoCallReceived": FieldValue.increment(1),
                  }, SetOptions(merge: true));
                }
              });
            } else {
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
                  .doc(call!.receiverId)
                  .set({
                "videoCallReceived": FieldValue.increment(1),
              }, SetOptions(merge: true));
            }
          }
          Wakelock.enable();
          update();
          Get.forceAppUpdate();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          remoteUid = 0;
          users.remove(remoteUid);
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
            if (call!.receiver != null) {
              List receiver = call!.receiver!;
              receiver.asMap().entries.forEach((element) {
                if (element.value["id"] != userData["id"]) {
                  FirebaseFirestore.instance
                      .collection("calls")
                      .doc(element.value["id"])
                      .collection("collectionCallHistory")
                      .doc(call!.timestamp.toString())
                      .set({
                    'status': 'ended',
                    'ended': DateTime.now(),
                  }, SetOptions(merge: true));
                }
              });
            } else {
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
          }
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
        onLeaveChannel: (connection, stats) {
          _stopCallingSound();
          remoteUId = null;
          infoStrings.add('onLeaveChannel');
          users.clear();

          _dispose();
          update();
          if (isAlreadyEndedCall == false) {
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .add({});
            FirebaseFirestore.instance
                .collection("calls")
                .doc(call!.callerId)
                .collection("collectionCallHistory")
                .doc(call!.timestamp.toString())
                .set({
              'status': 'ended',
              'ended': DateTime.now(),
            }, SetOptions(merge: true));
            if (call!.receiver != null) {
              List receiver = call!.receiver!;
              receiver.asMap().entries.forEach((element) {
                if (element.value['id'] != userData["id"]) {
                  FirebaseFirestore.instance
                      .collection("calls")
                      .doc(element.value['id'])
                      .collection("collectionCallHistory")
                      .doc(call!.timestamp.toString())
                      .set({
                    'status': 'ended',
                    'ended': DateTime.now(),
                  }, SetOptions(merge: true));
                }
              });
            } else {
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

  void onToggleSpeaker() {
    isSpeaker = !isSpeaker;
    update();
    engine.setEnableSpeakerphone(isSpeaker);
  }

  void _stopCallingSound() async {
    player!.stop();
  }

  void onToggleMute() {
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
    return VideoToolBar(isShowSpeaker: isShowSpeaker,status: status,);
  }

  Future<void> onSwitchCamera() async {
    engine.switchCamera();

    update();
  }

  Future<bool> endCall({required Call call}) async {
    try {
      log("endCallDelete");
      if (call.receiver != null) {
        List receiver = call.receiver!;
        receiver.asMap().entries.forEach((element) async {
          await FirebaseFirestore.instance
              .collection("calls")
              .doc(element.value["id"])
              .collection("calling")
              .where("callerId", isEqualTo: element.value["id"])
              .limit(1)
              .get()
              .then((value) {
            if (value.docs.isNotEmpty) {
              FirebaseFirestore.instance
                  .collection("calls")
                  .doc(element.value["id"])
                  .collection("calling")
                  .doc(value.docs[0].id)
                  .delete();
            }
          });
        });
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
      } else {
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
      }

      return true;
    } catch (e) {
      log("error : $e");
      return false;
    }
  }

  void onCallEnd(BuildContext context) async {
    await endCall(call: call!).then((value) async {
      log("value : $value");
      DateTime now = DateTime.now();
      if (call!.receiver != null) {
        List receiver = call!.receiver!;

        update();
        receiver.asMap().entries.forEach((element) {
          FirebaseFirestore.instance
              .collection("calls")
              .doc(element.value["id"])
              .collection("collectionCallHistory")
              .doc(call!.timestamp.toString())
              .set({'status': 'ended', 'ended': now, "callName": nameList},
                  SetOptions(merge: true));
        });
      } else {
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
            .set({'status': 'ended', 'ended': now},
                SetOptions(merge: true)).then((value) {
          remoteUId = null;
          channelName = "";
          role = null;
          update();
        });
      }
      remoteUId = null;
      channelName = "";
      role = null;
      update();
    });

    update();
    _dispose();

    log("endCall");
    Wakelock.disable();
    Get.back();
  }

  Future<void> playCallingTone() async {
    player = (await audioCache.load('sounds/callingtone.mp3'))
        as audio_players.AudioPlayer;
    update();
  }
}
