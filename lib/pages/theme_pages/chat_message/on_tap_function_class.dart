import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_theme/config.dart';
import 'package:flutter_theme/models/message_model.dart';
import 'package:open_filex/open_filex.dart';

class OnTapFunctionCall {
  var openResult = 'Unknown';
  //contentTap
  contentTap(ChatController chatCtrl, docId) {

    if (chatCtrl.selectedIndexId.isNotEmpty) {
      chatCtrl.enableReactionPopup = false;
      chatCtrl.showPopUp = false;
      if (!chatCtrl.selectedIndexId.contains(docId)) {
        chatCtrl.selectedIndexId.add(docId);
      } else {
        chatCtrl.selectedIndexId.remove(docId);
      }
      chatCtrl.update();
    }

  }

  //image tap
  imageTap(ChatController chatCtrl, docId,MessageModel document) async {
    if (chatCtrl.selectedIndexId.isNotEmpty || chatCtrl.enableReactionPopup) {
      if (chatCtrl.selectedIndexId.isNotEmpty) {
        chatCtrl.enableReactionPopup = false;
        chatCtrl.showPopUp = false;
      }
      if (!chatCtrl.selectedIndexId.contains(docId)) {
        chatCtrl.selectedIndexId.add(docId);
      } else {
        chatCtrl.selectedIndexId.remove(docId);
      }
      chatCtrl.update();
    } else {

      var dio = Dio();
      var tempDir = await getExternalStorageDirectory();
      var filePath = tempDir!.path +
          (decryptMessage(document.content).contains("-BREAK-")
              ? decryptMessage(document.content).split("-BREAK-")[0]
              : (decryptMessage(document.content)));
    await dio.download(
          decryptMessage(document.content).contains("-BREAK-")
              ? decryptMessage(document.content).split("-BREAK-")[1]
              : decryptMessage(document.content),
          filePath);
      final result = await OpenFilex.open(filePath);


      openResult = "type=${result.type}  message=${result.message}";

    }
  }

  //location tap
  locationTap(ChatController chatCtrl, docId, document) {
    if (chatCtrl.selectedIndexId.isNotEmpty || chatCtrl.enableReactionPopup) {
      if (chatCtrl.selectedIndexId.isNotEmpty) {
        chatCtrl.enableReactionPopup = false;
        chatCtrl.showPopUp = false;
      }
      if (!chatCtrl.selectedIndexId.contains(docId)) {
        chatCtrl.selectedIndexId.add(docId);
      } else {
        chatCtrl.selectedIndexId.remove(docId);
      }
      chatCtrl.update();
    } else {
      launchUrl(Uri.parse(decryptMessage(document.content)));
    }
  }

  //pdf tap
  pdfTap(ChatController chatCtrl, docId,MessageModel document) async {
    if (chatCtrl.selectedIndexId.isNotEmpty || chatCtrl.enableReactionPopup) {
      if (chatCtrl.selectedIndexId.isNotEmpty) {
        chatCtrl.enableReactionPopup = false;
        chatCtrl.showPopUp = false;
      }
      if (!chatCtrl.selectedIndexId.contains(docId)) {
        chatCtrl.selectedIndexId.add(docId);
      } else {
        chatCtrl.selectedIndexId.remove(docId);
      }
      chatCtrl.update();
    } else {

      var dio = Dio();
      var tempDir = await getExternalStorageDirectory();

      var filePath = tempDir!.path + decryptMessage(document.content).split("-BREAK-")[0];
     await dio.download(
          decryptMessage(document.content).split("-BREAK-")[1], filePath);

      final result = await OpenFilex.open(filePath);

      openResult = "type=${result.type}  message=${result.message}";
      OpenFilex.open(filePath);
    }
  }

  //doc tap
  docTap(ChatController chatCtrl, docId,MessageModel document) async {
    if (chatCtrl.selectedIndexId.isNotEmpty || chatCtrl.enableReactionPopup) {
      if (chatCtrl.selectedIndexId.isNotEmpty) {
        chatCtrl.enableReactionPopup = false;
        chatCtrl.showPopUp = false;
      }
      if (!chatCtrl.selectedIndexId.contains(docId)) {
        chatCtrl.selectedIndexId.add(docId);
      } else {
        chatCtrl.selectedIndexId.remove(docId);
      }
      chatCtrl.update();
    } else {

      var dio = Dio();
      var tempDir = await getExternalStorageDirectory();

      var filePath = tempDir!.path + decryptMessage(document.content).split("-BREAK-")[0];
      await dio.download(
          decryptMessage(document.content).split("-BREAK-")[1], filePath);

      final result = await OpenFilex.open(filePath);

      openResult = "type=${result.type}  message=${result.message}";
      OpenFilex.open(filePath);
    }
  }

