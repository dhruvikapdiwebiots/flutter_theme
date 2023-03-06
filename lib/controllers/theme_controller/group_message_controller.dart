import 'dart:async';
import 'dart:developer' as log;
import 'dart:io';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupChatMessageController extends GetxController {
  String? pId,
      id,
      documentId,
      pName,
      groupImage,
      groupId,
      imageUrl,
      status,
      statusLastSeen,
      nameList,
      videoUrl;
  dynamic message, pData;
  bool positionStreamStarted = false;
  XFile? imageFile;
  XFile? videoFile;
  File? image;
  bool isLoading = true;
  dynamic user;
  bool typing = false;
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());
  TextEditingController textEditingController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void onReady() {
    // TODO: implement onReady
    user = appCtrl.storage.read(session.user);
    id = user["id"];
    groupId = '';
    isLoading = false;
    imageUrl = '';
    var data = Get.arguments;
    pData = data;
    pId = pData["groupId"];
    pName = pData["name"];
    groupImage = pData["image"];
    getPeerStatus();

    update();
    super.onReady();
  }

//get group data
  getPeerStatus() {
    nameList = "";
    nameList = null;
    FirebaseFirestore.instance
        .collection(collectionName.groups)
        .doc(pId)
        .get()
        .then((value) {
      if (value.exists) {
        List receiver = pData["users"];
        nameList = (receiver.length -1).toString();
      }

      update();
    });

    FirebaseFirestore.instance
        .collection(collectionName.groupMessage)
        .doc(pId)
        .collection(collectionName.chat)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        documentId = value.docs[0].id;
      }
    });

    return status;
  }

  //document share
  documentShare() async {

    pickerCtrl.dismissKeyboard();
    Get.back();
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      isLoading = true;
      update();
      File file = File(result.files.single.path.toString());
      String fileName =
          "${file.name}-${DateTime.now().millisecondsSinceEpoch.toString()}";
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(file);

      uploadTask.then((res) {
        res.ref.getDownloadURL().then((downloadUrl) {
          imageUrl = downloadUrl;
          isLoading = false;
          onSendMessage(
              "${result.files.single.name}-BREAK-$imageUrl",
              result.files.single.path.toString().contains(".mp4")
                  ? MessageType.video
                  : result.files.single.path.toString().contains(".mp3")
                      ? MessageType.audio
                      : MessageType.doc);
          update();
        }, onError: (err) {
          isLoading = false;
          update();
          Fluttertoast.showToast(msg: 'Not Upload');
        });
      });
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
        backgroundColor: appCtrl.appTheme.transparentColor,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout

          return const GroupBottomSheet();
        });
  }

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadFile() async {
    imageFile = pickerCtrl.imageFile;
    update();

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

  Future videoSend() async {
    videoFile = pickerCtrl.videoFile;
    update();
    if (videoFile != null) {
      const Duration(seconds: 2);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      var file = File(videoFile!.path);
      UploadTask uploadTask = reference.putFile(file);
      uploadTask.then((res) {
        res.ref.getDownloadURL().then((downloadUrl) {
          videoUrl = downloadUrl;
          isLoading = false;

          pickerCtrl.videoFile = null;

          pickerCtrl.video = null;
          update();
          pickerCtrl.update();
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
  }

  //pick up contact and share
  saveContactInChat() async {
    PermissionStatus permissionStatus =
        await permissionHandelCtrl.getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Get.toNamed(routeName.allContactList)!.then((value) async {
        if (value != null) {
          Contact contact = value;
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

      String fileName =
          "${file.name}-${DateTime.now().millisecondsSinceEpoch.toString()}";
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();

      onSendMessage(downloadUrl, MessageType.audio);
    });
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, MessageType type, {groupId}) async {
    isLoading = true;
    textEditingController.clear();
    update();
    if (content.trim() != '') {
      var user = appCtrl.storage.read(session.user);
      id = user["id"];
      FirebaseFirestore.instance
          .collection(collectionName.groupMessage)
          .doc(pId)
          .collection(collectionName.chat)
          .add({
        'sender': id,
        'senderName': user["name"],
        'receiver': pData["users"],
        'content': content,
        "groupId": pId,
        'type': type.name,
        'messageType': "sender",
        "status": "",
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      await ChatMessageApi().saveGroupData(id, pId, content, pData);
      isLoading = false;
      videoFile = null;
      videoUrl = "";
      pickerCtrl.videoFile = null;

      pickerCtrl.video = null;
      update();
      pickerCtrl.update();
      update();
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  //delete chat layout
  Widget buildPopupDialog(
      BuildContext context, DocumentSnapshot documentReference) {
    return GroupDeleteAlert(
      documentReference: documentReference,
    );
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN
  Widget buildItem(int index, DocumentSnapshot document) {
    return Column(
      children: [
        (document['sender'] == user["id"])
            ? GroupSenderMessage(
                document: document,
                index: index,
                currentUserId: user["id"],
              )
            :
            // RECEIVER MESSAGE

            GroupReceiverMessage(document: document, index: index)
      ],
    );
  }

  //group call
  audioAndVideoCall(isVideoCall) async {
    try {
      var userData = appCtrl.storage.read(session.user);

      String channelId = Random().nextInt(1000).toString();
      ClientRoleType role = ClientRoleType.clientRoleBroadcaster;
      int timestamp = DateTime.now().millisecondsSinceEpoch;
      List receiver = pData["users"];

      receiver.asMap().entries.forEach((element) {

        FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(element.value["id"])
            .get()
            .then((snap) async {
          Call call = Call(
              timestamp: timestamp,
              callerId: userData["id"],
              callerName: userData["name"],
              callerPic: userData["image"],
              receiverId: snap.data()!["id"],
              receiverName: snap.data()!["name"],
              receiverPic: snap.data()!["image"],
              callerToken: userData["pushToken"],
              receiverToken: snap.data()!["pushToken"],
              channelId: channelId,
              isVideoCall: isVideoCall,receiver: receiver);

          await FirebaseFirestore.instance
              .collection(collectionName.calls)
              .doc(call.callerId)
              .collection(collectionName.calling)
              .add({
            "timestamp": timestamp,
            "callerId": userData["id"],
            "callerName": userData["name"],
            "callerPic": userData["image"],
            "receiverId": snap.data()!["id"],
            "receiverName": snap.data()!["name"],
            "receiverPic": snap.data()!["image"],
            "callerToken": userData["pushToken"],
            "receiverToken": snap.data()!["pushToken"],
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
              "receiverId": snap.data()!["id"],
              "receiverName": snap.data()!["name"],
              "receiverPic": snap.data()!["image"],
              "callerToken": userData["pushToken"],
              "receiverToken": snap.data()!["pushToken"],
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
                  "role": role,
                };

                Get.toNamed(routeName.videoCall, arguments: data);
              }
            });
          });
        });
      });
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
  log.log("err :$e");
    }
  }

  // ON BACK PRESS
  Future<bool> onBackPress() {
    firebaseCtrl.groupTypingStatus(pId, documentId, false);
    Get.back();
    return Future.value(false);
  }
}
