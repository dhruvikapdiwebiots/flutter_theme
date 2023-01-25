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
        body: GetBuilder<VideoCallController>(builder: (_) {
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("calls")
                  .doc(videoCallCtrl.userData["id"])
                  .collection("collectionCallHistory")
                  .doc(videoCallCtrl.call!.timestamp.toString())
                  .snapshots(),
              builder: (BuildContext context, snapshot) {
                return snapshot.hasData
                    ? snapshot.data!.data()!.isNotEmpty? Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          buildNormalVideoUI(),
                          videoCallCtrl.toolbar(
                              false, snapshot.data!.data()!["status"])
                        ],
                      ) :Center(
                        child: Text(
                  fonts.pleaseWait.tr,
                  textAlign: TextAlign.center,
                  style: AppCss.poppinsMedium16
                        .textColor(appCtrl.appTheme.blackColor),
                ),
                      )
                    : Center(
                      child: Text(
                          fonts.pleaseWait.tr,
                          textAlign: TextAlign.center,
                          style: AppCss.poppinsMedium16
                              .textColor(appCtrl.appTheme.blackColor),
                        ),
                    );
              });
        }),
      );
    });
  }

  Widget buildNormalVideoUI() {
    return GetBuilder<VideoCallController>(builder: (_) {
      return SizedBox(
        height: Get.height,
        child:  buildJoinUserUI(),
      );
    });
  }

  List<Widget> _getRenderViews() {
    final List<AgoraVideoView> list = [
      AgoraVideoView(
        controller: VideoViewController.remote(
            rtcEngine: videoCallCtrl.engine,
            canvas: const VideoCanvas(uid: 0),
            connection: RtcConnection(channelId: fonts.channel)),
      ),
    ];
    videoCallCtrl.users
        .asMap()
        .entries
        .forEach((uid) => list.add(AgoraVideoView(
              controller: VideoViewController.remote(
                  rtcEngine: videoCallCtrl.engine,
                  canvas: VideoCanvas(uid: uid.value),
                  connection: RtcConnection(channelId: fonts.channel)),
            )));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget buildJoinUserUI() {
    final views = _getRenderViews();

    switch (views.length) {
      case 1:
        return Column(
          children: <Widget>[_videoView(views[0])],
        );
      case 2:
        return SizedBox(
            width: Get.width,
            height: Get.height,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      _expandedVideoRow([views[1]]),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 8,
                            color: Colors.white38,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.fromLTRB(15, 40, 10, 15),
                        width: 110,
                        height: 140,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _expandedVideoRow([views[0]]),
                          ],
                        )))
              ],
            ));
      case 3:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        );
      case 4:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        );
      default:
    }
    return Container();
  }
}
