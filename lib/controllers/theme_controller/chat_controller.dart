import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/contact_model.dart';
import 'package:flutter_theme/pages/theme_pages/chat_message/chat_message_api.dart';
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
  dynamic pData,allData, userData;
  UserContactModel? userContactModel;
  bool positionStreamStarted = false;
  bool isUserAvailable = true;
  XFile? imageFile;
  XFile? videoFile;
  String? audioFile;
  File? image;
  File? video;
  bool isLoading = true;
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
      userContactModel = data["data"];
      pId = userContactModel!.uid;
      pName = userContactModel!.username;
      chatId = data["chatId"];
      isUserAvailable = true;
      update();
    }
    update();
    getChatData();

    super.onReady();
  }

  //get chat data
  getChatData() async {
    if (chatId != "0") {
      await FirebaseFirestore.instance
          .collection("users").doc(userData["id"]).collection("chats").where("chatId",isEqualTo: chatId)
          .get()
          .then((value) {
        allData = value.docs[0].data();

        update();
        seenMessage();
      });
    }
    await FirebaseFirestore.instance
        .collection("users").doc(userContactModel!.uid)
        .get()
        .then((value) {
      pData = value.data();
      update();
    });

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

  //seen all message
  seenMessage() async {
    if(allData != null ) {
      if (userData["id"] == allData["id"]) {
        await FirebaseFirestore.instance
            .collection("messages")
            .doc(chatId)
            .collection("chat")
            .where("isSeen", isEqualTo: false)
            .get()
            .then((value) {
          for (var i = 0; i < value.docs.length; i++) {
            FirebaseFirestore.instance
                .collection("messages")
                .doc(chatId)
                .collection("chat")
                .doc(value.docs[i].id)
                .update({"isSeen": true});
          }
        });
      }
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

      log("fileName : $fileName");
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
      await FirebaseFirestore.instance
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

      await FirebaseFirestore.instance
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
        imageFile = null;
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
    }).then((value) {
      videoFile = null;
      pickerCtrl.videoFile = null;

      pickerCtrl.video = null;
      videoUrl = "";
      update();
      pickerCtrl.update();
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
            '${contact.displayName}-BREAK-${contact.phones[0].number}-BREAK-${contact.photo}',
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
      backgroundColor: appCtrl.appTheme.transparentColor,
      builder: (BuildContext bc) {
        return Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: appCtrl.appTheme.whiteColor,
                borderRadius: BorderRadius.circular(10)),
            child: AudioRecordingPlugin(type: type, index: index));
      },
    ).then((value) async {
      File file = File(value);
      String fileName =
          "${file.name}-${DateTime.now().millisecondsSinceEpoch.toString()}";

      audioFile = await pickerCtrl.uploadAudio(file, fileNameText: fileName);

      onSendMessage(audioFile!, MessageType.audio);
    });
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, MessageType type) async {
    isLoading = true;
    update();
    if (content.trim() != '') {
      textEditingController.clear();
      final now = DateTime.now();
      String? newChatId =
          chatId == "0" ? now.microsecondsSinceEpoch.toString() : chatId;
      chatId = newChatId;
      update();
      imageUrl = "";
      videoUrl = "";
      audioFile = "";
      update();
      if(pData["pushToken"] != "" && pData["pushToken"] != null) {
        firebaseCtrl.sendNotification(title: "$pName • $content",
            msg: content,
            token: pData["pushToken"]);
      }
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(newChatId)
          .collection("chat")
          .add({
        'sender': userData["id"],
        'receiver': pData["id"],
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
        isLoading = false;
        update();
        Get.forceAppUpdate();
        await ChatMessageApi().saveMessageInUserCollection(userData["id"], pData["id"], newChatId, content);
        await ChatMessageApi().saveMessageInUserCollection(pData["id"], userData["id"], newChatId, content);
      }).then((value) {
        isLoading = false;
        update();
        Get.forceAppUpdate();
      });
      Get.forceAppUpdate();
    }
    isLoading = false;
    update();
    Get.forceAppUpdate();
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