  //excel tap
  excelTap(ChatController chatCtrl, docId, document) async {
    if (chatCtrl.selectedIndexId.isNotEmpty || chatCtrl.enableReactionPopup) {
      if (chatCtrl.selectedIndexId.isNotEmpty) {
        chatCtrl.enableReactionPopup = false;
        chatCtrl.showPopUp = false;
      }
      if (!chatCtrl.selectedIndexId.contains(docId)) {
        chatCtrl.selectedIndexId.add(docId);
      } else {
        chatCtrl.selectedIndexId.remove(docId);
      }
      chatCtrl.update();
    } else {

      var dio = Dio();
      var tempDir = await getExternalStorageDirectory();

      var filePath = tempDir!.path + decryptMessage(document.content).split("-BREAK-")[0];
      await dio.download(
          decryptMessage(document.content).split("-BREAK-")[1], filePath);

      final result = await OpenFilex.open(filePath);

      openResult = "type=${result.type}  message=${result.message}";

      OpenFilex.open(filePath);
    }
  }

  //doc image tap
  docImageTap(ChatController chatCtrl, docId, document) async {
    if (chatCtrl.selectedIndexId.isNotEmpty || chatCtrl.enableReactionPopup) {
      if (chatCtrl.selectedIndexId.isNotEmpty) {
        chatCtrl.enableReactionPopup = false;
        chatCtrl.showPopUp = false;
      }
      if (!chatCtrl.selectedIndexId.contains(docId)) {
        chatCtrl.selectedIndexId.add(docId);
      } else {
        chatCtrl.selectedIndexId.remove(docId);
      }
      chatCtrl.update();
    } else {

      var dio = Dio();
      var tempDir = await getExternalStorageDirectory();

      var filePath = tempDir!.path + decryptMessage(document.content).split("-BREAK-")[0];
       await dio.download(
          decryptMessage(document.content).split("-BREAK-")[1], filePath);

      final result = await OpenFilex.open(filePath);

      openResult = "type=${result.type}  message=${result.message}";
      OpenFilex.open(filePath);
    }
  }

  //on emoji select
  onEmojiSelect(ChatController chatCtrl,docId,emoji,title) async {
    log("ddff");
    chatCtrl.selectedIndexId = [];
    chatCtrl.showPopUp = false;
    chatCtrl.enableReactionPopup = false;

    int index = chatCtrl.localMessage.indexWhere((element) => (element.time!.contains("-other") ? element.time!.replaceAll("-other", '') : element.time) == title);

  int messageIndex =   chatCtrl.localMessage[index].message!.indexWhere((element) => element.docId == docId);
    chatCtrl.localMessage[index].message![messageIndex].emoji = emoji;
    await FirebaseFirestore.instance.collection(collectionName.users).doc(appCtrl.user["id"])
        .collection(collectionName.messages)
        .doc(chatCtrl.chatId)
        .collection(collectionName.chat)
        .doc(docId)
        .update({"emoji": emoji});

    chatCtrl.update();
    log("LLLLL : ${chatCtrl.localMessage[index].message![messageIndex].emoji}");
  }

  //on emoji select
  onEmojiSelectBroadcast(BroadcastChatController chatCtrl,docId,emoji,title) async {
    log("ddff");
    chatCtrl.selectedIndexId = [];
    chatCtrl.showPopUp = false;
    chatCtrl.enableReactionPopup = false;
    chatCtrl.update();

    int index = chatCtrl.localMessage.indexWhere((element) => (element.time!.contains("-other") ? element.time!.replaceAll("-other", '') : element.time) == title);

    int messageIndex =   chatCtrl.localMessage[index].message!.indexWhere((element) => element.docId == docId);
    chatCtrl.localMessage[index].message![messageIndex].emoji = emoji;
    await FirebaseFirestore.instance.collection(collectionName.users).doc(appCtrl.user["id"])
        .collection(collectionName.broadcastMessage)
        .doc(chatCtrl.pId)
        .collection(collectionName.chat)
        .doc(docId)
        .update({"emoji": emoji});

    chatCtrl.update();
    log("LLLLL : ${chatCtrl.localMessage[index].message![messageIndex].emoji}");
  }
}
