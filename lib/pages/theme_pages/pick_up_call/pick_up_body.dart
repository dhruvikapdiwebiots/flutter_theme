import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:camera/camera.dart';

import '../../../config.dart';

class PickupBody extends StatelessWidget {
  final Call? call;
  final CameraController? cameraController;
  final String? imageUrl;
  const PickupBody({Key? key,this.call,this.cameraController,this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appCtrl.appTheme.primary,
      body: Stack(
        children: [
          call!.isVideoCall == true
              ? CameraPreview(cameraController!)
              .height(MediaQuery.of(context).size.height)
              : Container(
            color: appCtrl.appTheme.primary,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const VSpace(Sizes.s20),
              //caller image
              CallerImage(imageUrl: imageUrl),
              const VSpace(Sizes.s10),
              Text(call!.callerName!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppCss.poppinsblack20
                      .textColor(appCtrl.appTheme.whiteColor)),
              const VSpace(Sizes.s8),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        call!.isVideoCall == true
                            ? Icons.videocam
                            : Icons.mic_rounded,
                        color: appCtrl.appTheme.whiteColor),
                    const HSpace(Sizes.s10),
                    Text(
                        call!.isVideoCall == true
                            ? fonts.inComingVideo.tr
                            : fonts.inComingAudio.tr,
                        style: AppCss.poppinsMedium18.textColor(appCtrl.appTheme.whiteColor))
                  ]),
            ],
          ).paddingSymmetric(vertical: Insets.i35),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    log("cancel");
                    //flutterLocalNotificationsPlugin!.cancelAll();
                    final videoCtrl =
                    Get.isRegistered<VideoCallController>()
                        ? Get.find<VideoCallController>()
                        : Get.put(VideoCallController());
                    await videoCtrl.endCall(call: call!);
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
                      'status': 'rejected',
                      'ended': DateTime.now(),
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
                      'started': null,
                      'callerName': call!.callerName,
                      'status': 'rejected',
                      'ended': DateTime.now(),
                    }, SetOptions(merge: true));
                    Get.back();
                  },
                  child: Icon(
                    Icons.call_end,
                    color: appCtrl.appTheme.whiteColor,
                    size: 35.0,
                  ).paddingAll(Insets.i15).decorated(
                      color: appCtrl.appTheme.redColor,
                      shape: BoxShape.circle),
                ),
                const HSpace(Sizes.s30),
                InkWell(
                    onTap: () async {
                      if (call!.isVideoCall!) {
                        var data = {
                          "channelName": call!.channelId,
                          "call": call,
                          "role":
                          ClientRoleType.clientRoleBroadcaster
                        };
                        Get.toNamed(routeName.videoCall,
                            arguments: data);
                      } else {
                        var data = {
                          "channelName": call!.channelId,
                          "call": call,
                          "role":
                          ClientRoleType.clientRoleBroadcaster
                        };
                        log("data : $data");
                        Get.toNamed(routeName.audioCall,
                            arguments: data);
                      }
                    },
                    child: Icon(
                      Icons.call,
                      color: appCtrl.appTheme.whiteColor,
                      size: 35.0,
                    ).paddingAll(Insets.i15).decorated(
                        color: appCtrl.appTheme.greenColor,
                        shape: BoxShape.circle)),
              ],
            ).marginSymmetric(vertical: Insets.i25),
          ),
        ],
      ),
    );
  }
}