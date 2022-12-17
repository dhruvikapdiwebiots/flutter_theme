
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_theme/models/call_model.dart';
import 'package:flutter_theme/pages/theme_pages/call_screen/layouts/audio_call.dart';
import 'package:flutter_theme/pages/theme_pages/call_screen/layouts/call_firebase_method.dart';
import 'package:flutter_theme/pages/theme_pages/call_screen/layouts/video_call.dart';

import '../../../../config.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {dynamic fromData,
        dynamic toData,        bool? isVideoCall,
        required String? currentUserUid,
        context}) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Call call = Call(
        timestamp: timestamp,
        callerId: fromData["id"],
        callerName: fromData["name"],
        callerPic: fromData["image"],
        receiverId: toData["id"],
        receiverName: toData["name"],
        receiverPic: toData["image"],
        channelId: Random().nextInt(1000).toString(),
        isVideoCall: isVideoCall);

    ClientRoleType role = ClientRoleType.clientRoleBroadcaster;
    bool callMade = await callMethods.makeCall(
        call: call, isVideoCall: isVideoCall, timestamp: timestamp);

    call.hasDialled = true;
    if (isVideoCall == false) {
      if (callMade) {
        Get.to(AudioCall(call: call, currentUserUid: currentUserUid,role: role,channelName: call.channelId,));
        /*await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioCall(
              currentUserUid: currentUserUid,
              call: call,
              channelName: call.channelId,
              role: _role,
            ),
          ),
        );*/
      }
    } else {
      if (callMade) {
        Get.to(VideoCall(call: call, currentUserUid: currentUserUid,role: role,channelName: call.channelId,));
        /*await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCall(
              currentUserUid: currentUserUid,
              call: call,
              channelName: call.channelId,
              role: _role,
            ),
          ),
        );*/
      }
    }
  }
}