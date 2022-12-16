
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
      {String? fromUID,
        String? fromFullname,
        String? fromDp,
        String? toFullname,
        String? toDp,
        String? toUID,
        bool? isVideoCall,
        required String? currentuseruid,
        context}) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Call call = Call(
        timestamp: timestamp,
        callerId: fromUID,
        callerName: fromFullname,
        callerPic: fromDp,
        receiverId: toUID,
        receiverName: toFullname,
        receiverPic: toDp,
        channelId: Random().nextInt(1000).toString(),
        isVideoCall: isVideoCall);

    ClientRoleType _role = ClientRoleType.clientRoleBroadcaster;
    bool callMade = await callMethods.makeCall(
        call: call, isVideoCall: isVideoCall, timestamp: timestamp);

    call.hasDialled = true;
    if (isVideoCall == false) {
      if (callMade) {
        Get.to(AudioCall(call: call, currentuseruid: currentuseruid));
        /*await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioCall(
              currentuseruid: currentuseruid,
              call: call,
              channelName: call.channelId,
              role: _role,
            ),
          ),
        );*/
      }
    } else {
      if (callMade) {
        Get.to(VideoCall(call: call, currentuseruid: currentuseruid));
        /*await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCall(
              currentuseruid: currentuseruid,
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