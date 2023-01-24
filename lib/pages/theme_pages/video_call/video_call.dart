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
    videoCallCtrl.userData = appCtrl.storage.read(session.user);
    setState(() {});
    log("videoCallCtrl.channelName : ${videoCallCtrl.call!.channelId}");
    log("videoCallCtrl.channelName : ${videoCallCtrl.channelName}");
    videoCallCtrl.initAgora();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoCallController>(builder: (_) {

      return Scaffold(
        backgroundColor: appCtrl.appTheme.whiteColor,
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("calls")
                .doc(videoCallCtrl.userData["id"])
                .collection("collectionCallHistory")
                .doc(videoCallCtrl.call!.timestamp.toString())
                .snapshots(),
            builder: (BuildContext context, snapshot) {
              log("videoCallCtrl.remoteUidValue : ${videoCallCtrl.remoteUidValue}");
              return !videoCallCtrl.isFullScreen
                  ? Stack(
                      children: [
                        Center(
                          child: videoCallCtrl.remoteUidValue != null
                              ? AgoraVideoView(
                                  controller: VideoViewController.remote(
                                      rtcEngine: videoCallCtrl.engine,
                                      canvas: VideoCanvas(
                                          uid: videoCallCtrl.remoteUidValue),
                                      connection: RtcConnection(
                                          channelId: fonts.channel)),
                                )
                              : Text(
                                  'Please wait for remote user to join',
                                  textAlign: TextAlign.center,
                                  style: AppCss.poppinsMedium16
                                      .textColor(appCtrl.appTheme.blackColor),
                                ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(
                                Insets.i15, Insets.i35, Insets.i15, Insets.i15),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r5)),
                            width: Sizes.s120,
                            height: Sizes.s150,
                            child: Center(
                              child: videoCallCtrl.localUserJoined
                                  ? AgoraVideoView(
                                      controller: VideoViewController(
                                        rtcEngine: videoCallCtrl.engine,
                                        canvas: const VideoCanvas(uid: 0),
                                      ),
                                    ).borderRadius(all: AppRadius.r10)
                                  : const CircularProgressIndicator(),
                            ),
                          ).inkWell(onTap: () {
                            videoCallCtrl.isFullScreen =
                                !videoCallCtrl.isFullScreen;
                            videoCallCtrl.update();
                          }),
                        ),
                        if (snapshot.hasData)
                          if (snapshot.data!.exists)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: videoCallCtrl.toolbar(
                                  false, snapshot.data!.data()!["status"]),
                            )
                      ],
                    )
                  : Stack(
                      children: [
                        Center(
                          child: videoCallCtrl.localUserJoined
                              ? AgoraVideoView(
                                  controller: VideoViewController(
                                  rtcEngine: videoCallCtrl.engine,
                                  canvas: const VideoCanvas(uid: 0),
                                ))
                              :  Text(
                                  'Please wait for remote user to join',
                                  textAlign: TextAlign.center,
                            style: AppCss.poppinsMedium16
                                .textColor(appCtrl.appTheme.blackColor),
                                ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(
                                Insets.i15, Insets.i35, Insets.i15, Insets.i15),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r5)),
                            width: Sizes.s150,
                            height: Sizes.s180,
                            child: Center(
                              child: videoCallCtrl.remoteUidValue != null
                                  ? AgoraVideoView(
                                      controller: VideoViewController.remote(
                                          rtcEngine: videoCallCtrl.engine,
                                          canvas: VideoCanvas(
                                              uid:
                                                  videoCallCtrl.remoteUidValue),
                                          connection: RtcConnection(
                                              channelId: fonts.channel)),
                                    ).borderRadius(all: AppRadius.r10)
                                  : const CircularProgressIndicator(),
                            ),
                          ).inkWell(onTap: () {
                            videoCallCtrl.isFullScreen =
                                !videoCallCtrl.isFullScreen;
                            videoCallCtrl.update();
                          }),
                        ),
                        if (snapshot.hasData)
                          if (snapshot.data!.exists)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: videoCallCtrl.toolbar(
                                  false, snapshot.data!.data()!["status"]),
                            )
                      ],
                    );
            }),
      );
    });
  }
}
