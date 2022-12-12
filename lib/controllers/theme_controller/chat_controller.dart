import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/chat/layouts/audio_recording_plugin.dart';
import 'package:flutter_theme/utilities/utils/handler/all_permission_handler.dart';

class ChatController extends GetxController {
  String? pId, id, pName, groupId, imageUrl, peerNo,status,statusLastSeen;
  dynamic message;
  dynamic pData;
  final permissionHandelCtrl = Get.put(PermissionHandlerController());
  bool positionStreamStarted = false;
  XFile? imageFile;
  bool? isLoading;
  bool typing = false;

  TextEditingController textEditingController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void onReady() {
    // TODO: implement onReady
    groupId = '';
    isLoading = false;
    imageUrl = '';
    var data = Get.arguments;
    pData = data;
    pId = data["id"];
    pName = data["name"];
    readLocal();
    getPeerStatus();
    update();
    super.onReady();
  }

  getPeerStatus() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(pId).get().then((value) {
      print("statsy : ${value.data()!["status"]}" );
      status = value.data()!["status"].toString();
      statusLastSeen = value.data()!["lastSeen"].toString();
    });
    update();
    return status;
  }

//read local data
  readLocal() async {
    id = appCtrl.storage.read('id') ?? '';
    groupId = '$id-$pId';
    log("groupId : $groupId");
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(id)
        .update({'chattingWith': pId});
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty) {
        FirebaseFirestore.instance.collection("users").doc(id).update(
          {"status": "typing...","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
        );
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        FirebaseFirestore.instance.collection("users").doc(id).update(
          {"status": "Online","lastSeen": DateTime.now().millisecondsSinceEpoch.toString()},
        );
        typing = false;
      }
    });
    update();
  }

// FOR Dismiss KEYBOARD
  void dismissKeyboard() {
    FocusScope.of(Get.context!).requestFocus(FocusNode());
  }

  documentShare() async {
    dismissKeyboard();
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
    dismissKeyboard();
    Get.back();
    await getCurrentPosition().then((value) async {
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
    // Add your onPressed code here!
    final granted = await FlutterContactPicker.hasPermission();
    if (granted) {
      update();
    } else {
      await FlutterContactPicker.requestPermission().then((value) async {
        update();
      });
    }
    final FullContact contactPick =
        (await FlutterContactPicker.pickFullContact());

    onSendMessage(
        '${contactPick.name!.nickName}-BREAK-${contactPick.phones[0].number}-BREAK-${contactPick.photo!}',
        MessageType.contact);
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
          child: AudioRecordingPlugin(
            type: type,
            index: index,
          ),
        );
      },
    );
  }

  Future<Position> getCurrentPosition() async {
    final hasPermission = await permissionHandelCtrl.handlePermission();

    if (!hasPermission) {
      return Geolocator.getCurrentPosition();
    }

    final position =
        await permissionHandelCtrl.geoLocatorPlatform.getCurrentPosition();
    permissionHandelCtrl.updatePositionList(
      PositionItemType.position,
      position.toString(),
    );

    return position;
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, MessageType type, {groupId}) async {
    if (content.trim() != '') {
      textEditingController.clear();
      FirebaseFirestore.instance
          .collection('messages')
          .doc(collectionName.chatWith)
          .set({
        'idFrom': id,
        'idTo': pId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'type': type.name,
        "groupId": groupId ?? "",
      });

      final msgList = await FirebaseFirestore.instance
          .collection("contacts")
          .doc("$id-$pId")
          .get();
      if (msgList.exists) {
        FirebaseFirestore.instance
            .collection('contacts')
            .doc("$id-$pId")
            .update({
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content
        });
      } else {
        dynamic user = appCtrl.storage.read("user");

        FirebaseFirestore.instance.collection('contacts').doc("$id-$pId").set({
          'sender': {
            "id": user["id"],
            "name": user["name"],
            "image": user["image"]
          },
          'receiver': {"id": pId, "name": pName, "image": pData["image"]},
          'receiverId': pId,
          'senderId': user["id"],
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content,
          "isGroup": groupId ?? "",
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
        });
      }
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  //delete chat
  Widget buildPopupDialog(
      BuildContext context, DocumentSnapshot documentReference) {
    return DeleteAlert(
      documentReference: documentReference,
    );
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN
  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      return SenderMessage(
        document: document,
        index: index,
      );
    } else {
      // RECEIVER MESSAGE
      return ReceiverMessage(document: document, index: index);
    }
  }

  // CHECK IF IT IS RECEIVER SIDE OR NOT
  bool isLastMessageLeft(int index) {
    if ((index > 0 && message != null && message![index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // CHECK IF IT IS SENDER SIDE OR NOT
  bool isLastMessageRight(int index) {
    if ((index > 0 && message != null && message![index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
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
            dismissKeyboard();
            getImage(ImageSource.camera);
            Get.back();
          }, galleryTap: () {
            getImage(ImageSource.gallery);
            Get.back();
          });
        });
  }
}
