import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:camera/camera.dart';
import 'package:flutter_theme/pages/theme_pages/video_call/video_call.dart';

import '../../../config.dart';

class PickupLayout extends StatefulWidget {
  final Widget scaffold;

  const PickupLayout({
    required this.scaffold,
  });

  @override
  State<PickupLayout> createState() => _PickupLayoutState();
}

class _PickupLayoutState extends State<PickupLayout>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation? colorAnimation;
  late CameraController cameraController;

  Animation? sizeAnimation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    colorAnimation = ColorTween(begin: Colors.red, end: Colors.red)
        .animate(CurvedAnimation(parent: controller!, curve: Curves.bounceOut));
    sizeAnimation = Tween<double>(begin: 30.0, end: 60.0).animate(controller!);
    controller!.addListener(() async {
      setState(() {});
    });

    controller!.repeat();
    cameraController = CameraController(cameras[1], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    var user = appCtrl.storage.read(session.user);
    return user != null &&  user != ""? StreamBuilder(
      stream:  FirebaseFirestore.instance
          .collection("calls")
          .doc(user["id"])
          .collection("calling")
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          Call call =
              Call.fromMap(snapshot.data!.docs as Map<dynamic, dynamic>);
          if (!call.hasDialled!) {
            return Scaffold(
              backgroundColor: appCtrl.appTheme.primary,
              body: Stack(
                children: [
                  call.isVideoCall == true
                      ? CameraPreview(cameraController)
                          .height(MediaQuery.of(context).size.height)
                      : Container(
                          color: appCtrl.appTheme.primary,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            call.isVideoCall == true
                                ? Icons.videocam
                                : Icons.mic_rounded,
                            size: 40,
                            color: appCtrl.appTheme.whiteColor,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            call.isVideoCall == true
                                ? 'inComingVideo'
                                : 'inComingAudio',
                            style: TextStyle(
                                fontSize: 18.0,
                                color: appCtrl.appTheme.whiteColor,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 1.1,
                          child: Text(call.callerName!,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 27,
                                  color: appCtrl.appTheme.whiteColor))),
                    ],
                  ).paddingOnly(top: MediaQuery.of(context).size.height / 5.5),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          onTap: () async {
                            flutterLocalNotificationsPlugin!.cancelAll();
                            final videoCtrl =
                                Get.isRegistered<VideoCallController>()
                                    ? Get.find<VideoCallController>()
                                    : Get.put(VideoCallController());
                            await videoCtrl.endCall(call: call);
                            FirebaseFirestore.instance
                                .collection("calls")
                                .doc(call.callerId)
                                .collection("collectionCallHistory")
                                .doc("callData")
                                .set({
                              'status': 'rejected',
                              'ended': DateTime.now(),
                            }, SetOptions(merge: true));
                            FirebaseFirestore.instance
                                .collection("calls")
                                .doc(call.receiverId)
                                .collection("collectionCallHistory")
                                .doc("callData")
                                .set({
                              'status': 'rejected',
                              'ended': DateTime.now(),
                            }, SetOptions(merge: true));
                          },
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 35.0,
                          ).paddingAll(Insets.i15).decorated(
                              color: appCtrl.appTheme.redColor,
                              shape: BoxShape.circle),
                        ),
                        const HSpace(Sizes.s30),
                        InkWell(
                            onTap: () async {
                              log("message");

                              log("message1");
                              if (call.isVideoCall!) {
                                var data = {
                                  "channelName": call.channelId,
                                  "call": call,
                                  "role": ClientRoleType.clientRoleBroadcaster
                                };
                                Get.toNamed(routeName.videoCall,
                                    arguments: data);
                              } else {
                                var data = {
                                  "channelName": call.channelId,
                                  "call": call,
                                  "role": ClientRoleType.clientRoleBroadcaster
                                };
                                Get.toNamed(routeName.audioCall,
                                    arguments: data);
                              }
                            },
                            child: const Icon(
                              Icons.call,
                              color: Colors.white,
                              size: 35.0,
                            ).paddingAll(Insets.i15).decorated(
                                color: Colors.green, shape: BoxShape.circle)),
                      ],
                    ).marginSymmetric(vertical: Insets.i25),
                  ),
                ],
              ),
            );
          } else {}
        }
        return widget.scaffold;
      },
    ):widget.scaffold;
  }
}
