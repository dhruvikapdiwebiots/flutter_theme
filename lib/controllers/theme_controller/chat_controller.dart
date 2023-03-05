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
  UserContactModel? userContactModel;
  bool positionStreamStarted = false;
  bool isUserAvailable = true;
  XFile? imageFile;
  XFile? videoFile;
  String? audioFile;
  String selectedImage = "";
  final picker = ImagePicker();
  File? selectedFile;
  File? image;
  File? video;
  bool isLoading = false;
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
    userData = appCtrl.storage.read(session.user);
    var data = Get.arguments;
    log("data : $data");
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
    log("chatId : $chatId");
    if (chatId != "0") {
      seenMessage();
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userData["id"])
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get()
          .then((value) {
        log("allData : ${value.docs}");
        update();
        seenMessage();
      });
    }
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(pId)
        .get()
        .then((value) {
      pData = value.data();

      update();
      log("get L : $pData");
    });
  }

  //audio and video call tap
  audioVideoCallTap(isVideoCall) async {
    log("pData : $pData");

    await ChatMessageApi()
        .audioAndVideoCallApi(toData: pData, isVideoCall: isVideoCall);

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
    await FirebaseFirestore.instance
        .collection(collectionName.messages)
        .doc(chatId)
        .collection(collectionName.chat)
        .where("sender", isEqualTo: userData["id"])
        .get()
        .then((value) {
          value.docs.asMap().entries.forEach((element) {
            FirebaseFirestore.instance
                .collection(collectionName.messages)
                .doc(chatId)
                .collection(collectionName.chat)
                .doc(element.value.id)
                .update({"isSeen": true});
          });

    });

    FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(userData["id"])
        .collection(collectionName.chats)
        .where("chatId", isEqualTo: chatId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(userData["id"])
            .collection(collectionName.chats)
            .doc(value.docs[0].id)
            .update({"isSeen": true});
      }
    });

    FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(pId)
        .collection(collectionName.chats)
        .where("chatId", isEqualTo: chatId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(pId)
            .collection(collectionName.chats)
            .doc(value.docs[0].id)
            .update({"isSeen": true});
      }
    });
  }

  //share document
  documentShare() async {
    pickerCtrl.dismissKeyboard();
    Get.back();

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      isLoading = true;
      update();
      Get.forceAppUpdate();
      File file = File(result.files.single.path.toString());
      String fileName =
          "${file.name}-${DateTime.now().millisecondsSinceEpoch.toString()}";
      log("file : $file");
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();
      isLoading = true;
      update();
      log("fileName : $downloadUrl");
      onSendMessage(
          "${result.files.single.name}-BREAK-$downloadUrl",
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
      log("value : $value");
      var locationString =
          'https://www.google.com/maps/search/?api=1&query=${value!.latitude},${value.longitude}';
      onSendMessage(locationString, MessageType.location);
      return null;
    });
  }

  //share media
  shareMedia(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: appCtrl.appTheme.transparentColor,
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
          .collection(collectionName.messages)
          .doc(newChatId)
          .collection(collectionName.chat)
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
      await ChatMessageApi().saveMessageInUserCollection(
          userData["id"],
          pId,
          newChatId,
          "You unblock this contact",
          isBlock: true,
          userData["id"]);
    } else {
      FirebaseFirestore.instance
          .collection(collectionName.messages)
          .doc(newChatId)
          .collection(collectionName.chat)
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

      await ChatMessageApi().saveMessageInUserCollection(
          userData["id"],
          pData["id"],
          newChatId,
          "You block this contact",
          isBlock: true,
          userData["id"]);
    }
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    imageFile = pickerCtrl.imageFile;
    update();
    log("chat_con : $imageFile");
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    var file = File(imageFile!.path);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((downloadUrl) {
        imageUrl = downloadUrl;
        imageFile = null;
        isLoading = false;
        log("imageUrl : $imageUrl");
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
    update();
    videoFile = pickerCtrl.videoFile;
    update();
    log("videoFile : $videoFile");
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
      Get.toNamed(routeName.allContactList)!.then((value) async {
        if (value != null) {
          Contact contact = value;
          log("ccc : $contact");
          isLoading = true;
          update();
          onSendMessage(
              '${contact.displayName}-BREAK-${contact.phones[0].number}-BREAK-${contact.photo}',
              MessageType.contact);
        }
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
      log("file : $file");
      String fileName =
          "${file.name}-${DateTime.now().millisecondsSinceEpoch.toString()}";
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();
      log("audioFile : $downloadUrl");
      onSendMessage(downloadUrl, MessageType.audio);
      log("audioFile : $downloadUrl");
    });
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, MessageType type) async {
    log("allData : $allData");
    isLoading = true;
    update();
    Get.forceAppUpdate();
    log("check for send ");
    if (content.trim() != '') {
      textEditingController.clear();
      final now = DateTime.now();
      String? newChatId =
          chatId == "0" ? now.microsecondsSinceEpoch.toString() : chatId;
      chatId = newChatId;
      update();
      imageUrl = "";
      log("chatId : $chatId");
      update();

      if (allData != null && allData != "") {
        if (allData["isBlock"] == true) {
          if (allData["blockUserId"] == pId) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
                SnackBar(content: Text(fonts.unblockUser(pName))));
          } else {
            await FirebaseFirestore.instance
                .collection(collectionName.messages)
                .doc(newChatId)
                .collection(collectionName.chat)
                .add({
              'sender': userData["id"],
              'receiver': pData["id"],
              'content': content,
              "chatId": newChatId,
              'type': type.name,
              'messageType': "sender",
              "isBlock": false,
              "isSeen": false,
              "isBroadcast": false,
              "blockBy": "",
              "blockUserId": "",
              'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            }).then((snap) async {
              isLoading = false;
              update();
              Get.forceAppUpdate();
              await ChatMessageApi().saveMessageInUserCollection(pData["id"],
                  userData["id"], newChatId, content, userData["id"]);
            }).then((value) {
              isLoading = false;
              update();
              Get.forceAppUpdate();
            });
          }
          isLoading = false;
          update();
        } else {
          await FirebaseFirestore.instance
              .collection(collectionName.messages)
              .doc(newChatId)
              .collection(collectionName.chat)
              .add({
            'sender': userData["id"],
            'receiver': pId,
            'content': content,
            "chatId": newChatId,
            'type': type.name,
            'messageType': "sender",
            "isBlock": false,
            "isSeen": false,
            "isBroadcast": false,
            "blockBy": "",
            "blockUserId": "",
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          }).then((snap) async {
            isLoading = false;
            update();
            Get.forceAppUpdate();
            await ChatMessageApi().saveMessageInUserCollection(
                userData["id"], pId, newChatId, content, userData["id"]);
            await ChatMessageApi().saveMessageInUserCollection(
                pId, pId, newChatId, content, userData["id"]);
          }).then((value) {
            isLoading = false;
            update();
            Get.forceAppUpdate();
          });
        }
        isLoading = false;
        update();
        Get.forceAppUpdate();
      } else {
        log("message se");
        isLoading = false;
        update();

        await FirebaseFirestore.instance
            .collection(collectionName.messages)
            .doc(newChatId)
            .collection(collectionName.chat)
            .add({
          'sender': userData["id"],
          'receiver': pId,
          'content': content,
          "chatId": newChatId,
          'type': type.name,
          'messageType': "sender",
          "isBlock": false,
          "isSeen": false,
          "isBroadcast": false,
          "blockBy": "",
          "blockUserId": "",
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        }).then((snap) async {
          isLoading = false;
          update();
          Get.forceAppUpdate();
          log("check");
          await ChatMessageApi().saveMessageInUserCollection(
              userData["id"], pId, newChatId, content, userData["id"]);
          await ChatMessageApi().saveMessageInUserCollection(
              pId, pId, newChatId, content, userData["id"]);
        }).then((value) {
          isLoading = false;
          update();
          Get.forceAppUpdate();
          getChatData();
        });
      }
    }
    if (pData["pushToken"] != "") {
      firebaseCtrl.sendNotification(
          title: "Single Message",
          msg: content,
          chatId: chatId,
          token: pData["pushToken"],
          pId: pId,
          pName: pName,
          userContactModel: userContactModel,
          image: userData["image"],
          dataTitle: pName);
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
