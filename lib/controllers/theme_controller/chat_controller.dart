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
      pData = data["data"];
      pId = pData["id"];
      pName = pData["name"];
      chatId = data["chatId"];
      isUserAvailable = true;
      update();
    }
    update();

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

  //block user
  blockUser() async {
    var user = appCtrl.storage.read("user");
    await FirebaseFirestore.instance.collection("blocks").doc(user["id"]).collection("users").add({
      "userId": pId,
    });
    DateTime now = DateTime.now();
    String? newChatId =
        chatId == "0" ? now.microsecondsSinceEpoch.toString() : chatId;
    chatId = newChatId;
    FirebaseFirestore.instance
        .collection('messages')
        .doc(newChatId)
        .collection("chat")
        .add({
      'sender': user["id"],
      'receiver': pId,
      // user ID you want to read message
      'content': "You block this contact",
      "chatId": newChatId,
      'type': MessageType.messageType.name,
      'messageType': "sender",
      // i dont know why you need this ?
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      // I dont know why you called it just timestamp i changed it on created and passed an function with serverTimestamp()
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
    var user = appCtrl.storage.read("user");
    FirebaseFirestore.instance
        .collection("blocks")
        .doc(user["id"]).collection("users")
        .get()
        .then((value) {
      bool isContains = value.docs[0].data().containsValue(pId);
      print(" d: $isContains");
      if (isContains) {
        print(value.docs[0].data());
        Get.generalDialog(
          pageBuilder: (context, anim1, anim2) {
            return Align(
              alignment: Alignment.center,
              child: AlertDialog(

                content:  Text("Unblock $pName to send message?"),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child:  Text(
                        "Cancel",
                        style: TextStyle(color: appCtrl.appTheme.gray, fontSize: 17),
                      )),
                  TextButton(
                      onPressed: () {
                       print("d : ${value.docs}");
                       for(int i = 0;i< value.docs.length;i++){
                         if(value.docs[i].data()["userId"] == pId){
                           FirebaseFirestore.instance
                               .collection("blocks")
                               .doc(user["id"]).collection("users").doc(value.docs[i].id).delete();
                           DateTime now = DateTime.now();
                           String? newChatId =
                           chatId == "0" ? now.microsecondsSinceEpoch.toString() : chatId;
                           chatId = newChatId;
                           FirebaseFirestore.instance
                               .collection('messages')
                               .doc(newChatId)
                               .collection("chat")
                               .add({
                             'sender': user["id"],
                             'receiver': pId,
                             // user ID you want to read message
                             'content': "You Unblock this contact",
                             "chatId": newChatId,
                             'type': MessageType.messageType.name,
                             'messageType': "sender",
                             // i dont know why you need this ?
                             'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                             // I dont know why you called it just timestamp i changed it on created and passed an function with serverTimestamp()
                           });
                         }
                       }
                        Get.back();
                      },
                      child: Text(
                        "UnBlock",
                        style: TextStyle(color: appCtrl.appTheme.primary, fontSize: 17),
                      ))
                ],
              ),
            );
          },
          transitionBuilder: (context, anim1, anim2, child) {
            return SlideTransition(
              position: Tween(
                  begin: const Offset(0, -1), end: const Offset(0, 0))
                  .animate(anim1),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      } else {
        if (content.trim() != '') {
          FirebaseFirestore.instance
              .collection("blocks")
              .doc(user["id"])
              .get()
              .then((value) {
            if (value.exists) {
              Get.generalDialog(
                pageBuilder: (context, anim1, anim2) {
                  return Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: Sizes.s280,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.r8)),
                      margin:
                          const EdgeInsets.symmetric(horizontal: Insets.i50),
                      child: Column(
                        children: [Text("Unblock $pName to send message")],
                      ),
                    ),
                  );
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return SlideTransition(
                    position: Tween(
                            begin: const Offset(0, -1), end: const Offset(0, 0))
                        .animate(anim1),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              );
            } else {
              final now = DateTime.now();
              String? newChatId = chatId == "0"
                  ? now.microsecondsSinceEpoch.toString()
                  : chatId;
              chatId = newChatId;
              update();
              FirebaseFirestore.instance
                  .collection('messages')
                  .doc(newChatId)
                  .collection("chat")
                  .add({
                'sender': user["id"],
                'receiver': pId,
                // user ID you want to read message
                'content': content,
                "chatId": newChatId,
                'type': type.name,
                'messageType': "sender",
                // i dont know why you need this ?
                'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
                // I dont know why you called it just timestamp i changed it on created and passed an function with serverTimestamp()
              }).then((value) async {
                final msgList = await FirebaseFirestore.instance
                    .collection("contacts")
                    .where("chatId", isEqualTo: newChatId)
                    .get()
                    .then((value) {
                  print("id : ${user['id']}");
                  print("pData : $pData");
                  if (value.docs.isNotEmpty) {
                    FirebaseFirestore.instance
                        .collection('contacts')
                        .doc(value.docs[0].id)
                        .update({
                      "updateStamp":
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      "lastMessage": content,
                      "senderPhone": user['phone'],
                      'sender': {
                        "id": user['id'],
                        "name": user['name'],
                        "image": user["image"],
                        "phone": user["phone"]
                      },
                      "receiverPhone": pData["phone"],
                      "receiver": {
                        "id": pId,
                        "name": pName,
                        "image": pData["image"],
                        "phone": pData["phone"]
                      }
                    });

                    listScrollController.animateTo(0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  } else {
                    dynamic user = appCtrl.storage.read("user");

                    FirebaseFirestore.instance.collection('contacts').add({
                      'sender': {
                        "id": user["id"],
                        "name": user["name"],
                        "image": user["image"],
                        "phone": user["phone"]
                      },
                      'receiver': {
                        "id": pId,
                        "name": pName,
                        "image": pData["image"],
                        "phone": pData["phone"]
                      },
                      'receiverPhone': pData["phone"],
                      "senderPhone": user['phone'],
                      'chatId': newChatId,
                      'timestamp':
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      "lastMessage": content,
                      "isGroup": false,
                      "groupId": "",
                      "updateStamp":
                          DateTime.now().millisecondsSinceEpoch.toString()
                    });
                  }
                });
              });
            }
          });
        }
      }
    });
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
    var user = appCtrl.storage.read("user");
    if (document['sender'] == user["id"]) {
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
      bool permissionStatus = await permissionHandelCtrl.permissionGranted();
      if (permissionStatus) {
        List<Contact> allContacts = await getAllContacts();
        contactList = allContacts;
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
    List<Status> statusData = [];
    for (int i = 0; i < statusesSnapshot.docs.length; i++) {
      for (int j = 0; j < contacts.length; j++) {
        if (contacts[j].phones!.isNotEmpty) {
          String phone =
              phoneNumberExtension(contacts[j].phones![0].value.toString());

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

  // ON BACK PRESS
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
