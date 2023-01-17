import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_theme/pages/theme_pages/video_call/video_call.dart';

import '../../../config.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;

  const PickupLayout({
    required this.scaffold,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    var user = appCtrl.storage.read(session.user);
    log("user : ${user["id"]}");
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("calls")
          .doc(user["id"])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call = Call.fromMap(
              snapshot.data!.data() as Map<dynamic, dynamic>);
          var w = MediaQuery.of(context).size.width;
          var h = MediaQuery.of(context).size.height;

          if (!call.hasDialled!) {
            return Scaffold(
                backgroundColor: appCtrl.appTheme.primary,
                body: Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        color: appCtrl.appTheme.whiteColor,
                        height: h / 4,
                        width: w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 7,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  call.isVideoCall == true
                                      ? Icons.videocam
                                      : Icons.mic_rounded,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  call.isVideoCall == true
                                      ? 'incomingvideo'
                                      : 'incomingaudio',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color:  Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: h / 9,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 7),
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width / 1.1,
                                    child: Text(
                                      call.callerName!,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: appCtrl.appTheme.whiteColor,
                                        fontSize: 27,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    call.callerId!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: appCtrl.appTheme.whiteColor.withOpacity(0.34),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: h / 25),

                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      call.callerPic == null || call.callerPic == ''
                          ? Container(
                        height: w + (w / 140),
                        width: w,
                        color: Colors.white12,
                        child: Icon(
                          Icons.person,
                          size: 140,
                          color: appCtrl.appTheme.primary,
                        ),
                      )
                          : Stack(
                        children: [
                          Container(
                              height: w + (w / 140),
                              width: w,
                              color: Colors.white12,
                              child: CachedNetworkImage(
                                imageUrl: call.callerPic!,
                                fit: BoxFit.cover,
                                height: w + (w / 140),
                                width: w,
                                placeholder: (context, url) => Center(
                                    child: Container(
                                      height: w + (w / 140),
                                      width: w,
                                      color: Colors.white12,
                                      child: Icon(
                                        Icons.person,
                                        size: 140,
                                        color: appCtrl.appTheme.primary,
                                      ),
                                    )),
                                errorWidget: (context, url, error) =>
                                    Container(
                                      height: w + (w / 140),
                                      width: w,
                                      color: Colors.white12,
                                      child: Icon(
                                        Icons.person,
                                        size: 140,
                                        color: appCtrl.appTheme.primary,
                                      ),
                                    ),
                              )),
                          Container(
                            height: w + (w / 140),
                            width: w,
                            color: Colors.black.withOpacity(0.18),
                          ),
                        ],
                      ),
                      Container(
                        height: h / 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () async {
                                flutterLocalNotificationsPlugin!.cancelAll();
                                final videoCtrl = Get.isRegistered<VideoCallController>() ? Get.find<VideoCallController>() :Get.put(VideoCallController());
                                await videoCtrl.endCall(call: call);
                                FirebaseFirestore.instance
                                    .collection("calls")
                                    .doc(call.callerId)
                                    .collection("collectioncallhistory")
                                    .doc(call.timestamp.toString())
                                    .set({
                                  'STATUS': 'rejected',
                                  'ENDED': DateTime.now(),
                                }, SetOptions(merge: true));
                                FirebaseFirestore.instance
                                    .collection("calls")
                                    .doc(call.receiverId)
                                    .collection("collectioncallhistory")
                                    .doc(call.timestamp.toString())
                                    .set({
                                  'STATUS': 'rejected',
                                  'ENDED': DateTime.now(),
                                }, SetOptions(merge: true));
                                //----------
                                await FirebaseFirestore.instance
                                    .collection("calls")
                                    .doc(call.receiverId)
                                    .collection('recent')
                                    .doc('callended')
                                    .set({
                                  'id': call.receiverId,
                                  'ENDED': DateTime.now().millisecondsSinceEpoch
                                }, SetOptions(merge: true));


                              },
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.redAccent,
                              padding: const EdgeInsets.all(15.0),
                            ),
                            SizedBox(width: 45),
                            RawMaterialButton(
                              onPressed: () async {
                                log("message");

                                log("message1");
                                if(call.isVideoCall! ){
                                  var data = {
                                    "channelName":call.channelId,
                                    "call":call,
                                    "role": ClientRoleType.clientRoleBroadcaster
                                  };
                                  Get.toNamed(routeName.videoCall,arguments: data);
                                }
                              },
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.green[400],
                              padding: const EdgeInsets.all(15.0),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
          }else{

          }
        }
        return scaffold;
      },
    );
  }
}