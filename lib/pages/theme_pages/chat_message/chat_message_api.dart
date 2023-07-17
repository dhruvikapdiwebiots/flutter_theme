import 'dart:math';
import 'dart:developer' as log;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../config.dart';

class ChatMessageApi {
  Future saveMessage(newChatId, pId, encrypted,MessageType type,dateTime,senderId,
      {isBlock = false,
      isSeen = false,
      isBroadcast = false,
      blockBy = "",
      blockUserId = "" }) async {
    log.log("SAVE");
    dynamic userData = appCtrl.storage.read(session.user);
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(senderId)
        .collection(collectionName.messages)
        .doc(newChatId)
        .collection(collectionName.chat)
        .doc(dateTime)
        .set({
      'sender': userData["id"],
      'receiver': pId,
      'content': encrypted,
      "chatId": newChatId,
      'type': type.name,
      'messageType': "sender",
      "isBlock": isBlock,
      "isSeen": isSeen,
      "isBroadcast": isBroadcast,
      "blockBy": blockBy,
      "blockUserId": blockUserId,
      'timestamp': dateTime,
    }, SetOptions(merge: true));
  }

  //save message in user
  saveMessageInUserCollection(
      id, receiverId, newChatId, content, senderId, userName,
      {isBlock = false, isBroadcast = false}) async {
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(id)
        .collection(collectionName.chats)
        .where("chatId", isEqualTo: newChatId)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(id)
            .collection(collectionName.chats)
            .doc(value.docs[0].id)
            .update({
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content,
          "senderId": senderId,
          "chatId": newChatId,
          "isSeen": false,
          "isGroup": false,
          "name": userName,
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
            .collection(collectionName.users)
            .doc(id)
            .collection(collectionName.chats)
            .add({
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content,
          "senderId": senderId,
          "isSeen": false,
          "isGroup": false,
          "chatId": newChatId,
          "isBlock": isBlock ?? false,
          "isOneToOne": true,
          "name": userName,
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
  saveGroupData(
    id,
    groupId,
    content,
    pData,
  ) async {
    var user = appCtrl.storage.read(session.user);
    List receiver = pData["groupData"]["users"];
    receiver.asMap().entries.forEach((element) async {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(element.value["id"])
          .collection(collectionName.chats)
          .where("groupId", isEqualTo: groupId)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(element.value["id"])
              .collection(collectionName.chats)
              .doc(value.docs[0].id)
              .update({
            "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "lastMessage": content,
            "senderId": user["id"],
            "name": pData["groupData"]["name"]
          });
          if (user["id"] != element.value["id"]) {
            FirebaseFirestore.instance
                .collection(collectionName.users)
                .doc(element.value["id"])
                .get()
                .then((snap) {
              if (snap.data()!["pushToken"] != "") {
                firebaseCtrl.sendNotification(
                    title: "Group Message",
                    msg: content,
                    groupId: groupId,
                    token: snap.data()!["pushToken"],
                    dataTitle: pData["groupData"]["name"]);
              }
            });
          }
        }
      });
    });
  }

  //audio and video call api
  audioAndVideoCallApi({toData, isVideoCall}) async {
    try {
      dynamic agoraToken = appCtrl.storage.read(session.agoraToken);
      log.log("agoraToken : $agoraToken");
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
          isVideoCall: isVideoCall,
          receiver: null);
      ClientRoleType role = ClientRoleType.clientRoleBroadcaster;
      await FirebaseFirestore.instance
          .collection(collectionName.calls)
          .doc(call.callerId)
          .collection(collectionName.calling)
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
        await FirebaseFirestore.instance
            .collection(collectionName.calls)
            .doc(call.receiverId)
            .collection(collectionName.calling)
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
        }).then((value) async {
          call.hasDialled = true;
          if (isVideoCall == false) {
            firebaseCtrl.sendNotification(
                title: "Incoming Audio Call...",
                msg: "${call.callerName} audio call",
                token: call.receiverToken,
                pName: call.callerName,
                image: userData["image"],
                dataTitle: call.callerName);
            var data = {
              "channelName": call.channelId,
              "call": call,
              "role": role
            };
            Get.toNamed(routeName.audioCall, arguments: data);
          } else {
            firebaseCtrl.sendNotification(
                title: "Incoming Video Call...",
                msg: "${call.callerName} video call",
                token: call.receiverToken,
                pName: call.callerName,
                image: userData["image"],
                dataTitle: call.callerName);

            var data = {
              "channelName": call.channelId,
              "call": call,
              "role": role
            };

            Get.toNamed(routeName.videoCall, arguments: data);
          }
        });
      });
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      log.log("Failed with error '${e.code}': ${e.message}");
    }
  }

  getMessageAsPerDate(snapshot){
    final chatCtrl = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController());
    List<QueryDocumentSnapshot<Object?>> message =
        (snapshot.data!).docs;
    message.asMap().entries.forEach((element) {

      if (getDate(element.value.id) == "today") {
        List<QueryDocumentSnapshot<Object?>> newMessageList = [];
        bool isExist = chatCtrl.message
            .where((element) => element["title"] == "today")
            .isNotEmpty;

        if (isExist) {
          if(!newMessageList.contains(element.value)) {
            newMessageList.add(element.value);
            int index = chatCtrl.message.indexWhere(
                    (element) =>
                element["title"] == "today");
            chatCtrl.message[index]["message"] =
                newMessageList;
          }
        } else {
          if(!newMessageList.contains(element.value)) {
            newMessageList.add(element.value);
            var data = {
              "title": getDate(element.value.id),
              "message": newMessageList
            };

            chatCtrl.message = [data];
          }

        }
      }
      if (getDate(element.value.id) == "yesterday") {
        List<QueryDocumentSnapshot<Object?>> newMessageList = [];
        bool isExist = chatCtrl.message
            .where((element) => element["title"] == "yesterday")
            .isNotEmpty;

        if (isExist) {
          if(!newMessageList.contains(element.value)) {
            newMessageList.add(element.value);
            int index = chatCtrl.message.indexWhere(
                    (element) =>
                element["title"] == "yesterday");
            chatCtrl.message[index]["message"] =
                newMessageList;
          }
        } else {
          if(!newMessageList.contains(element.value)) {
            newMessageList.add(element.value);
            var data = {
              "title": getDate(element.value.id),
              "message": newMessageList
            };

            if(chatCtrl.message.isNotEmpty){
              chatCtrl.message.add(data);
            }else {
              chatCtrl.message = [data];
            }
          }
        }
      }
      if(getDate(element.value.id) != "yesterday" && getDate(element.value.id) != "today"){
        List<QueryDocumentSnapshot<Object?>> newMessageList = [];
        bool isExist = chatCtrl.message
            .where((element) => element["title"].contains("-other"))
            .isNotEmpty;

        if (isExist) {
          if(!newMessageList.contains(element.value)) {
            newMessageList.add(element.value);
            int index = chatCtrl.message.indexWhere(
                    (element) =>
                element["title"].contains("-other"));
            chatCtrl.message[index]["message"] =
                newMessageList;
          }
        } else {
          if(!newMessageList.contains(element.value)) {
            newMessageList.add(element.value);
            var data = {
              "title": getWhen(element.value.id),
              "message": newMessageList
            };

            if(chatCtrl.message.isNotEmpty){
              chatCtrl.message.add(data);
            }else {
              chatCtrl.message = [data];
            }
          }
        }
      }
    });

  }
}
