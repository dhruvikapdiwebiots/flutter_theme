import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_theme/config.dart';

class VideoCall extends StatefulWidget {
  const VideoCall({Key? key}) : super(key: key);

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final videoCallCtrl = Get.put(VideoCallController());

  @override
  void initState() {
    super.initState();
    var data = Get.arguments;
    videoCallCtrl.channelName = data["channelName"];
    videoCallCtrl.call = data["call"];
    setState(() {});
    log("videoCallCtrl.channelName : ${videoCallCtrl.call!.channelId}");
    videoCallCtrl.initAgora();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoCallController>(builder: (_) {
      log("idddd : ${videoCallCtrl.remoteUidValue}");
      log("idddd : ${videoCallCtrl.call!.callerId}");
      log("idddd : ${videoCallCtrl.call!.receiverId}");
      log("idddd : ${videoCallCtrl.call!.timestamp}");

      return Scaffold(

        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("calls")
                .doc(videoCallCtrl.userData["id"])
                .collection("collectioncallhistory")
                .doc("callData")
                .snapshots(),
            builder: (BuildContext context, snapshot) {
              log("snap : ${snapshot.data!.data()}");

              return Stack(
                children: [
                  Center(
                    child: videoCallCtrl.remoteUidValue != null
                        ? AgoraVideoView(
                            controller: VideoViewController.remote(
                              rtcEngine: videoCallCtrl.engine,
                              canvas: VideoCanvas(
                                  uid: videoCallCtrl.remoteUidValue),
                              connection:
                                  RtcConnection(channelId: fonts.channel),
                            ),
                          )
                        : const Text(
                            'Please wait for remote user to join',
                            textAlign: TextAlign.center,
                          ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 100,
                      height: 150,
                      child: Center(
                        child: videoCallCtrl.localUserJoined
                            ? AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: videoCallCtrl.engine,
                                  canvas: const VideoCanvas(uid: 0),
                                ),
                              )
                            : const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: videoCallCtrl.toolbar(
                        false, snapshot.data!.data()!["STATUS"]),
                  )
                ],
              );
            }),
      );
    });
  }
}
