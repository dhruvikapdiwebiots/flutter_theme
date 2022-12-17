//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as audioPlayers;
import 'package:flutter_theme/models/call_model.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class AudioCall extends StatefulWidget {
  final String? channelName;
  final Call call;
  final String? currentUserUid;
  final ClientRoleType? role;

  const AudioCall({Key? key,
    required this.call,
    required this.currentUserUid,
    this.channelName,
    this.role})
      : super(key: key);

  @override
  AudioCallState createState() => AudioCallState();
}

class AudioCallState extends State<AudioCall> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;
  ChannelProfileType channelProfileType =
      ChannelProfileType.channelProfileLiveBroadcasting;


  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.release();

    streamController!.done;
    streamController!.close();
    timerSubscription!.cancel();

    super.dispose();
  }

  Stream<DocumentSnapshot>? stream;

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    stream = FirebaseFirestore.instance
        .collection("calls")
        .doc(widget.currentUserUid == widget.call.callerId
        ? widget.call.receiverId
        : widget.call.callerId)
        .collection("history")
        .doc(widget.call.timestamp.toString())
        .snapshots();
  }

  String? mp3Uri;
  late audioPlayers.AudioPlayer player;
  AudioCache audioCache = AudioCache();

  /* Future<Null> _playCallingTone() async {
    player = await audioCache('sounds/callingtone.mp3', volume: 6);

    setState(() {});
  }*/

  void _stopCallingSound() async {
    player.stop();
  }

  bool isspeaker = false;

  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();

    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    await _engine.setVideoEncoderConfiguration(configuration);
    /*await _engine.joinChannel("01254a6c76514e4787628f4b6bdc1786", widget.channelName!, null, uid: 0);*/
    await _engine.joinChannel(
        token: "01254a6c76514e4787628f4b6bdc1786",
        channelId: widget.channelName!,
        uid: 0,
        options: ChannelMediaOptions(
          channelProfile: channelProfileType,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ));
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine =  createAgoraRtcEngine();
    await _engine.setEnableSpeakerphone(isspeaker);
    await _engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
  }

  bool isAlreadyEndedCall = false;

  void _addAgoraEventHandlers() {
    /*_engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      if (widget.call.callerId == widget.currentUserUid) {
        _playCallingTone();
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'TYPE': 'OUTGOING',
          'ISVIDEOCALL': widget.call.isvideocall,
          'PEER': widget.call.receiverId,
          'TARGET': widget.call.receiverId,
          'TIME': widget.call.timeepoch,
          'DP': widget.call.receiverPic,
          'ISMUTED': false,
          'ISJOINEDEVER': false,
          'STATUS': 'calling',
          'STARTED': null,
          'ENDED': null,
          'CALLERNAME': widget.call.callerName,
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'TYPE': 'INCOMING',
          'ISVIDEOCALL': widget.call.isvideocall,
          'PEER': widget.call.callerId,
          'TARGET': widget.call.receiverId,
          'TIME': widget.call.timeepoch,
          'DP': widget.call.callerPic,
          'ISMUTED': false,
          'ISJOINEDEVER': true,
          'STATUS': 'missedcall',
          'STARTED': null,
          'ENDED': null,
          'CALLERNAME': widget.call.callerName,
        }, SetOptions(merge: true));
      }
      Wakelock.enable();
    }, leaveChannel: (stats) {
      _stopCallingSound();

      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
      if (isAlreadyEndedCall == false) {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        //----------
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection('recent')
            .doc('callended')
            .set({
          'id': widget.call.receiverId,
          'ENDED': DateTime.now().millisecondsSinceEpoch,
          'CALLERNAME': widget.call.callerName,
        }, SetOptions(merge: true));
      }
      Wakelock.disable();
    }, userJoined: (uid, elapsed) {
      startTimerNow();

      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
      if (widget.currentUserUid == widget.call.callerId) {
        _stopCallingSound();
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STARTED': DateTime.now(),
          'STATUS': 'pickedup',
          'ISJOINEDEVER': true,
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STARTED': DateTime.now(),
          'STATUS': 'pickedup',
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .set({
          Dbkeys.audioCallMade: FieldValue.increment(1),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .set({
          Dbkeys.audioCallRecieved: FieldValue.increment(1),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectiondashboard)
            .doc(DbPaths.docchatdata)
            .set({
          Dbkeys.audiocallsmade: FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
      Wakelock.enable();
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
      _stopCallingSound();
      if (isAlreadyEndedCall == false) {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        //----------
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.call.receiverId)
            .collection('recent')
            .doc('callended')
            .set({
          'id': widget.call.receiverId,
          'ENDED': DateTime.now().millisecondsSinceEpoch,
          'CALLERNAME': widget.call.callerName,
        }, SetOptions(merge: true));
      }
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));*/
  }

  Widget _toolbar(bool isshowspeaker,
      String? status,) {
    if (widget.role == ClientRoleType.clientRoleAudience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          status == 'ended' || status == 'rejected'
              ? SizedBox(height: 42, width: 42)
              : RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 22.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () async {
              setState(() {
                isAlreadyEndedCall =
                status == 'ended' || status == 'rejected' ? true : false;
              });

              _onCallEnd(context);
            },
            child: Icon(
              status == 'ended' || status == 'rejected'
                  ? Icons.close
                  : Icons.call,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: status == 'ended' || status == 'rejected'
                ? Colors.black
                : Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          isshowspeaker == true
              ? RawMaterialButton(
            onPressed: _onToggleSpeaker,
            child: Icon(
              isspeaker
                  ? Icons.volume_mute_rounded
                  : Icons.volume_off_sharp,
              color: isspeaker ? Colors.white : Colors.blueAccent,
              size: 22.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: isspeaker ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
              : SizedBox(height: 42, width: 42)
        ],
      ),
    );
  }

  audioscreenForPORTRAIT({
    String? status,
    bool? ispeermuted,
  }) {
    var w = MediaQuery
        .of(context)
        .size
        .width;
    var h = MediaQuery
        .of(context)
        .size
        .height;
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
            margin: EdgeInsets.only(top: MediaQuery
                .of(context)
                .padding
                .top),

            height: h / 4,
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 17,
                      color: Colors.white38,
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      "endtoendencryption",
                      style: TextStyle(
                          color: Colors.white38, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                // SizedBox(height: h / 35),
                SizedBox(
                  height: h / 9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 7),
                      SizedBox(
                        width: w / 1.1,
                        child: Text(
                          widget.call.callerId == widget.currentUserUid
                              ? widget.call.receiverName!
                              : widget.call.callerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 27,
                          ),
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        widget.call.callerId == widget.currentUserUid
                            ? widget.call.receiverId!
                            : widget.call.callerId!,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
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

                      fontWeight: FontWeight.w600),
                )
                    : Text(
                  status == 'pickedup'
                      ? 'picked'
                      : status == 'nonetwork'
                      ? 'connecting'
                      : status == 'ringing' || status == 'missedcall'
                      ? 'calling'
                      : status == 'calling'
                      ? widget.call.receiverId ==
                      widget.currentUserUid
                      ? 'connecting'
                      : 'calling'
                      : status == 'pickedup'
                      ? 'oncall'
                      : status == 'ended'
                      ? 'callended'
                      : status == 'rejected'
                      ? 'callrejected'
                      : 'plswait',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Stack(
            children: [
              widget.call.callerId == widget.currentUserUid
                  ? widget.call.receiverPic == null ||
                  widget.call.receiverPic == '' ||
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

                ),
              )
                  : Stack(
                children: [
                  Container(
                      height: w + (w / 11),
                      width: w,
                      color: Colors.white12,
                      child: CachedNetworkImage(
                        imageUrl: widget.call.callerId ==
                            widget.currentUserUid
                            ? widget.call.receiverPic!
                            : widget.call.callerPic!,
                        fit: BoxFit.cover,
                        height: w + (w / 11),
                        width: w,
                        placeholder: (context, url) =>
                            Center(
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
                  : widget.call.callerPic == null ||
                  widget.call.callerPic == '' ||
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

                ),
              )
                  : Stack(
                children: [
                  Container(
                      height: w + (w / 11),
                      width: w,
                      child: CachedNetworkImage(
                        imageUrl: widget.call.callerId ==
                            widget.currentUserUid
                            ? widget.call.receiverPic!
                            : widget.call.callerPic!,
                        fit: BoxFit.cover,
                        height: w + (w / 11),
                        width: w,
                        placeholder: (context, url) =>
                            Center(
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
              // widget.call.callerId == widget.currentUserUid
              //     ? widget.call.receiverPic == null ||
              //             widget.call.receiverPic == '' ||
              //             status == 'ended' ||
              //             status == 'rejected'
              //         ? SizedBox()
              //         : Container(
              //             height: w + (w / 11),
              //             width: w,
              //             color: Colors.black.withOpacity(0.3),
              //           )
              //     : widget.call.callerPic == null ||
              //             widget.call.callerPic == '' ||
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
                      child: status == 'pickedup'
                          ? ispeermuted == true
                          ? Text(
                        'muted',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,

                          fontSize: 16,
                        ),
                      )
                          : SizedBox(
                        height: 0,
                      )
                          : SizedBox(
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

  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) async {
    /*final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
    Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);
    stopWatchStream();
    await CallUtils.callMethods.endCall(call: widget.call);
    DateTime now = DateTime.now();
    _stopCallingSound();
    if (isAlreadyEndedCall == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.callerId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.receiverId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      //----------
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.receiverId)
          .collection('recent')
          .doc('callended')
          .set({
        'id': widget.call.receiverId,
        'ENDED': DateTime
            .now()
            .millisecondsSinceEpoch,
        'CALLERNAME': widget.call.callerName,
      }, SetOptions(merge: true));
    }
    Wakelock.disable();
    firestoreDataProviderCALLHISTORY.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.currentUserUid)
            .collection(DbPaths.collectioncallhistory)
            .orderBy('TIME', descending: true)
            .limit(14),
        true);
    Navigator.pop(context);*/
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _stopCallingSound();
    _engine.muteLocalAudioStream(muted);
  /*  FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentUserUid)
        .collection(DbPaths.collectioncallhistory)
        .doc(widget.call.timeepoch.toString())
        .set({'ISMUTED': muted}, SetOptions(merge: true));*/
  }

  void _onToggleSpeaker() {
    setState(() {
      isspeaker = !isspeaker;
    });
    _engine.setEnableSpeakerphone(isspeaker);
  }

  Future<bool> onWillPopNEw(BuildContext context) {
    // _onCallEnd(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery
        .of(context)
        .size
        .width;
    var h = MediaQuery
        .of(context)
        .size
        .height;
    return WillPopScope(
      onWillPop: () => onWillPopNEw(context),
      child: Scaffold(

          body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream:
            stream as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.data() == null ||
                    snapshot.data == null) {
                  return Center(
                    child: Stack(
                      children: <Widget>[
                      audioscreenForPORTRAIT(

                      status: 'calling',
                      ispeermuted: snapshot.data!.data()!["ISMUTED"],
                     // _panel(),
                    )
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        // _viewRows(),
                        audioscreenForPORTRAIT(

                            status: snapshot.data!.data()!["STATUS"],
                            ispeermuted: snapshot.data!.data()!["ISMUTED"]),

                        _panel(),
                        _toolbar(
                            snapshot.data!.data()!["STATUS"] == 'pickedup'
                                ? true
                                : false,
                            snapshot.data!.data()!["STATUS"]),
                      ],
                    ),
                  );
                }
              } else if (!snapshot.hasData) {
                return Center(
                  child: Stack(
                    children: <Widget>[
                      // _viewRows(),
                      audioscreenForPORTRAIT(

                          status: 'nonetwork',
                          ispeermuted: false),
                      _panel(),
                      _toolbar(false, 'nonetwork'),
                    ],
                  ),
                );
              }

              return Center(
                child: Stack(
                  children: <Widget>[
                    // _viewRows(),
                    audioscreenForPORTRAIT(

                        status: 'calling',
                        ispeermuted: false),
                    _panel(),
                    _toolbar(false, 'calling'),
                  ],
                ),
              );
            },
          ))

    );
  }

  //------ Timer Widget Section Below:
  bool flag = true;
  Stream<int>? timerStream;

  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;

  // ignore: close_sinks
  StreamController<int>? streamController;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    // ignore: close_sinks

    Timer? timer;
    Duration timerInterval = Duration(seconds: 1);
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
      if (!flag) {
        stopTimer();
      }
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

  startTimerNow() {
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      setState(() {
        hoursStr =
            ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
      //flutterLocalNotificationsPlugin.cancelAll();
    });
  }

//------
}
