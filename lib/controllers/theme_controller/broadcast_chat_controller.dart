import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/broadcast_chat/layouts/broadcast_sender.dart';
import 'package:flutter_theme/pages/theme_pages/chat_message/chat_message_api.dart';
import 'package:permission_handler/permission_handler.dart';

class BroadcastChatController extends GetxController {
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
  dynamic message, userData, broadData;
  List pData = [];
  bool positionStreamStarted = false;
  bool isUserAvailable = true;
  XFile? imageFile;
  XFile? videoFile;
  File? image;
  int totalUser = 0;
  String nameList = "";
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
    userData = appCtrl.storage.read(session.user);
    var data = Get.arguments;

    broadData = data["data"];
    pId = data["broadcastId"];
    pData = broadData["receiverId"];
    totalUser = pData.length;

    for (var i = 0; i < pData.length; i++) {
      if (nameList != "") {
        nameList = "$nameList, ${pData[i]["name"]}";
      } else {
        nameList = pData[i]["name"];
      }
    }
    update();

    super.onReady();
  }

  //update typing status
  setTyping() async {
    firebaseCtrl.setIsActive();
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
            '${contact.displayName}-BREAK-${contact.phones[0].number}-BREAK-${contact.photo!}',
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
      for (var i = 0; i < pData.length; i++) {
        if (pData[i]["chatId"] != null) {
          await FirebaseFirestore.instance
              .collection('messages')
              .doc(pData[i]["chatId"])
              .collection("chat")
              .add({
            'sender': userData["id"],
            'receiver': pData[i],
            'content': content,
            "chatId": pData[i]["chatId"],
            'type': type.name,
            'messageType': "sender",
            "isBlock": false,
            "isSeen": false,
            "blockBy": "",
            "blockUserId": "",
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          }).then((snap) async {

            await ChatMessageApi().saveMessageInUserCollection(
                pData[i]["id"], userData["id"], pData[i]["chatId"], content,isBroadcast: true,userData["id"]);
          });
        } else {
          final now = DateTime.now();
          String? newChatId = now.microsecondsSinceEpoch.toString();
          update();
          pData[i]["chatId"] = newChatId;
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
            "isBroadcast": false,
            "blockBy": "",
            "blockUserId": "",
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          }).then((snap) async {
            await ChatMessageApi().saveMessageInUserCollection(
                pData[i]["id"], userData["id"], pData[i]["chatId"], content,isBroadcast: true,userData["id"]);
          });
        }
      }

      FirebaseFirestore.instance
          .collection("broadcast")
          .doc(pId)
          .update({"users": pData});

      FirebaseFirestore.instance
          .collection('users')
          .doc(userData["id"])
          .collection("chats")
          .where("broadcastId", isEqualTo: pId)
          .get()
          .then((snap) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userData["id"])
            .collection("chats")
            .doc(snap.docs[0].id)
            .update({
          "receiverId": pData,
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content
        });
      });

      FirebaseFirestore.instance
          .collection('broadcastMessage')
          .doc(pId)
          .collection("chat")
          .add({
        'sender': userData["id"],
        'senderName': userData["name"],
        'receiver': pData,
        'content': content,
        "broadcastId": pId,
        'type': type.name,
        'messageType': "sender",
        "status": "",
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userData["id"])
            .collection("chats")
            .where("broadcastId", isEqualTo: pId)
            .get();
      });

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
      return BroadcastSender(
        document: document,
        index: index,
      );
    } else {
      // RECEIVER MESSAGE
      return Container();
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
