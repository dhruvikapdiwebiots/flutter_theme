import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dartx/dartx_io.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/message_model.dart';
import 'package:flutter_theme/pages/theme_pages/chat_message/layouts/chat_wall_paper.dart';
import 'package:flutter_theme/pages/theme_pages/chat_message/layouts/single_clear_dialog.dart';
import 'package:flutter_theme/widgets/reaction_pop_up/emoji_picker_widget.dart';
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
  List message = [];
  List<DateTimeChip> localMessage = [];
  dynamic pData, allData, userData;
  List<DrishyaEntity>? entities;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> allMessages = [];
  UserContactModel? userContactModel;
  bool positionStreamStarted = false;
  bool isUserAvailable = true;
  XFile? imageFile;
  XFile? videoFile;
  String? audioFile, wallPaperType;
  String selectedImage = "";
  final picker = ImagePicker();
  File? selectedFile;
  File? image;
  File? video;
  int? count;
  bool isLoading = true;
  bool enableReactionPopup = false, isChatSearch = false;
  bool showPopUp = false;
  List selectedIndexId = [];
  List searchChatId = [];

  bool typing = false, isBlock = false;
  final pickerCtrl = Get.isRegistered<PickerController>()
      ? Get.find<PickerController>()
      : Get.put(PickerController());
  final permissionHandelCtrl = Get.isRegistered<PermissionHandlerController>()
      ? Get.find<PermissionHandlerController>()
      : Get.put(PermissionHandlerController());
  TextEditingController textEditingController = TextEditingController();
  TextEditingController txtChatSearch = TextEditingController();
  ScrollController listScrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  StreamSubscription? messageSub;

  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  @override
  void onReady() {
    // TODO: implement onReady

    groupId = '';
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
      getAllDataLocally(data);
      isUserAvailable = true;
      update();
    }
    update();
    getChatData();

    super.onReady();
  }

  getAllDataLocally(data) async {
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .collection(collectionName.messages)
        .doc(chatId)
        .collection(collectionName.chat)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        allMessages = value.docs;
        update();
        log("allMessages ::: $allMessages");
        ChatMessageApi().getLocalMessage();
        update();
        isLoading = false;
        update();
      }
    });

  }

  //get chat data
  getChatData() async {

    if (chatId != "0") {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userData["id"])
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get()
          .then((value) {
        allData = value.docs[0].data();
        update();
      });

      messageSub = FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.messages)
          .doc(chatId)
          .collection(collectionName.chat)
          .snapshots()
          .listen((event) async {
        allMessages = event.docs;
        update();

        ChatMessageApi().getLocalMessage();

        isLoading = false;
        update();
      });
      isLoading = false;
      update();
    } else {
      isLoading = false;
      update();
    }
    seenMessage();
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(pId)
        .get()
        .then((value) {
      pData = value.data();

      update();
    });

    if (allData != null) {
      if (allData["backgroundImage"] != null ||
          allData["backgroundImage"] != "") {
        FirebaseFirestore.instance
            .collection(collectionName.users)
            .doc(userData["id"])
            .get()
            .then((value) {
          if (value.exists) {
            allData["backgroundImage"] = value.data()!["backgroundImage"];
          }
        });
      }
    } else {
      allData = {};
      allData["backgroundImage"] = "";
      allData["isBlock"] = false;
    }

    update();
    var data = Get.arguments;

    if (data["message"] != null) {
      onSendMessage(
          data["message"].statusType == StatusType.text.name
              ? data["message"].statusText!
              : data["message"].image!,
          data["message"].statusType == StatusType.image.name
              ? MessageType.image
              : data["message"].statusType == StatusType.text.name
                  ? MessageType.text
                  : MessageType.video);
    }
  }

  //audio and video call tap
  audioVideoCallTap(isVideoCall) async {
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
    if (allData != null) {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(appCtrl.user["id"])
          .collection(collectionName.messages)
          .doc(chatId)
          .collection(collectionName.chat)
          .where("receiver", isEqualTo: appCtrl.user["id"])
          .get()
          .then((value) {
        log("RECEIVER : ${value.docs.length}");
        value.docs.asMap().entries.forEach((element) async {
          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(appCtrl.user["id"])
              .collection(collectionName.messages)
              .doc(chatId)
              .collection(collectionName.chat)
              .doc(element.value.id)
              .update({"isSeen": true});
        });
      });
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userData["id"])
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(userData["id"])
              .collection(collectionName.chats)
              .doc(value.docs[0].id)
              .update({"isSeen": true});
        }
      });

      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(pId)
          .collection(collectionName.messages)
          .doc(chatId)
          .collection(collectionName.chat)
          .where("receiver", isEqualTo: appCtrl.user["id"])
          .get()
          .then((value) {
        log("RECEIVER : ${value.docs.length}");
        value.docs.asMap().entries.forEach((element) async {
          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(pId)
              .collection(collectionName.messages)
              .doc(chatId)
              .collection(collectionName.chat)
              .doc(element.value.id)
              .update({"isSeen": true});
        });
      });
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(pId)
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection(collectionName.users)
              .doc(pId)
              .collection(collectionName.chats)
              .doc(value.docs[0].id)
              .update({"isSeen": true});
        }
      });
    }
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

      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = reference.putFile(file);
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();
      isLoading = true;
      update();

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


    if (allData["isBlock"] == true) {
      Encrypted encrypteded = encryptFun("You unblock this contact");
      String encrypted = encrypteded.base64;


      ChatMessageApi().saveMessage(
          newChatId,
          pId,
          encrypted,
          MessageType.messageType,
          DateTime.now().millisecondsSinceEpoch.toString(),
          userData["id"]);

      await ChatMessageApi().saveMessageInUserCollection(
        userData["id"],
        pId,
        newChatId,
        encrypted,
        userData["id"],
        userData["name"],
        MessageType.messageType,
        isBlock: false,
      );
    } else {
      Encrypted encrypteded = encryptFun("You block this contact");
      String encrypted = encrypteded.base64;

      ChatMessageApi().saveMessage(
          newChatId,
          pId,
          encrypted,
          MessageType.messageType,
          DateTime.now().millisecondsSinceEpoch.toString(),
          userData["id"]);

      await ChatMessageApi().saveMessageInUserCollection(
        userData["id"],
        pData["id"],
        newChatId,
        encrypted,
        userData["id"],
        userData["name"],
        MessageType.messageType,
        isBlock: true,
      );
    }
    getChatData();
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
        imageFile = null;
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
    update();
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

          isLoading = true;
          update();
          onSendMessage(
              '${contact.displayName}-BREAK-${contact.phones[0].normalizedNumber}-BREAK-${contact.photo}',
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
  void onSendMessage(String content, MessageType type) async {
    // isLoading = true;
    update();
    Get.forceAppUpdate();
    Encrypted encrypteded = encryptFun(content);
    String encrypted = encrypteded.base64;

    if (content.trim() != '') {
      textEditingController.clear();
      final now = DateTime.now();
      String? newChatId =
          chatId == "0" ? now.microsecondsSinceEpoch.toString() : chatId;
      chatId = newChatId;
      update();
      imageUrl = "";
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      update();
      log("allData:: $allData");
      MessageModel messageModel = MessageModel(
          blockBy: allData != null ? allData["blockBy"] : "",
          blockUserId: allData != null ? allData["blockUserId"] : "",
          chatId: chatId,
          content: encrypted,
          docId: time,
          isBlock: false,
          isBroadcast: false,
          isFavourite: false,
          isSeen: false,
          messageType: "sender",
          receiver: pId,
          sender: appCtrl.user["id"],
          timestamp: time,
          type: type.name);
      bool isEmpty =
          localMessage.where((element) => element.time == "Today").isEmpty;
      if (isEmpty) {
        List<MessageModel>? message = [];
        if (message.isNotEmpty) {
          message.add(messageModel);
          message[0].docId = time;
        } else {
          message = [messageModel];
          message[0].docId = time;
        }
        DateTimeChip dateTimeChip =
            DateTimeChip(time: getDate(time), message: message);
        localMessage.add(dateTimeChip);
      } else {
        int index =
            localMessage.indexWhere((element) => element.time == "Today");

        if (!localMessage[index].message!.contains(messageModel)) {
          localMessage[index].message!.add(messageModel);
        }
      }
      if (allData != null && allData != "") {
        if (allData["isBlock"] == true) {
          if (allData["blockUserId"] == pId) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
                SnackBar(content: Text(fonts.unblockUser(pName))));
          } else {
            await ChatMessageApi()
                .saveMessage(
                    newChatId, pId, encrypted, type, time, userData["id"])
                .then((snap) async {
              isLoading = false;
              update();
              Get.forceAppUpdate();
              await ChatMessageApi().saveMessageInUserCollection(
                  pData["id"],
                  userData["id"],
                  newChatId,
                  encrypted,
                  userData["id"],
                  pName,
                  type);
            }).then((value) {
              isLoading = false;
              update();
              Get.forceAppUpdate();
            });
          }
          isLoading = false;
          update();
        } else {
          await ChatMessageApi()
              .saveMessage(
                  newChatId,
                  pId,
                  encrypted,
                  type,
                  DateTime.now().millisecondsSinceEpoch.toString(),
                  userData["id"])
              .then((value) async {
            await ChatMessageApi()
                .saveMessage(newChatId, pId, encrypted, type,
                    DateTime.now().millisecondsSinceEpoch.toString(), pId)
                .then((snap) async {
              isLoading = false;
              update();
              Get.forceAppUpdate();

              await ChatMessageApi().saveMessageInUserCollection(userData["id"],
                  pId, newChatId, encrypted, userData["id"], pName, type);
              await ChatMessageApi().saveMessageInUserCollection(pId, pId,
                  newChatId, encrypted, userData["id"], userData["name"], type);
            }).then((value) {
              isLoading = false;
              update();
              Get.forceAppUpdate();
            });
          });
        }
        isLoading = false;
        update();
        Get.forceAppUpdate();
      } else {
        isLoading = false;
        update();

        await ChatMessageApi()
            .saveMessage(
                newChatId,
                pId,
                encrypted,
                type,
                DateTime.now().millisecondsSinceEpoch.toString(),
                userData["id"])
            .then((value) async {
          await ChatMessageApi()
              .saveMessage(newChatId, pId, encrypted, type,
                  DateTime.now().millisecondsSinceEpoch.toString(), pId)
              .then((snap) async {
            isLoading = false;
            update();
            Get.forceAppUpdate();

            await ChatMessageApi().saveMessageInUserCollection(userData["id"],
                pId, newChatId, encrypted, userData["id"], pName, type);
            await ChatMessageApi().saveMessageInUserCollection(pId, pId,
                newChatId, encrypted, userData["id"], userData["name"], type);
          }).then((value) {
            isLoading = false;
            update();
            Get.forceAppUpdate();
            getChatData();
          });
        });
      }
    }

    if (chatId != "0") {
      await FirebaseFirestore.instance
          .collection(collectionName.users)
          .doc(userData["id"])
          .collection(collectionName.chats)
          .where("chatId", isEqualTo: chatId)
          .get()
          .then((value) {
        allData = value.docs[0].data();

        update();
      });
    }
    log("chatId :: R$chatId");
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(appCtrl.user["id"])
        .collection(collectionName.messages)
        .doc(chatId)
        .collection(collectionName.chat)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        allMessages = value.docs;
        update();
        ChatMessageApi().getLocalMessage();
        update();
      }
    });
    log("allMessages : $allMessages");
    seenMessage();
    await FirebaseFirestore.instance
        .collection(collectionName.users)
        .doc(pId)
        .get()
        .then((value) {
      pData = value.data();

      update();
    });
    if (pData["pushToken"] != "") {
      firebaseCtrl.sendNotification(
          title: "Single Message",
          msg: messageTypeCondition(type, content),
          chatId: chatId,
          token: pData["pushToken"],
          pId: pId,
          pName: appCtrl.user["name"],
          userContactModel: userContactModel,
          image: userData["image"],
          dataTitle: appCtrl.user["name"]);
    }
    isLoading = false;
    if (allData == null) {
      getChatData();
    }
    update();
    Get.forceAppUpdate();
  }

  //delete chat layout
  buildPopupDialog() async {
    await showDialog(
        context: Get.context!, builder: (_) => const DeleteAlert());
  }

  wallPaperConfirmation(image) async {
    Get.generalDialog(
      pageBuilder: (context, anim1, anim2) {
        return ChatWallPaper(image: image);
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

  Widget timeLayout(DateTimeChip document) {

    List<MessageModel> newMessageList = document.message!.reversed.toList();
    log("newMessageList : ${newMessageList.length}");
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
          return buildItem(
              e.key,
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
      return SenderMessage(
              document: document,
              index: index,
              docId: document.docId,
              title: title)
          .inkWell(onTap: () {
        enableReactionPopup = false;
        showPopUp = false;
        selectedIndexId = [];
        update();
      });
    } else if (document.sender != userData["id"]) {
      // RECEIVER MESSAGE
      return document.type! == MessageType.messageType.name
          ? Container()
          : document.isBlock!
              ? Container()
              : ReceiverMessage(
                  document: document,
                  index: index,
                  docId: document.docId,
                  title: title,
                ).inkWell(onTap: () {
                  enableReactionPopup = false;
                  showPopUp = false;
                  selectedIndexId = [];
                  update();
                  log("enable : $enableReactionPopup");
                });
    } else {
      return Container();
    }
  }

  // ON BACK PRESS
  Future<bool> onBackPress() {
    appCtrl.isTyping = false;
    appCtrl.update();
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

  Widget searchTextField() {
    return TextField(
      controller: txtChatSearch,
      onChanged: (val) async {
        count = null;
        searchChatId = [];
        selectedIndexId = [];
        log("message :: $message");
        localMessage.asMap().entries.forEach((element) {
          element.value.message!.asMap().entries.forEach((e) {
            if(decryptMessage(e.value.content).toString().toLowerCase().contains(txtChatSearch.text)){
              if (!searchChatId.contains(e.key)) {
                searchChatId.add(e.key);
              } else {
                searchChatId.remove(e.key);
              }
            }
          });
        });
      },

      //Display the keyboard when TextField is displayed
      cursorColor: appCtrl.appTheme.blackColor,
      style: AppCss.poppinsMedium14.textColor(appCtrl.appTheme.blackColor),
      textInputAction: TextInputAction.search,
      //Specify the action button on the keyboard
      decoration: InputDecoration(
        //Style of TextField
        enabledBorder: UnderlineInputBorder(
            //Default TextField border
            borderSide: BorderSide(color: appCtrl.appTheme.blackColor)),
        focusedBorder: UnderlineInputBorder(
            //Borders when a TextField is in focus
            borderSide: BorderSide(color: appCtrl.appTheme.blackColor)),
        hintText: 'Search', //Text that is displayed when nothing is entered.
      ),
    );
  }

//clear dialog
  clearChatConfirmation() async {
    Get.generalDialog(
      pageBuilder: (context, anim1, anim2) {
        return const SingleClearDialog();
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

  //ON TAP EMOJI BOTTOM SHEET OPEN
  void showBottomSheet(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        builder: (context) => EmojiPickerWidget(
          onSelected: (emoji) {
            textEditingController.text = textEditingController.text + emoji;
            log("emoji : ${emoji.codeUnits}");
            log("emoji : ${emoji.characters}");
            // onEmojiTap(emoji);
          },
          textEditingController: textEditingController,
        ),
      );

  //ON SELECT EMOJI SEND TO CHAT
  onEmojiTap(emoji) {
    onSendMessage(emoji, MessageType.text);
  }
}
