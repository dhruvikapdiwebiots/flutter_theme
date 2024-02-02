import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:dartx/dartx_io.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/message_model.dart';
import 'package:flutter_theme/pages/theme_pages/broadcast_chat/layouts/broad_cast_wall_paper.dart';
import 'package:flutter_theme/pages/theme_pages/broadcast_chat/layouts/broadcast_file_list.dart';
import 'package:flutter_theme/widgets/reaction_pop_up/emoji_picker_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../pages/theme_pages/broadcast_chat/layouts/broad_cast_clear_dialog.dart';

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
  List selectedIndexId = [];
  List newpData = [], userList = [], searchUserList = [];
  bool positionStreamStarted = false;
  bool isUserAvailable = true;
  bool isTextBox = false, isThere = false;
  XFile? imageFile;
  String? wallPaperType;
  XFile? videoFile;
  File? image;
  int totalUser = 0;
  String nameList = "";
  Offset tapPosition = Offset.zero;
  File? video;
  bool? isLoading = true;
  bool typing = false, isBlock = false,enableReactionPopup =false,showPopUp=false;
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textNameController = TextEditingController();
  TextEditingController textSearchController = TextEditingController();
  ScrollController listScrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  List newContact = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> allMessages = [];
  StreamSubscription? messageSub;
  List<DateTimeChip> localMessage = [];

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
    pName = broadData["name"] ?? "";
    newContact = data["newContact"] ?? [];
    totalUser = pData.length;

    for (var i = 0; i < pData.length; i++) {
      if (nameList != "") {
        nameList = "$nameList, ${pData[i]["name"]}";
      } else {
        nameList = pData[i]["name"];
      }
    }
    update();

    getBroadcastData();

    super.onReady();
  }

  //get broad cast data
  getBroadcastData() async {
    log("chatId :: $chatId");
    messageSub =  FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .collection(collectionName.broadcastMessage)
        .doc(pId)
        .collection(collectionName.chat)
        .snapshots()
        .listen((event) async {
      allMessages = event.docs;
      update();
      ChatMessageApi().getLocalBroadcastMessage();

      isLoading = false;
      update();
    });
    await FirebaseFirestore.instance
        .collection(collectionName.broadcast)
        .doc(pId)
        .get()
        .then((value) {
      if (value.exists) {

        if (value.data().toString().contains('backgroundImage')) {
          broadData["backgroundImage"] = value.data()!["backgroundImage"] ?? "";

        } else {
          broadData["backgroundImage"] = "";
        }
      } else {
        broadData["backgroundImage"] = "";
      }
      broadData["users"] = value.data()!["users"] ?? [];
    });

    if (newContact.isNotEmpty) {
      Encrypted encrypteded = encryptFun("You created this broadcast");
      String encrypted = encrypteded.base64;
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.broadcastMessage)
          .doc(pId)
          .collection(collectionName.chat)
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set({
        'sender': appCtrl.user["id"],
        'senderName': appCtrl.user["name"],
        'receiver': newContact,
        'content': encrypted,
        "broadcastId": pId,
        'type': MessageType.messageType.name,
        'messageType': "sender",
        "status": "",
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    }
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .collection(collectionName.broadcastMessage)
        .doc(chatId)
        .collection(collectionName.chat)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        allMessages = value.docs;
        update();
        log("allMessages ::: $allMessages");
        ChatMessageApi().getLocalBroadcastMessage();
        update();
        isLoading = false;
        update();
      }
    });

    update();


  }


