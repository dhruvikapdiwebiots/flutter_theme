import 'dart:developer';
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

    log("datadata :: $data");
    videoCallCtrl.channelName = data["channelName"];
    videoCallCtrl.call = data["call"];
    videoCallCtrl.token = data["token"];
    videoCallCtrl.userData = appCtrl.storage.read(session.user);
    setState(() {});
    log("datadata :: $data");
    videoCallCtrl.initAgora();
    videoCallCtrl.update();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return GetBuilder<VideoCallController>(builder: (_) {
          return Scaffold(
            backgroundColor: appCtrl.appTheme.whiteColor,
            body: GetBuilder<VideoCallController>(builder: (_) {
              log("TIME : ${videoCallCtrl.call!.timestamp.toString()}");
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection(collectionName.calls)
                      .doc( appCtrl.user["id"])
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
    );
  }
}
