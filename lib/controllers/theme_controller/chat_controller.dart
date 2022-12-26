import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatController extends GetxController {
  String? pId,
      id,
      chatId,
      pName,
      groupId,
      imageUrl,
      peerNo,
      status,
      statusLastSeen,
      videoUrl,
      blockBy;
  dynamic message;
  dynamic pData, allData, userData;
  bool positionStreamStarted = false;
  bool isUserAvailable = true;
  XFile? imageFile;
  XFile? videoFile;
  File? image;
  File? video;
  bool? isLoading = true;
  bool typing = false, isBlock = false;
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());
  TextEditingController textEditingController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void onReady() {
    // TODO: implement onReady
    groupId = '';
    isLoading = false;
    imageUrl = '';
    userData = appCtrl.storage.read("user");
    var data = Get.arguments;
    if (data == "No User") {
      isUserAvailable = false;
    } else {
      pData = data["data"];
      allData = data["allData"];
      isBlock = allData.data()["isBlock"] ?? false;
      blockBy = allData.data()["blockBy"] ?? "";
      pId = pData["id"];
      pName = pData["name"];
      chatId = data["chatId"];
      isUserAvailable = true;
      print("pData : $pData");
      update();
    }
    update();
    seenMessage();
    super.onReady();
  }

  //update typing status
  setTyping() async {
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty) {
        firebaseCtrl.setTyping();
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        firebaseCtrl.setIsActive();
        typing = false;
      }
    });
  }

  seenMessage() async {

    if(userData["phone"] != pData["senderPhone"]) {
      FirebaseFirestore.instance
          .collection("messages")
          .doc(pId)
          .collection("chat")
          .where("isSeen", isEqualTo: false)
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          FirebaseFirestore.instance
              .collection("messages")
              .doc(pId)
              .collection("chat").doc(value.docs[i].id).update(
              {"isSeen": true});
        }
      });
    }
  }

  //share document
  documentShare() async {
    pickerCtrl.dismissKeyboard();
    Get.back();
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path.toString());
      String fileName =
          "${file.name}-${DateTime.now().millisecondsSinceEpoch.toString()}";

      imageUrl = await pickerCtrl.uploadImage(file, fileNameText: fileName);
      onSendMessage(
          "${result.files.single.name}-BREAK-$imageUrl",
          result.files.single.path.toString().contains(".mp4")
              ? MessageType.video
              : result.files.single.path.toString().contains(".mp3")
                  ? MessageType.audio
                  : MessageType.doc);
    }
  }

  //location share
  locationShare() async {
    pickerCtrl.dismissKeyboard();
    Get.back();

    await permissionHandelCtrl.getCurrentPosition().then((value) async {
      var locationString =
          'https://www.google.com/maps/search/?api=1&query=${value!.latitude},${value.longitude}';
      onSendMessage(locationString, MessageType.location);
      return null;
    });
  }

  //share media
  shareMedia(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.r25))),
        builder: (BuildContext context) {
          // return your layout

          return const FileBottomSheet();
        });
  }

  //block user
  blockUser() async {
    DateTime now = DateTime.now();
    String? newChatId =
        chatId == "0" ? now.microsecondsSinceEpoch.toString() : chatId;
    chatId = newChatId;
    update();
    if (isBlock) {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(newChatId)
          .collection("chat")
          .add({
        'sender': userData["id"],
        'receiver': pId,
        'content': "You unblock this contact",
        "chatId": newChatId,
        'type': MessageType.messageType.name,
        "isBlock": true,
        "blockBy": userData["id"],
        "blockUserId": pId,
        'messageType': "sender",
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      final msgList = await FirebaseFirestore.instance
          .collection("contacts")
          .where("chatId", isEqualTo: newChatId)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('contacts')
              .doc(value.docs[0].id)
              .update({
            "senderPhone": userData['phone'],
            'sender': {
              "id": userData['id'],
              "name": userData['name'],
              "image": userData["image"],
              "phone": userData["phone"]
            },
            "receiverPhone": pData["phone"],
            "receiver": {
              "id": pId,
              "name": pName,
              "image": pData["image"],
              "phone": pData["phone"]
            },
            "isBlock": false,
            "blockBy": "",
            "blockUserId": ""
          }).then((value) {
            FirebaseFirestore.instance
                .collection("contacts")
                .where("chatId", isEqualTo: newChatId)
                .get()
                .then((value) {
              allData = value.docs[0];
              update();
              Get.forceAppUpdate();
              log("alll : ${value.docs[0].data()}");
            });
          });

          listScrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    } else {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(newChatId)
          .collection("chat")
          .add({
        'sender': userData["id"],
        'receiver': pId,
        'content': "You block this contact",
        "chatId": newChatId,
        'type': MessageType.messageType.name,
        "isBlock": true,
        "blockBy": userData["id"],
        "blockUserId": pId,
        'messageType': "sender",
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      final msgList = await FirebaseFirestore.instance
          .collection("contacts")
          .where("chatId", isEqualTo: newChatId)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FirebaseFirestore.instance
              .collection('contacts')
              .doc(value.docs[0].id)
              .update({
            "senderPhone": userData['phone'],
            'sender': {
              "id": userData['id'],
              "name": userData['name'],
              "image": userData["image"],
              "phone": userData["phone"]
            },
            "receiverPhone": pData["phone"],
            "receiver": {
              "id": pId,
              "name": pName,
              "image": pData["image"],
              "phone": pData["phone"]
            },
            "isBlock": true,
            "blockBy": userData["id"],
            "blockUserId": pId
          }).then((value) {
            FirebaseFirestore.instance
                .collection("contacts")
                .where("chatId", isEqualTo: newChatId)
                .get()
                .then((value) {
              allData = value.docs[0];
              update();
              Get.forceAppUpdate();
              log("alll : ${value.docs[0].data()}");
            });
          });

          listScrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    var file = File(imageFile!.path);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;
        isLoading = false;
        onSendMessage(imageUrl!, MessageType.image);
        update();
      }, onError: (err) {
        isLoading = false;
        update();
        Fluttertoast.showToast(msg: 'Image is Not Valid');
      });
    });
  }

  //send video after recording or pick from media
  videoSend() async {
    await pickerCtrl.videoPickerOption(Get.context!);
    videoFile = pickerCtrl.videoFile;
    update();
    const Duration(seconds: 2);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    var file = File(videoFile!.path);
    UploadTask uploadTask = reference.putFile(file);

    uploadTask.then((res) {
      res.ref.getDownloadURL().then((downloadUrl) {
        videoUrl = downloadUrl;
        isLoading = false;
        onSendMessage(videoUrl!, MessageType.video);
        update();
      }, onError: (err) {
        isLoading = false;
        update();
        Fluttertoast.showToast(msg: 'Image is Not Valid');
      });
    });
  }

  //pick up contact and share
  saveContactInChat() async {
    PermissionStatus permissionStatus =
        await permissionHandelCtrl.getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Get.toNamed(routeName.contactList)!.then((value) async {
        Contact contact = value;
        onSendMessage(
            '${contact.displayName}-BREAK-${contact.phones![0].value}-BREAK-${contact.avatar!}',
            MessageType.contact);
      });
    } else {
      permissionHandelCtrl.handleInvalidPermissions(permissionStatus);
    }
    update();
  }

  //audio recording
  void audioRecording(BuildContext context, String type, int index) {
    showModalBottomSheet(
      context: Get.context!,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: AudioRecordingPlugin(type: type, index: index));
      },
    );
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, MessageType type) async {
    if (content.trim() != '') {
      textEditingController.clear();
      final now = DateTime.now();
      String? newChatId =
          chatId == "0" ? now.microsecondsSinceEpoch.toString() : chatId;
      chatId = newChatId;
      update();
      if (allData.data()["isBlock"] != null) {
        if (allData.data()["isBlock"] == true) {
          if (allData.data()["blockBy"] == userData["id"]) {
            await unblockConfirmation(
                pName, allData.data()["isBlock"], chatId, pId);
            allData.data()["isBlock"] = false;
            allData.data()["blockBy"] = "";
            allData.data()["blockUserId"] = "";
            update();
          } else {
            await FirebaseFirestore.instance
                .collection('messages')
                .doc(newChatId)
                .collection("chat")
                .add({
              'sender': userData["id"],
              'receiver': pId,
              'content': content,
              "chatId": newChatId,
              'type': type.name,
              'messageType': "sender",
              "isBlock": true,
              "blockBy": allData.data()["blockBy"],
              "blockUserId": allData.data()["blockUserId"],
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            }).then((snap) async {
              await FirebaseFirestore.instance
                  .collection("contacts")
                  .where("chatId", isEqualTo: newChatId)
                  .get()
                  .then((value) async {
                if (value.docs.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('contacts')
                      .doc(value.docs[0].id)
                      .update({
                    "updateStamp":
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    "senderPhone": userData['phone'],
                    'sender': {
                      "id": userData['id'],
                      "name": userData['name'],
                      "image": userData["image"],
                      "phone": userData["phone"]
                    },
                    "blockUserMessage": content,
                    "receiverPhone": pData["phone"],
                    "receiver": {
                      "id": pId,
                      "name": pName,
                      "image": pData["image"],
                      "phone": pData["phone"]
                    }
                  }).then((value) {
                    textEditingController.text = "";
                    update();
                  });
                } else {
                  FirebaseFirestore.instance.collection('contacts').add({
                    'sender': {
                      "id": userData["id"],
                      "name": userData["name"],
                      "image": userData["image"],
                      "phone": userData["phone"]
                    },
                    'receiver': {
                      "id": pId,
                      "name": pName,
                      "image": pData["image"],
                      "phone": pData["phone"]
                    },
                    "blockUserMessage": content,
                    'receiverPhone': pData["phone"],
                    "senderPhone": userData['phone'],
                    'chatId': newChatId,
                    'timestamp':
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    "lastMessage": content,
                    "isGroup": false,
                    "isBlock": true,
                    "isBroadcast": false,
                    "blockBy": allData.data()["blockBy"],
                    "blockUserId": allData.data()["blockUserId"],
                    "groupId": "",
                    "updateStamp":
                        DateTime.now().millisecondsSinceEpoch.toString()
                  });
                }
              });
            });
          }
        } else {
          await FirebaseFirestore.instance
              .collection('messages')
              .doc(newChatId)
              .collection("chat")
              .add({
            'sender': userData["id"],
            'receiver': pId,
            'content': content,
            "chatId": newChatId,
            'type': type.name,
            'messageType': "sender",
            "isBlock": false,
            "blockBy": "",
            "blockUserId": "",
            "isSeen": false,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          }).then((snap) async {
            await FirebaseFirestore.instance
                .collection("contacts")
                .where("chatId", isEqualTo: newChatId)
                .get()
                .then((value) async {
              if (value.docs.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('contacts')
                    .doc(value.docs[0].id)
                    .update({
                  "updateStamp":
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  "lastMessage": content,
                  "senderPhone": userData['phone'],
                  'sender': {
                    "id": userData['id'],
                    "name": userData['name'],
                    "image": userData["image"],
                    "phone": userData["phone"]
                  },
                  "isGroup": false,
                  "isBlock": false,
                  "isBroadcast": false,
                  "blockBy": "",
                  "isSeen": false,
                  "blockUserId": "",
                  "receiverPhone": pData["phone"],
                  "receiver": {
                    "id": pId,
                    "name": pName,
                    "image": pData["image"],
                    "phone": pData["phone"]
                  }
                }).then((value) {
                  textEditingController.text = "";
                  update();
                });
              } else {
                FirebaseFirestore.instance.collection('contacts').add({
                  'sender': {
                    "id": userData["id"],
                    "name": userData["name"],
                    "image": userData["image"],
                    "phone": userData["phone"]
                  },
                  'receiver': {
                    "id": pId,
                    "name": pName,
                    "image": pData["image"],
                    "phone": pData["phone"]
                  },
                  'receiverPhone': pData["phone"],
                  "senderPhone": userData['phone'],
                  'chatId': newChatId,
                  'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                  "lastMessage": content,
                  "isGroup": false,
                  "isSeen": false,
                  "isBlock": false,
                  "isBroadcast": false,
                  "blockBy": "",
                  "blockUserId": "",
                  "groupId": "",
                  "updateStamp":
                      DateTime.now().millisecondsSinceEpoch.toString()
                });
              }
            });
          });
        }
      } else {
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(newChatId)
            .collection("chat")
            .add({
          'sender': userData["id"],
          'receiver': pId,
          'content': content,
          "chatId": newChatId,
          'type': type.name,
          'messageType': "sender",
          "isBlock": false,
          "isSeen": false,
          "blockBy": "",
          "blockUserId": "",
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        }).then((snap) async {
          await FirebaseFirestore.instance
              .collection("contacts")
              .where("chatId", isEqualTo: newChatId)
              .get()
              .then((value) async {
            if (value.docs.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('contacts')
                  .doc(value.docs[0].id)
                  .update({
                "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
                "lastMessage": content,
                "senderPhone": userData['phone'],
                "isSeen": false,
                'sender': {
                  "id": userData['id'],
                  "name": userData['name'],
                  "image": userData["image"],
                  "phone": userData["phone"]
                },
                "isGroup": false,
                "isBlock": false,
                "isBroadcast": false,
                "blockBy": "",
                "blockUserId": "",
                "receiverPhone": pData["phone"],
                "receiver": {
                  "id": pId,
                  "name": pName,
                  "image": pData["image"],
                  "phone": pData["phone"]
                }
              }).then((value) {
                textEditingController.text = "";
                update();
              });
            } else {
              dynamic user = appCtrl.storage.read("user");

              FirebaseFirestore.instance.collection('contacts').add({
                'sender': {
                  "id": user["id"],
                  "name": user["name"],
                  "image": user["image"],
                  "phone": user["phone"]
                },
                "isSeen": false,
                'receiver': {
                  "id": pId,
                  "name": pName,
                  "image": pData["image"],
                  "phone": pData["phone"]
                },
                'receiverPhone': pData["phone"],
                "senderPhone": user['phone'],
                'chatId': newChatId,
                'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                "lastMessage": content,
                "isGroup": false,
                "isBlock": false,
                "isBroadcast": false,
                "blockBy": "",
                "blockUserId": "",
                "groupId": "",
                "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
              });
            }
          });
        });
      }
      Get.forceAppUpdate();
    }
  }

  //delete chat layout
  Widget buildPopupDialog(
      BuildContext context, DocumentSnapshot documentReference) {
    return DeleteAlert(
      documentReference: documentReference,
    );
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN
  Widget buildItem(int index, document) {
    if (document['sender'] == userData["id"]) {
      return SenderMessage(
        document: document,
        index: index,
      );
    } else {
      // RECEIVER MESSAGE
      return document["type"] == MessageType.messageType.name
          ? Container()
          : document["isBlock"]
              ? Container()
              : ReceiverMessage(document: document, index: index);
    }
  }

  // ON BACK PRESS
  Future<bool> onBackPress() {
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(userData["id"])
        .update({'status': "Online"});
    Get.back();
    return Future.value(false);
  }
}
