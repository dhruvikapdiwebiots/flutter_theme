import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/pages/theme_pages/chat/layouts/audio_recording_plugin.dart';
import 'package:flutter_theme/utilities/utils/handler/all_permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatController extends GetxController {
  String? pId, id, pName, groupId, imageUrl, peerNo, status, statusLastSeen;
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
    FirebaseFirestore.instance.collection('users').doc(pId).get().then((value) {
      if (value.data()!.isNotEmpty) {
        status = value.data()!["status"].toString();
        statusLastSeen = value.data()!["lastSeen"].toString();
      }
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
          {
            "status": "typing...",
            "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
          },
        );
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        FirebaseFirestore.instance.collection("users").doc(id).update(
          {
            "status": "Online",
            "lastSeen": DateTime.now().millisecondsSinceEpoch.toString()
          },
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
    PermissionStatus permissionStatus = await _getContactPermission();
    print(permissionStatus);
    if (permissionStatus == PermissionStatus.granted) {
      Get.to(ContactListPage())!.then((value) async{
        log("ccc : ${value}");
        Contact contact = value;
        log("contact : ${contact.phones![0].value}");
        onSendMessage(
            '${contact.displayName}-BREAK-${contact.phones![0].value}-BREAK-${contact.avatar!}',
            MessageType.contact);
      });
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
    update();
  }


  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
    }
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

      FirebaseFirestore.instance.collection('messages').add({
        'sender': id,
        'receiver': pId,
        // user ID you want to read message
        'content': content,
        "groupId": groupId ?? "",
        'type': type.name,
        'messageType': "sender",
        // i dont know why you need this ?
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        // I dont know why you called it just timestamp i changed it on created and passed an function with serverTimestamp()
      });

      final msgList = await FirebaseFirestore.instance
          .collection("contacts")
          .get()
          .then((value) {
        log("exist : ${value}");
        if (value.docs.isNotEmpty) {
          for (var i = 0; i < value.docs.length; i++) {
            final snapshot = value.docs[i].data();
            log("dd : ${snapshot["senderId"] == id && snapshot["receiverId"] == pId}");
            log("dd : ${snapshot["senderId"] == id}");
            if (snapshot["senderId"] == id && snapshot["receiverId"] == pId || snapshot["senderId"] == pId && snapshot["receiverId"] == id) {
              log("es : ${value.docs[i].id}");
              FirebaseFirestore.instance
                  .collection('contacts')
                  .doc(value.docs[i].id)
                  .update({
                "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
                "lastMessage": content
              });
            } else {
              dynamic user = appCtrl.storage.read("user");

              FirebaseFirestore.instance.collection('contacts').add({
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
          }

          /*if (msgList.exists) {
        FirebaseFirestore.instance
            .collection('contacts')
            .doc(msgList.id)
            .update({
          "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
          "lastMessage": content
        });
      } else {
        dynamic user = appCtrl.storage.read("user");

        FirebaseFirestore.instance.collection('contacts').add({
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
      }*/
          listScrollController.animateTo(0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        } else {
          dynamic user = appCtrl.storage.read("user");

          FirebaseFirestore.instance.collection('contacts').add({
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
      });
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
    if (document['sender'] == id) {
      return SenderMessage(
        document: document,
        index: index,
      );
    } else {
      // RECEIVER MESSAGE
      return ReceiverMessage(document: document, index: index);
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
