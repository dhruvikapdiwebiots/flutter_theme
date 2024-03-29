

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
                  .collection(collectionName.calls)
                  .doc(videoCallCtrl.userData["id"])
                  .collection(collectionName.collectionCallHistory)
                  .doc(videoCallCtrl.call!.timestamp.toString())
                  .snapshots(),
              builder: (BuildContext context, snapshot) {
                return snapshot.hasData
                    ? snapshot.data!.exists
                        ? snapshot.data!.data()!.isNotEmpty
                            ? Stack(
                                alignment: Alignment.bottomCenter,
                                children: [

                                  //video view layout
                                    VideoCallClass().buildNormalVideoUI(),
                                    //bottom tab layout
                                    videoCallCtrl.toolbar(
                                        false, snapshot.data!.data()!["status"])
                                  ])
                            : VideoCallClass().pleaseWaitLayout()
                        : VideoCallClass().pleaseWaitLayout()
                    : VideoCallClass().pleaseWaitLayout();
              });
        }),
      );
    });
  }
}