//clear dialog
  clearChatConfirmation() async {
    Get.generalDialog(
      pageBuilder: (context, anim1, anim2) {
        return const BroadcastClearDialog();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
            position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
                .animate(anim1),
            child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }



  wallPaperConfirmation(image) async {
    Get.generalDialog(
      pageBuilder: (context, anim1, anim2) {
        return BroadcastChatWallPaper(
          image: image,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
            position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
                .animate(anim1),
            child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
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
      isLoading = true;
      update();
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
        backgroundColor: appCtrl.appTheme.transparentColor,
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

// UPLOAD SELECTED IMAGE TO FIREBASE
  Future uploadMultipleFile(File imageFile, MessageType messageType) async {
    imageFile = imageFile;
    update();

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    var file = File(imageFile.path);
    UploadTask uploadTask = reference.putFile(file);
    uploadTask.then((res) {
      res.ref.getDownloadURL().then((downloadUrl) async {
        imageUrl = downloadUrl;
        isLoading = false;
        onSendMessage(imageUrl!, messageType);
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
            '${contact.displayName}-BREAK-${contact.phones[0].normalizedNumber}-BREAK-${contact.photo}',
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
    );
  }

  // SEND MESSAGE CLICK
  void onSendMessage(String content, MessageType type) async {
    if (content.trim() != '') {
      Encrypted encrypteded = encryptFun(content);
      String encrypted = encrypteded.base64;

      textEditingController.clear();
      await saveMessageInLoop(encrypted, type);
      await Future.delayed(DurationClass.s4);
      String dateTime = DateTime.now().millisecondsSinceEpoch.toString();

      MessageModel messageModel = MessageModel(
          blockBy:"",
          blockUserId: "",
          broadcastId: chatId,
          chatId: chatId,
          content: encrypted,
          docId: dateTime,
          isBlock: false,
          isBroadcast: false,
          isFavourite: false,
          isSeen: false,
          messageType: "sender",
          receiverList: pData,
          sender: appCtrl.user["id"],
          timestamp: dateTime,
          type: type.name);
      bool isEmpty =
          localMessage.where((element) => element.time == "Today").isEmpty;
      if (isEmpty) {
        List<MessageModel>? message = [];
        if (message.isNotEmpty) {
          message.add(messageModel);
          message[0].docId = dateTime;
        } else {
          message = [messageModel];
          message[0].docId = dateTime;
        }
        DateTimeChip dateTimeChip =
        DateTimeChip(time: getDate(dateTime), message: message);
        localMessage.add(dateTimeChip);
      } else {
        int index =
        localMessage.indexWhere((element) => element.time == "Today");

        if (!localMessage[index].message!.contains(messageModel)) {
          localMessage[index].message!.add(messageModel);
        }
      }
      update();
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userData["id"])
          .collection(collectionName.chats)
          .where("broadcastId", isEqualTo: pId)
          .get()
          .then((snap) {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(userData["id"])
            .collection(collectionName.chats)
            .doc(snap.docs[0].id)
            .update({
          "receiverId": pData,
          "updateStamp": dateTime,
          "lastMessage": encrypted
        });
      });

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userData["id"])
          .collection(collectionName.broadcastMessage)
          .doc(pId)
          .collection(collectionName.chat)
          .doc(dateTime)
          .set({
        'sender': userData["id"],
        'senderName': userData["name"],
        'receiver': pData,
        'content': encrypted,
        "broadcastId": pId,
        'type': type.name,
        'messageType': "sender",
        "status": "",
        'timestamp': dateTime,
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(userData["id"])
            .collection(collectionName.chats)
            .where("broadcastId", isEqualTo: pId)
            .get();
      });

      Get.forceAppUpdate();
    }
  }

  saveMessageInLoop(content, MessageType type) async {
    pData.asMap().entries.forEach((element) async {
      if (element.value["id"] != appCtrl.user["id"]) {
        log("CHATID : ${element.value["chatId"]}");
        if (element.value["chatId"] != null) {
          newpData.add(element.value);
          update();
          await ChatMessageApi()
              .saveMessage(
                  element.value["chatId"],
                  pId,
                  content,
                  type,
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  userData["id"],
                  isBroadcast: true)
              .then((value) async {
            await ChatMessageApi().saveMessageInUserCollection(
                element.value["id"],
                element.value["id"],
                element.value["chatId"],
                content,

                userData["id"],
                userData["name"],type, isBroadcast: true,);
          });
        } else {
          final now = DateTime.now();
          String? newChatId = now.microsecondsSinceEpoch.toString();
          update();
          element.value["chatId"] = newChatId;
          await ChatMessageApi()
              .saveMessage(
                  element.value["chatId"],
                  pId,
                  content,
                  type,
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  userData["id"],
                  isBroadcast: true)
              .then((value) async {
            newpData.add(element.value);
            update();
            await ChatMessageApi().saveMessageInUserCollection(
                element.value["id"],
                element.value["id"],
                element.value["chatId"],
                content,

                userData["id"],
                userData["name"],type,                isBroadcast: true,);
          });
        }
      }
    });
  }

  //delete chat layout
   buildPopupDialog(

   )async {
     await showDialog(
         context: Get.context!, builder: (_) => const BroadCastDeleteAlert());

  }

  Widget timeLayout(DateTimeChip document) {
    List<MessageModel> newMessageList = document.message!.reversed.toList();
    return Column(
      children: [
        Text(
                document.time!.contains("-other")
                    ? document.time!.split("-other")[0]
                    : document.time!,
                style:
                    AppCss.poppinsMedium14.textColor(appCtrl.appTheme.txtColor))
            .marginSymmetric(vertical: Insets.i5),
        ...newMessageList.asMap().entries.map((e) {
          return buildItem( e.key,
              e.value,
              e.value.docId,
              document.time!.contains("-other")
                  ? document.time!.split("-other")[0]
                  : document.time!);
        }).toList()
      ],
    );
  }

// BUILD ITEM MESSAGE BOX FOR RECEIVER AND SENDER BOX DESIGN
  Widget buildItem(int index, MessageModel document, documentId, title) {

    if (document.sender == userData["id"]) {
      return BroadcastSenderMessage(
        document: document,
        index: index,
        docId: documentId,
        title: title,
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

    return Future.value(true);
  }

  //ON LONG PRESS
  onLongPressFunction(docId) {
    showPopUp = true;
    enableReactionPopup = true;

    if (!selectedIndexId.contains(docId)) {
      if (showPopUp == false) {
        selectedIndexId.add(docId);
      } else {
        selectedIndexId = [];
        selectedIndexId.add(docId);
      }
      update();
    }
    update();
  }

  deleteBroadCast() async {
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .collection(collectionName.broadcastMessage)
        .doc(pId)
        .delete()
        .then((value) async {
      await FirebaseFirestore.instance
          .collection(collectionName.broadcast)
          .doc(pId)
          .delete()
          .then((value) async {
        await FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(appCtrl.user["id"])
            .collection(collectionName.chats)
            .where("broadcastId", isEqualTo: pId)
            .limit(1)
            .get()
            .then((broadcastVal)async {
      await    FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(appCtrl.user["id"])
              .collection(collectionName.chats)
              .doc(broadcastVal.docs[0].id)
              .delete();
        });
        Get.back();
        Get.back();
      });
    });
  }

  //check contact in firebase and if not exists
  saveContact(userData, {message}) async {

    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(userData["id"])
        .collection("chats")
        .where("isOneToOne", isEqualTo: true)
        .get()
        .then((value) {
      bool isEmpty = value.docs
          .where((element) =>
              element.data()["senderId"] == userData["uid"] ||
              element.data()["receiverId"] == userData["uid"])
          .isNotEmpty;
      if (!isEmpty) {
        var data = {"chatId": "0", "data": userData, "message": message};

        Get.back();
        Get.toNamed(routeName.chat, arguments: data);
      } else {
        value.docs.asMap().entries.forEach((element) {
          if (element.value.data()["senderId"] == userData["uid"] ||
              element.value.data()["receiverId"] == userData["uid"]) {
            var data = {
              "chatId": element.value.data()["chatId"],
              "data": userData,
              "message": message
            };
            Get.back();

            Get.toNamed(routeName.chat, arguments: data);
          }
        });
      }
    });
  }

  getTapPosition(TapDownDetails tapDownDetails) {
    RenderBox renderBox = Get.context!.findRenderObject() as RenderBox;
    update();
    tapPosition = renderBox.globalToLocal(tapDownDetails.globalPosition);
  }

  showContextMenu(context, value, snapshot) async {
    RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    final result = await showMenu(
        color: appCtrl.appTheme.whiteColor,
        context: context,
        position: RelativeRect.fromRect(
          Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 10, 10),
          Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
              overlay.paintBounds.size.height),
        ),
        items: [
          _buildPopupMenuItem("Chat $pName", 0),
          _buildPopupMenuItem("Remove $pName", 1),
        ]);
    if (result == 0) {
      var data = {
        "uid": value["id"],
        "username": value["name"],
        "phoneNumber": value["phone"],
        "image": snapshot.data!.data()!["image"],
        "description": snapshot.data!.data()!["statusDesc"],
        "isRegister": true,
      };
      UserContactModel userContactModel = UserContactModel.fromJson(data);
      saveContact(userContactModel);
    } else {
      removeUserFromGroup(value, snapshot);
    }
  }

  removeUserFromGroup(value, snapshot) async {
    await FirebaseFirestore.instance
        .collection(collectionName.broadcast)
        .doc(pId)
        .get()
        .then((group) {
      if (group.exists) {
        List user = group.data()!["users"];
        user.removeWhere((element) => element["phone"] == value["phone"]);
        update();
        FirebaseFirestore.instance
            .collection(collectionName.broadcast)
            .doc(pId)
            .update({"users": user}).then((value) {
          getBroadcastData();
        });
      }
    });
  }

  PopupMenuItem _buildPopupMenuItem(String title, int position) {
    return PopupMenuItem(
      value: position,
      child: Row(children: [
        Text(title,
            style:
                AppCss.poppinsMedium14.textColor(appCtrl.appTheme.blackColor))
      ]),
    );
  }

  void showBottomSheet(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (context) => EmojiPickerWidget(onSelected: (emoji) {
          Navigator.pop(context);
          onEmojiTap(emoji);
        }),
      );

  onEmojiTap(emoji) {
    onSendMessage(emoji, MessageType.text);
  }
}
