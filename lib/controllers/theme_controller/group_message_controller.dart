import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/controllers/common_controller/picker_controller.dart';
import 'package:flutter_theme/controllers/common_controller/picker_controller.dart';
import 'package:flutter_theme/controllers/common_controller/picker_controller.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_receiver/group_receiver_message.dart';
import 'package:flutter_theme/pages/theme_pages/group_chat_message/layouts/group_sender/sender_message.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupChatMessageController extends GetxController {
  String? pId, id, pName, groupId, imageUrl, peerNo, status, statusLastSeen;
  dynamic message;
  dynamic pData;
  bool positionStreamStarted = false;
  XFile? imageFile;
  File? image;
  bool isLoading = true;
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
    var user = appCtrl.storage.read("user");
    id = user["id"];
    groupId = '';
    isLoading = false;
    imageUrl = '';
    var data = Get.arguments;
    pData = data;
    pId = data["id"];
    pName = data["name"];
    readLocal();
    getPeerStatus();
    log("groupData : $pData");
    update();
    super.onReady();
  }

  getPeerStatus() {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(pId)
        .get()
        .then((value) {
      if (value.exists) {
        if (value.data()!.isNotEmpty) {
          log("ddd : ${value.data()}");
          pData = value.data();
        }
      }
    });
    update();
    return status;
  }

  setTyping() async {
    final user = appCtrl.storage.read("user");
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty) {
        FirebaseFirestore.instance.collection("users").doc(id).update({
          "status": "${user["name"]} is typing...",
          "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
        });
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        FirebaseFirestore.instance.collection("users").doc(id).update({
          "status": "Online",
          "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
        });
        typing = false;
      }
    });
  }

//read local data
  readLocal() async {
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(pId)
        .update({'chattingWith': pId});
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty) {
        appCtrl.firebaseCtrl.setTyping();
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        appCtrl.firebaseCtrl.setIsActive();
        typing = false;
      }
    });
    update();
  }

  documentShare() async {
    pickerCtrl.dismissKeyboard();
    Get.back();
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path.toString());
      String fileName =
          "${file.name}-${DateTime.now().millisecondsSinceEpoch.toString()}";
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(file);
      print("fileName : $fileName");
      print("file : $file");
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
          'https://www.google.com/maps/search/?api=1&query=${value.latitude},${value.longitude}';
      onSendMessage(locationString, MessageType.location);
    });
  }

  //share media
  shareMedia(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout

          return const FileBottomSheet();
        });
  }

// GET IMAGE FROM GALLERY
  Future getImage(source) async {
    final ImagePicker picker = ImagePicker();
    imageFile = (await picker.pickImage(source: source))!;
    if (imageFile != null) {
      isLoading = true;
      update();
      uploadFile();
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
  void onSendMessage(String content, MessageType type, {groupId}) async {
    if (content.trim() != '') {
      textEditingController.clear();

      FirebaseFirestore.instance.collection('messages').add({
        'sender': id,
        'receiver': pData["users"],
        // user ID you want to read message
        'content': content,
        "groupId": pId,
        'type': type.name,
        'messageType': "sender",
        // i dont know why you need this ?
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        // I dont know why you called it just timestamp i changed it on created and passed an function with serverTimestamp()
      });

      await FirebaseFirestore.instance
          .collection("contacts")
          .get()
          .then((value) {
        log("exist : ${value}");
        if (value.docs.isNotEmpty) {
          for (var i = 0; i < value.docs.length; i++) {
            final snapshot = value.docs[i].data();
            if (snapshot["isGroup"] == true && snapshot["groupId"] == pId) {
              log("es : ${value.docs[i].id}");
              FirebaseFirestore.instance
                  .collection('contacts')
                  .doc(value.docs[i].id)
                  .update({
                "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
                "lastMessage": content
              });
            }
          }

          listScrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
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
  Widget buildItem(int index, DocumentSnapshot document) {
    print("groupId : ${document['groupId']}");
    return Column(
      children: [
        (document['sender'] == id && document['groupId'] == pId)
            ? GroupSenderMessage(
                document: document,
                index: index,
                currentUserId: id,
              )
            :
            // RECEIVER MESSAGE
        document['groupId'] != "" ?
         GroupReceiverMessage(document: document, index: index):Container()
      ],
    );
  }

  // ON BACKPRESS
  Future<bool> onBackPress() {
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(id)
        .update({'chattingWith': null});
    Get.back();
    return Future.value(false);
  }

  //image picker option
  imagePickerOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.r25)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return ImagePickerLayout(cameraTap: () {
            pickerCtrl.dismissKeyboard();
            getImage(ImageSource.camera);
            Get.back();
          }, galleryTap: () {
            getImage(ImageSource.gallery);
            Get.back();
          });
        });
  }
}
