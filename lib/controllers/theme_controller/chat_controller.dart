import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartx/dartx_io.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/message_model.dart';
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
      videoUrl;
  dynamic message;
  dynamic pData;
  bool positionStreamStarted = false;
  bool isUserAvailable = true;
  XFile? imageFile;
  XFile? videoFile;
  File? image;
  File? video;
  bool? isLoading = true;
  bool typing = false;
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
    var data = Get.arguments;
    if (data == "No User") {
      isUserAvailable = false;
    } else {
      print("arg : $data");
      pData = data["data"];
      pId = pData["id"];
      pName = pData["name"];
      chatId = data["chatId"];
      readLocal();
      getPeerStatus();
      isUserAvailable = true;
      update();
    }
    print("chatId : $chatId");
    print(
        "all : ${FirebaseFirestore.instance.collection('messages').doc(chatId).collection("chat").orderBy('timestamp', descending: true).get().then((value) => {
              print("va : ${value.docs[0].data()}")
            })}");
    update();
    getMessage();
    super.onReady();
  }

  Stream<List<MessageModel>> getMessage()  {
    print("object");
    return FirebaseFirestore.instance .collection('messages')
        .doc(chatId!)
        .collection("chat")
        .orderBy('timestamp', descending: true).limit(20)
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var document in event.docs) {
        print("document : $document");
        messages.add(MessageModel.fromMap(document.data()));
      }
      return messages;
    });
  }

  //get user online, offline, typing status
  getPeerStatus() {
    FirebaseFirestore.instance.collection('users').doc(pId).get().then((value) {
      if (value.exists) {
        if (value.data()!.isNotEmpty) {
          status = value.data()!["status"].toString();
          statusLastSeen = value.data()!["lastSeen"].toString();
        }
      }
    });
    update();
    return status;
  }

  //update typing status
  setTyping() async {
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty) {
        FirebaseFirestore.instance.collection("users").doc(id).update({
          "status": "typing...",
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
    id = appCtrl.storage.read('id') ?? '';
    FirebaseFirestore.instance
        .collection(
            'users') // Your collection name will be whatever you have given in firestore database
        .doc(id)
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
    Position? position =
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
      FirebaseFirestore.instance
          .collection('messages')
          .doc(newChatId)
          .collection("chat")
          .add({
        'sender': id,
        'receiver': pId,
        // user ID you want to read message
        'content': content,
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
        if (value.docs.isNotEmpty) {
          for (var i = 0; i < value.docs.length; i++) {
            dynamic user = appCtrl.storage.read("user");
            final snapshot = value.docs[i].data();
            if (snapshot["senderId"] == id && snapshot["receiverId"] == pId ||
                snapshot["senderId"] == pId && snapshot["receiverId"] == id) {
              FirebaseFirestore.instance
                  .collection('contacts')
                  .doc(value.docs[i].id)
                  .update({
                "updateStamp": DateTime.now().millisecondsSinceEpoch.toString(),
                "lastMessage": content,
                "senderId": id,
                'sender': {
                  "id": user["id"],
                  "name": user["name"],
                  "image": user["image"]
                },
                'receiver': {"id": pId, "name": pName, "image": pData["image"]},
                'receiverId': pId,
              });
            } else {
              FirebaseFirestore.instance.collection('contacts').add({
                'sender': {
                  "id": user["id"],
                  "name": user["name"],
                  "image": user["image"]
                },
                'receiver': {"id": pId, "name": pName, "image": pData["image"]},
                'receiverId': pId,
                'senderId': user["id"],
                'chatId': newChatId,
                'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                "lastMessage": content,
                "isGroup": false,
                "groupId": "",
                "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
              });
            }
          }

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
            'chatId': newChatId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            "lastMessage": content,
            "isGroup": false,
            "groupId": "",
            "updateStamp": DateTime.now().millisecondsSinceEpoch.toString()
          });
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
  Widget buildItem(int index, document) {
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

  Future<bool> getContact(document) async {
    List<Contact>? contactList;
    bool isExist = false;
    try {
      PermissionStatus permissionStatus =
          await permissionHandelCtrl.getContactPermission();
      if (permissionStatus == PermissionStatus.granted) {
        var contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: false));
        contactList = contacts;
        print(contactList.length);
        isExist = await getContactList(contactList, document);
      }
    } catch (e) {
      log("message : $e");
    }
    return isExist;
  }

  getContactList(List<Contact> contacts, DocumentSnapshot document) async {
    var statusesSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    log("statusesSnapshot : ${statusesSnapshot.docs.length}");
    List<Status> statusData = [];
    for (int i = 0; i < statusesSnapshot.docs.length; i++) {
      for (int j = 0; j < contacts.length; j++) {
        if (contacts[j].phones!.isNotEmpty) {
          print("phonephonephone : ${contacts[j].phones![0].value}");
          String phone = contacts[j].phones![0].value.toString();
          if (phone.length > 10) {
            if (phone.contains(" ")) {
              phone = phone.replaceAll(" ", "");
            }
            if (phone.contains("-")) {
              phone = phone.replaceAll("-", "");
            }
            if (phone.contains("+")) {
              phone = phone.replaceAll("+91", "");
            }
          }
          print("phone : $phone");
          print(phone == statusesSnapshot.docs[i]["phone"]);
          if (phone == statusesSnapshot.docs[i]["phone"]) {
            if (statusesSnapshot.docs[i]["id"] == document["receiver"]) {
              return true;
            } else {
              return false;
            }
          } else {
            return false;
          }
        }
      }
    }

    return statusData;
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
