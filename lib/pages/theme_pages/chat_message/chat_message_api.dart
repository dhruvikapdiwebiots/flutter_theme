import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

import '../../../config.dart';

class ChatMessageApi {
  //save message in user
  saveMessageInUserCollection(id, receiverId, newChatId, content, senderId,
      {isBlock = false, isBroadcast = false}) async {
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("chats")
        .where("chatId", isEqualTo: newChatId)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .collection("chats")
            .doc(value.docs[0].id)
            .update({
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content,
          "senderId": senderId,
          "chatId": newChatId,
          "isSeen": false,
          "isGroup": false,
          "isBlock": isBlock ?? false,
          "isOneToOne": true,
          "isBroadcast": isBroadcast,
          "blockBy": isBlock ? id : "",
          "blockUserId": isBlock ? receiverId : "",
          "receiverId": receiverId,
        }).then((value) {
          chatCtrl.textEditingController.text = "";
          chatCtrl.update();
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .collection("chats")
            .add({
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content,
          "senderId": senderId,
          "isSeen": false,
          "isGroup": false,
          "chatId": newChatId,
          "isBlock": isBlock ?? false,
          "isOneToOne": true,
          "isBroadcast": isBroadcast,
          "blockBy": isBlock ? id : "",
          "blockUserId": isBlock ? receiverId : "",
          "receiverId": receiverId,
        }).then((value) {
          chatCtrl.textEditingController.text = "";
          chatCtrl.update();
        });
      }
    }).then((value) {
      chatCtrl.isLoading = false;
      chatCtrl.update();
      Get.forceAppUpdate();
    });
  }

  //save group data
  saveGroupData(id, groupId, content, pData) async {
    var user = appCtrl.storage.read(session.user);
    List receiver = pData["users"];
    receiver.asMap().entries.forEach((element) async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(element.value["id"])
          .collection("chats")
          .where("groupId", isEqualTo: groupId)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection("users")
              .doc(element.value["id"])
              .collection("chats")
              .doc(value.docs[0].id)
              .update({
            "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "lastMessage": content,
            "senderId": user["id"],
          });
        }
      });
    });
  }

  //audio and video call api
  audioAndVideoCallApi({toData, isVideoCall}) async {
    var userData = appCtrl.storage.read(session.user);

    String channelId = Random().nextInt(1000).toString();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    Call call = Call(
        timestamp: timestamp,
        callerId: userData["id"],
        callerName: userData["name"],
        callerPic: userData["image"],
        receiverId: toData["id"],
        receiverName: toData["name"],
        receiverPic: toData["image"],
        callerToken: userData["pushToken"],
        receiverToken: toData["pushToken"],
        channelId: channelId,
        isVideoCall: isVideoCall);
    ClientRoleType role = ClientRoleType.clientRoleBroadcaster;


    FirebaseFirestore.instance
        .collection("calls")
        .doc(call.callerId).collection("calling")
        .add({
      "timestamp": timestamp,
      "callerId": userData["id"],
      "callerName": userData["name"],
      "callerPic": userData["image"],
      "receiverId": toData["id"],
      "receiverName": toData["name"],
      "receiverPic": toData["image"],
      "callerToken": userData["pushToken"],
      "receiverToken": toData["pushToken"],
      "hasDialled": true,
      "channelId": channelId,
      "isVideoCall": isVideoCall,
    }).then((value) async {
      print("ddssdf1");
      await FirebaseFirestore.instance
          .collection("calls")
          .doc(call.receiverId).collection("calling")
          .add({
        "timestamp": timestamp,
        "callerId": userData["id"],
        "callerName": userData["name"],
        "callerPic": userData["image"],
        "receiverId": toData["id"],
        "receiverName": toData["name"],
        "receiverPic": toData["image"],
        "callerToken": userData["pushToken"],
        "receiverToken": toData["pushToken"],
        "hasDialled": false,
        "channelId": channelId,
        "isVideoCall": isVideoCall
      }).then((value) {
        print("ddssdf");
        call.hasDialled = true;
        if (isVideoCall == false) {
          var data = {
            "channelName": call.channelId,
            "call": call,
            "role": role
          };
          Get.toNamed(routeName.audioCall, arguments: data);

          /*  await Navigator.push(
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
        } else {
          var data = {
            "channelName": call.channelId,
            "call": call,
            "role": role
          };
          print("object : $data");
          Get.toNamed(routeName.videoCall, arguments: data);

          /*  firebaseCtrl.sendNotification(
          title: "Incoming Video Call...",
          msg: "${call.callerName} video call",
          token: call.receiverToken,
          image: userData["image"]);*/
          /* await Navigator.push(
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
      });
    });
  }

  Future<bool> audioVideoCallSave(
      {required Call call,
      required bool? isVideoCall,
      required int timestamp}) async {
    try {
      print("hasDialledMap ");
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await FirebaseFirestore.instance
          .collection("calls")
          .doc(call.channelId)
          .set(hasDialledMap)
          .then((value) {
        print("ddssdf");
        FirebaseFirestore.instance
            .collection("calls")
            .doc(call.receiverId)
            .set(hasNotDialledMap)
            .then((value) => print("comple"));
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }
}
