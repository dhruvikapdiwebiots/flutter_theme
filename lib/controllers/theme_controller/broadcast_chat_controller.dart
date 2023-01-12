import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/broadcast_chat/layouts/broadcast_file_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
  List pData = [];
  List newpData = [];
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

          return const BroadcastFileRowList();
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
    log("pData : ${pData.length}");
    if (content.trim() != '') {
      textEditingController.clear();
      await saveMessageInLoop(content, type);
      await Future.delayed(Durations.s4);
      log("newpData : $newpData");


      await FirebaseFirestore.instance
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
          "receiverId": newpData,
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
        'receiver': newpData,
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

  saveMessageInLoop(String content, MessageType type) async {
    pData.asMap().entries.forEach((element) async {
      log("cha : ${element.value["chatId"]}");
      if (element.value["chatId"] != null) {
        newpData.add(element.value);
        update();
        await FirebaseFirestore.instance
            .collection("messages")
            .doc(element.value["chatId"])
            .collection("chat")
            .add({
          'sender': userData["id"],
          'receiver': element.value["id"],
          'content': content,
          "chatId": element.value["chatId"],
          'type': type.name,
          'messageType': "sender",
          "isBlock": false,
          "isSeen": false,
          "isBroadcast": true,
          "blockBy": "",
          "blockUserId": "",
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        }).then((value) async {
          await ChatMessageApi().saveMessageInUserCollection(
              element.value["id"],
              element.value["id"],
              element.value["chatId"],
              content,
              isBroadcast: true,
              userData["id"]);
        });
      } else {
        final now = DateTime.now();
        String? newChatId = now.microsecondsSinceEpoch.toString();
        update();
        element.value["chatId"] = newChatId;
        await FirebaseFirestore.instance
            .collection("messages")
            .doc(element.value["chatId"])
            .collection("chat")
            .add({
          'sender': userData["id"],
          'receiver': element.value["id"],
          'content': content,
          "chatId": element.value["chatId"],
          'type': type.name,
          'messageType': "sender",
          "isBlock": false,
          "isSeen": false,
          "isBroadcast": true,
          "blockBy": "",
          "blockUserId": "",
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        }).then((value) async {
          newpData.add(element.value);
          update();
          await ChatMessageApi().saveMessageInUserCollection(
              element.value["id"],
              element.value["id"],
              element.value["chatId"],
              content,
              isBroadcast: true,
              userData["id"]);
        });
      }
    });
    log("loop : $newpData");
  }

  //delete chat layout
  Widget buildPopupDialog(
      BuildContext context, DocumentSnapshot documentReference) {
    return BroadCastDeleteAlert(
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
